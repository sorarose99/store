<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Mail\OrderStatusMail;
use App\Models\Notification;
use App\Models\Order;
use App\Services\FirebaseNotificationService;
use App\Services\InfobipService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Mail;
use Mpdf\Config\ConfigVariables;
use Mpdf\Mpdf;

use function Symfony\Component\Clock\now;

class OrderController extends Controller
{
    protected $sms;

    public function __construct(InfobipService $sms)
    {
        $this->sms = $sms;
        $this->middleware('check.permission:view_orders')->only(['index', 'show']);
        $this->middleware('check.permission:create_orders')->only(['create', 'store']);
        $this->middleware('check.permission:edit_orders')->only(['edit', 'update']);
        $this->middleware('check.permission:delete_orders')->only(['destroy']);
    }

    /**
     * عرض قائمة الطلبات
     */
    public function index(Request $request)
    {
        $filters = $request->validate([
            'search' => ['nullable', 'string', 'max:50'],
            'status' => ['nullable', 'string', 'in:pending,processing,shipped,completed,cancelled'],
            'date_from' => ['nullable', 'date'],
            'date_to' => ['nullable', 'date', 'after_or_equal:date_from'],
        ]);

        $query = Order::with('user')->select(['id', 'order_number', 'shipping_full_name', 'user_id', 'total', 'status', 'created_at']);

        // order number
        $query->when(! empty($filters['search']), function ($q) use ($filters) {
            $q->where('order_number', 'like', '%'.$filters['search'].'%');
        });

        // فلتر الحالة
        $query->when(! empty($filters['status']), function ($q) use ($filters) {
            $q->where('status', $filters['status']);
        });

        // فلتر التاريخ من
        $query->when(! empty($filters['date_from']), function ($q) use ($filters) {
            $q->whereDate('created_at', '>=', $filters['date_from']);
        });

        // فلتر التاريخ إلى
        $query->when(! empty($filters['date_to']), function ($q) use ($filters) {
            $q->whereDate('created_at', '<=', $filters['date_to']);
        });

        $orders = $query->orderByDesc('created_at')->paginate(15);
        // stats
        $stats = Order::selectRaw("
            COUNT(*) as total,
            SUM(status = 'completed') as completed,
            SUM(status = 'pending') as pending,
            SUM(status = 'cancelled') as cancelled
        ")->first();

        // تحويل القيم إلى أعداد صحيحة
        $stats = [
            'total' => (int) $stats->total,
            'completed' => (int) $stats->completed,
            'pending' => (int) $stats->pending,
            'cancelled' => (int) $stats->cancelled,
        ];

        return view('admin.orders.index', compact('orders', 'stats', 'filters'));
    }

    /**
     * عرض تفاصيل الطلب
     */
    public function show($id)
    {

        $order = Order::with([
            'paymentTransaction:id,order_id,transaction_id,payment_method,status,paid_at',
            'user:id,avatar,first_name,last_name,email,phone,created_at',
            'items' => function ($q) {
                $q->select(
                    'id',
                    'order_id',
                    'product_id',
                    'product_name',
                    'sku',
                    'price',
                    'image',
                    'quantity',
                    'total',
                    'options'
                );
            },
            'items.product:id,name_ar,slug,sku',
            'items.product.primaryImage:id,product_id,path',
        ])
            ->findOrFail($id);

        $notification = Notification::where('related_id', $id)->first();

        if ($notification && ! $notification->is_read) {
            $notification->update([
                'is_read' => true,
                'read_at' => now(),
            ]);
        }

        return view('admin.orders.show', compact('order'));
    }

    /**
     * تحديث حالة الطلب
     */
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:pending,processing,shipped,completed,cancelled',
            'admin_notes' => 'nullable|string',
            'cancellation_reason' => 'nullable|string',
        ]);

        $order = Order::findOrFail($id);
        $oldStatus = $order->status;

        $order->status = $request->status;

        // ملاحظات إدارية عامة (كل الحالات)
        if ($request->filled('admin_notes')) {
            $order->admin_notes = $request->admin_notes;
        }

        // حالة الإلغاء
        if ($request->status === 'cancelled') {
            $order->cancellation_reason = $request->cancellation_reason ?? $request->admin_notes;
            $order->cancelled_by = Auth::id();
            $order->cancelled_at = now();
        }

        // حالة الإكمال
        if ($request->status === 'completed') {
            $order->completed_at = now();
        }

        $order->save();

        // تسجيل تغيير الحالة
        $notes = $request->admin_notes;
        if ($request->status === 'cancelled') {
            $notes = $request->cancellation_reason
                ?? $request->admin_notes
                ?? 'تم إلغاء الطلب';
        }
        $order->statusHistories()->create([
            'old_status' => $oldStatus,
            'new_status' => $request->status,
            'notes' => $notes,
            'user_id' => Auth::id(),
        ]);

        // إرسال إشعار للعميل إذا تم الطلب
        // $client_phone = $order->shipping_phone;
        // $orderNumber = $order->order_number;

        $client_email = $order->shipping_email;

        $sendStatuses = ['processing', 'shipped', 'completed', 'cancelled'];

        if ($oldStatus !== $order->status && in_array($order->status, $sendStatuses)) {
            Mail::to($client_email)->send(new OrderStatusMail($order));

            // إرسال Firebase Push Notification
            if ($order->user && $order->user->devices()->count() > 0) {

                $title = 'تحديث حالة الطلب';

                $body = match ($order->status) {
                    'processing' => 'تم استلام طلبك, نعمل الآن على تجهيز طلبك وسيتم إشعارك فور شحنه',
                    'shipped' => 'طلبك غادر مركز KDX, اللوجستي وهو في طريقه إليك',
                    'completed' => 'شكراً لتسوقك من KDX, تم تسليم طلبك إلى العنوان المحدد',
                    'cancelled' => 'تم إلغاء طلبك, وسيتم إعادة المبلغ وفق سياسة الأسترجاع',
                    default => 'تم تحديث حالة طلبك',
                };

                foreach ($order->user->devices as $device) {

                    app(FirebaseNotificationService::class)->send(
                        $device->fcm_token,
                        $title,
                        $body,
                        [
                            'order_number' => (string) $order->order_number,
                            'status' => $order->status,
                            'type' => 'order',
                            'click_action' => route('orders.show', $order->order_number),
                        ]
                    );
                }
            }
        }

        return redirect()->back()->with('success', 'تم تحديث حالة الطلب بنجاح');
    }

    /**
     * طباعة فاتورة الطلب
     */
    public function invoice($id)
    {
        $order = Order::select(
            'id',
            'order_number',
            'user_id',
            'subtotal',
            'shipping_cost',
            'tax',
            'discount',
            'total',
            'payment_method',
            'payment_status',
            'status',
            'shipping_full_name',
            'shipping_phone',
            'shipping_country',
            'shipping_city',
            'shipping_address',
            'created_at'
        )
            ->where('id', $id)
            ->with([
                'paymentTransaction:order_id,transaction_id',

                'user:id,first_name,last_name,email,phone',

                'items:id,order_id,product_name,sku,price,image,quantity,total',
            ])
            ->firstOrFail();

        // تأكد من وجود مجلد fonts في المسار العام
        $fontPath = $_SERVER['DOCUMENT_ROOT'].'/fonts';

        $config = [
            'mode' => 'utf-8',
            'format' => 'A4',
            'orientation' => 'P',
            'default_font' => 'tajawal',
            'default_font_size' => 11,
            'autoScriptToLang' => true,  // هام: يحول النصوص حسب اللغة
            'autoLangToFont' => true,    // هام: يختار الخط المناسب تلقائياً
            'useOTL' => 0xFF,            // يفترض استخدام OTL (OpenType Layout)
            'useKashida' => 75,          // يضبط طول الكشيدة للعربية
        ];

        // إضافة الخطوط المخصصة
        $config['fontDir'] = array_merge(
            (new ConfigVariables)->getDefaults()['fontDir'],
            [$fontPath]
        );

        $config['fontdata'] = [
            'tajawal' => [
                'R' => 'Tajawal-Regular.ttf',
                'B' => 'Tajawal-Bold.ttf',
                'I' => 'Tajawal-Regular.ttf',    // اختياري
                'BI' => 'Tajawal-Bold.ttf',      // اختياري
                'useOTL' => 0xFF,
                'useKashida' => 75,
            ],
        ];

        $mpdf = new Mpdf($config);

        // تفعيل دعم اللغة العربية بشكل إضافي
        $mpdf->SetDirectionality('rtl');

        // تفعيل مكتبة التشكيل العربي
        $mpdf->autoScriptToLang = true;
        $mpdf->autoLangToFont = true;

        // عرض الـ HTML
        $html = view('admin.orders.invoice', compact('order'))->render();
        $mpdf->WriteHTML($html);

        return response($mpdf->Output('order-'.$order->order_number.'.pdf', 'D'));
    }
}
