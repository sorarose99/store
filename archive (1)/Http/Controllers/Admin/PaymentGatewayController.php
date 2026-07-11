<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\PaymentGateway;
use App\Models\PaymentTransaction;
use Illuminate\Http\Request;

class PaymentGatewayController extends Controller
{
    public function __construct()
    {
        $this->middleware('check.permission:view_payments')->only(['index', 'show', 'history']);
        $this->middleware('check.permission:manage_payments')->only(['edit', 'update', 'updatePaytabs', 'destroy']);
    }

    public function index()
    {
        $gateways = [
            'paytabs' => [
                'currency' => 'SAR',
                'credentials' => [
                    'profile_id' => '',
                    'server_key' => '',
                    'client_key' => '',
                ],
            ],

            'tabby' => [
                'currency' => 'KWD',
                'credentials' => [
                    'secret_key' => '',
                    'public_key' => '',
                    'merchant_code' => '',
                ],
            ],

            'tamara' => [
                'currency' => 'SAR',
                'credentials' => [
                    'api_token' => '',
                    'notification_token' => '',
                ],
            ],
        ];

        foreach ($gateways as $name => $data) {
            PaymentGateway::firstOrCreate(
                ['name' => $name],
                [
                    'is_active' => false,
                    'mode' => 'sandbox',
                    'currency' => $data['currency'],
                    'credentials' => $data['credentials'],
                ]
            );
        }

        $paymentGateways = PaymentGateway::all();

        return view('admin.payments.index', compact('paymentGateways'));
    }

    public function update(Request $request, $gateway)
    {
        $gatewayModel = PaymentGateway::where('name', $gateway)->firstOrFail();

        $request->validate([
            'is_active' => 'nullable',
            'mode' => 'required|in:sandbox,live',
            'currency' => 'required|string|max:10',
        ]);

        $credentials = [];

        switch ($gateway) {

            case 'paytabs':
                $credentials = [
                    'profile_id' => $request->profile_id,
                    'server_key' => $request->server_key,
                    'client_key' => $request->client_key,
                ];
                break;

            case 'tabby':
                $credentials = [
                    'secret_key' => $request->secret_key,
                    'public_key' => $request->public_key,
                    'merchant_code' => $request->merchant_code,
                ];
                break;

            case 'tamara':
                $credentials = [
                    'api_token' => $request->api_token,
                    'notification_token' => $request->notification_token,
                ];
                break;
        }

        $gatewayModel->update([
            'is_active' => $request->has('is_active'),
            'mode' => $request->mode,
            'currency' => $request->currency,
            'credentials' => $credentials,
        ]);

        return back()->with('success', 'تم تحديث البوابة بنجاح');
    }

    /**
     * عرض سجل المدفوعات
     */
    public function history(Request $request)
    {
        $query = PaymentTransaction::with(['order', 'user']);

        // فلتر حسب الحالة
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        // فلتر حسب طريقة الدفع
        if ($request->filled('method')) {
            $query->where('payment_method', $request->method);
        }

        // فلتر حسب التاريخ (اختياري)
        if ($request->filled('date_from')) {
            $query->whereDate('created_at', '>=', $request->date_from);
        }

        if ($request->filled('date_to')) {
            $query->whereDate('created_at', '<=', $request->date_to);
        }

        // فلتر حسب المبلغ (اختياري)
        if ($request->filled('amount_min')) {
            $query->where('amount', '>=', $request->amount_min);
        }

        if ($request->filled('amount_max')) {
            $query->where('amount', '<=', $request->amount_max);
        }

        // Get paginated results
        $transactions = $query->orderBy('created_at', 'desc')->paginate(15);

        // Calculate statistics - Create fresh queries to avoid modifying the main query
        $statistics = [
            'total_amount' => PaymentTransaction::when($request->filled('status'), function ($q) use ($request) {
                return $q->where('status', $request->status);
            })->when($request->filled('method'), function ($q) use ($request) {
                return $q->where('payment_method', $request->method);
            })->where('status', 'completed')->sum('amount'),

            'total_transactions' => PaymentTransaction::when($request->filled('status'), function ($q) use ($request) {
                return $q->where('status', $request->status);
            })->when($request->filled('method'), function ($q) use ($request) {
                return $q->where('payment_method', $request->method);
            })->count(),

            'completed_count' => PaymentTransaction::when($request->filled('status'), function ($q) use ($request) {
                return $q->where('status', $request->status);
            })->when($request->filled('method'), function ($q) use ($request) {
                return $q->where('payment_method', $request->method);
            })->where('status', 'completed')->count(),

            'failed_count' => PaymentTransaction::when($request->filled('status'), function ($q) use ($request) {
                return $q->where('status', $request->status);
            })->when($request->filled('method'), function ($q) use ($request) {
                return $q->where('payment_method', $request->method);
            })->where('status', 'failed')->count(),

            'pending_count' => PaymentTransaction::when($request->filled('status'), function ($q) use ($request) {
                return $q->where('status', $request->status);
            })->when($request->filled('method'), function ($q) use ($request) {
                return $q->where('payment_method', $request->method);
            })->where('status', 'pending')->count(),
        ];

        return view('admin.payments.history', compact('transactions', 'statistics'));
    }

    /**
     * عرض تفاصيل معاملة محددة
     */
    public function show($id)
    {
        $transaction = PaymentTransaction::with(['order:id,order_number', 'user:id,email,first_name,last_name'])
            ->select('order_id', 'user_id', 'transaction_id', 'payment_method', 'status', 'amount', 'currency', 'created_at', 'paid_at')->findOrFail($id);

        if (request()->ajax()) {
            return response()->json($transaction);
        }

        return view('admin.payments.show', compact('transaction'));
    }

    /**
     * تصدير سجل المدفوعات
     */
    public function export(Request $request)
    {
        $query = PaymentTransaction::with(['order', 'user']);

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('method')) {
            $query->where('payment_method', $request->method);
        }

        $transactions = $query->orderBy('created_at', 'desc')->get();

        // تصدير CSV
        $filename = 'payment_history_'.date('Y-m-d_His').'.csv';

        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => "attachment; filename=\"$filename\"",
        ];

        $callback = function () use ($transactions) {
            $file = fopen('php://output', 'w');

            // Add UTF-8 BOM for Arabic support
            fprintf($file, chr(0xEF).chr(0xBB).chr(0xBF));

            // Headers
            fputcsv($file, [
                'ID',
                'رقم العملية',
                'رقم الطلب',
                'اسم المستخدم',
                'البريد الإلكتروني',
                'المبلغ',
                'العملة',
                'طريقة الدفع',
                'الحالة',
                'تاريخ الإنشاء',
                'تاريخ الدفع',
                'رسالة الخطأ',
            ]);

            // Data rows
            foreach ($transactions as $transaction) {
                fputcsv($file, [
                    $transaction->id,
                    $transaction->transaction_id,
                    $transaction->order_id,
                    $transaction->user?->name,
                    $transaction->user?->email,
                    $transaction->amount,
                    $transaction->currency,
                    $transaction->payment_method,
                    $transaction->status,
                    $transaction->created_at,
                    $transaction->paid_at,
                    $transaction->error_message,
                ]);
            }

            fclose($file);
        };

        return response()->stream($callback, 200, $headers);
    }
}
