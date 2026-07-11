<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\User;
use App\Services\FirebaseNotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CustomerController extends Controller
{
    public function __construct()
    {
        $this->middleware('check.permission:view_clients')->only(['index', 'show']);
        $this->middleware('check.permission:create_clients')->only(['create', 'store']);
        $this->middleware('check.permission:edit_clients')->only(['edit', 'update']);
        $this->middleware('check.permission:delete_clients')->only(['destroy']);
    }

    /**
     * عرض قائمة العملاء
     */
    public function index(Request $request)
    {
        // Validation
        $validated = $request->validate([
            'search' => ['nullable', 'string', 'max:100'],
            'status' => ['nullable', 'in:active,inactive,blocked'],
            'date_from' => ['nullable', 'date'],
            'date_to' => ['nullable', 'date', 'after_or_equal:date_from'],
        ]);

        // تنظيف البحث (مهم)
        $validated['search'] = isset($validated['search']) ? trim($validated['search']) : null;

        // Query
        $customers = User::clients()
            ->search($validated['search'] ?? null)
            ->status($validated['status'] ?? null)
            ->dateRange(
                $validated['date_from'] ?? null,
                $validated['date_to'] ?? null
            )

            ->latest()
            ->paginate(15)
            ->withQueryString();

        return view('admin.customers.index', [
            'customers' => $customers,
            'stats' => User::customerStats(),
            'request' => $request,
        ]);
    }

    /**
     * عرض تفاصيل العميل
     */
    public function show($id)
    {
        $customer = User::clients()
            ->with('latestAddress:addresses.user_id,addresses.address')
            ->withCount([
                // كل الطلبات
                'orders as total_orders',

                // الطلبات المكتملة فقط
                'orders as completed_orders_count' => function ($q) {
                    $q->where('status', 'completed');
                },
            ])
            ->withSum([
                // مجموع المشتريات (فقط المكتملة)
                'orders as total_spent' => function ($q) {
                    $q->where('status', 'completed');
                },
            ], 'total')
            ->findOrFail($id);
        // آخر الطلبات
        $recentOrders = $customer->orders()
            ->withCount('items')
            ->latest()
            ->take(10)
            ->get();

        $customerStats = [
            'total_orders' => $customer->total_orders,
            'completed_orders' => $customer->completed_orders_count,
            'total_spent' => $customer->total_spent ?? 0,
        ];

        return view('admin.customers.show', compact(
            'customer',
            'recentOrders',
            'customerStats'
        ));
    }

    /**
     * حظر العميل
     */
    public function block(Request $request, $id)
    {
        $request->validate([
            'blocked_reason' => 'nullable|string|max:500',
        ]);

        $customer = User::where('role', 'client')->findOrFail($id);

        if ($customer->status === 'blocked') {
            return redirect()->back()->with('success', 'العميل محظور بالفعل');
        }

        $customer->status = 'blocked';
        $customer->blocked_reason = $request->blocked_reason ?? 'تم الحظر بواسطة المدير';
        $customer->blocked_at = now();
        $customer->blocked_by = Auth::id();
        $customer->save();

        return redirect()->back()->with('success', 'تم حظر العميل بنجاح');
    }

    /**
     * إلغاء حظر العميل
     */
    public function unblock($id)
    {
        $customer = User::where('role', 'client')->findOrFail($id);

        if ($customer->status !== 'blocked') {
            return redirect()->back()->with('success', 'العميل غير محظور');
        }

        $customer->status = 'active';
        $customer->blocked_reason = null;
        $customer->blocked_at = null;
        $customer->blocked_by = null;
        $customer->save();

        return redirect()->back()->with('success', 'تم إلغاء حظر العميل بنجاح');
    }

    /**
     * عرض طلبات العميل
     */
    public function orders($customerId)
    {
        $customer = User::clients()
            ->select('id', 'first_name', 'last_name')
            ->findOrFail($customerId);

        $orders = Order::with([
            'items:id,order_id,product_name,quantity,price,total',
        ])->withCount('items')
            ->where('user_id', $customerId)
            ->latest()
            ->paginate(15);

        return view('admin.customers.orders', compact('customer', 'orders'));
    }

    /**
     * حذف عميل (Soft Delete أو حذف نهائي حسب الحاجة)
     */
    public function destroy($id)
    {
        $customer = User::where('role', 'client')->findOrFail($id);

        // التحقق من وجود طلبات للعميل
        if ($customer->orders()->count() > 0) {
            if (request()->ajax()) {
                return response()->json([
                    'success' => false,
                    'message' => 'لا يمكن حذف العميل لأنه لديه طلبات مسجلة',
                ], 400);
            }

            return redirect()->back()->with('error', 'لا يمكن حذف العميل لأنه لديه طلبات مسجلة');
        }

        $customer->delete();

        if (request()->ajax()) {
            return response()->json([
                'success' => true,
                'message' => 'تم حذف العميل بنجاح',
            ]);
        }

        return redirect()->route('admin.customers.index')->with('success', 'تم حذف العميل بنجاح');
    }

    /**
     * تصدير العملاء إلى Excel/CSV
     */
    public function export(Request $request)
    {
        $query = User::where('role', 'client');

        // تطبيق نفس الفلاتر
        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('first_name', 'like', "%{$search}%")
                    ->orWhere('last_name', 'like', "%{$search}%")
                    ->orWhere('email', 'like', "%{$search}%")
                    ->orWhere('phone', 'like', "%{$search}%");
            });
        }

        if ($request->filled('status')) {
            if ($request->status === 'blocked') {
                $query->where('status', 'blocked');
            } elseif ($request->status === 'active') {
                $query->where('status', 'active');
            }
        }

        $customers = $query->withCount('orders')
            ->withSum('orders', 'total')
            ->get();

        // تصدير كـ CSV
        $fileName = 'customers_'.date('Y-m-d_His').'.csv';
        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => "attachment; filename={$fileName}",
        ];

        $callback = function () use ($customers) {
            $file = fopen('php://output', 'w');
            // إضافة BOM ليدعم اللغة العربية
            fprintf($file, chr(0xEF).chr(0xBB).chr(0xBF));

            // العناوين
            fputcsv($file, [
                'المعرف',
                'الاسم الأول',
                'الاسم الأخير',
                'البريد الإلكتروني',
                'رقم الجوال',
                'الحالة',
                'تاريخ التسجيل',
                'آخر تسجيل دخول',
                'عدد الطلبات',
                'إجمالي المشتريات',
            ]);

            // البيانات
            foreach ($customers as $customer) {
                fputcsv($file, [
                    $customer->id,
                    $customer->first_name,
                    $customer->last_name,
                    $customer->email,
                    $customer->phone ?? '-',
                    $customer->status === 'active' ? 'نشط' : ($customer->status === 'blocked' ? 'محظور' : 'غير نشط'),
                    $customer->created_at->format('Y-m-d'),
                    $customer->last_login_at ? $customer->last_login_at->format('Y-m-d H:i') : '-',
                    $customer->orders_count,
                    $customer->orders_sum_total ?? 0,
                ]);
            }

            fclose($file);
        };

        return response()->stream($callback, 200, $headers);
    }

    /**
     * عرض صفحة ارسال الاشعار الى العميل
     */
    public function createNotification($id)
    {
        $customer = User::clients()->findOrFail($id);

        return view('admin.customers.create-notification', compact('customer'));
    }

    /**
     * ارسال الاشعار الى العميل
     */
    public function storeNotification(Request $request, $id)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:60',
            'content' => 'required|string|max:160',
            'url' => 'nullable|url',
        ]);

        $customer = User::clients()->with('devices')->findOrFail($id);

        // جلب جميع التوكنات الصالحة
        $tokens = $customer->devices
            ->pluck('fcm_token')
            ->filter()
            ->unique();

        if ($tokens->isEmpty()) {
            return back()->with('error', 'لا توجد أجهزة مرتبطة بهذا العميل');
        }

        foreach ($tokens as $token) {

            app(FirebaseNotificationService::class)->send(
                $token,
                $validated['title'],
                $validated['content'],
                [
                    'type' => 'promotion',
                    'click_action' => $validated['url'] ?? url('/'),
                ]
            );
        }

        return back()->with('success', 'تم ارسال الاشعار بنجاح');
    }
}
