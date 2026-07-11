<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;

class DashboardController extends Controller
{
    public function __construct()
    {
        $this->middleware('check.permission:dashboard');
    }
        
    /**
     * عرض الصفحة الرئيسية للوحة التحكم
     */
    public function index(Request $request)
    {
        // إحصائيات سريعة
        $totalSales = Order::where('status', 'completed')->sum('total');
        $totalOrders = Order::count();
        $totalProducts = Product::count();
        $totalCustomers = User::where('role', 'client')->count();

        // آخر الطلبات
        $recentOrders = Order::with('user')
            ->orderBy('created_at', 'desc')
            ->take(5)
            ->get();

        // أفضل المنتجات مبيعاً
        $topProducts = Product::withCount('orderItems')
            ->orderBy('order_items_count', 'desc')
            ->take(5)
            ->get();

        // إحصائيات المبيعات لاخر سنة او شهر او اسبوع
        $period = $request->input('period', 'month');
        if ($period == 'year') {
            $days = 365;
        } else if ($period == 'month') {
            $days = 30;
        } else {
            $days = 7;
        }
        $salesData = $this->getSalesData($days);

        // توزيع حالات الطلبات
        $orderStatusCounts = [
            'pending' => Order::where('status', 'pending')->count(),
            'processing' => Order::where('status', 'processing')->count(),
            'completed' => Order::where('status', 'completed')->count(),
            'cancelled' => Order::where('status', 'cancelled')->count(),
        ];

        $totalOrdersCount = array_sum($orderStatusCounts);

        $orderStatusPercentages = [
            'completed' => $totalOrdersCount ? round(($orderStatusCounts['completed'] / $totalOrdersCount) * 100) : 0,
            'pending'   => $totalOrdersCount ? round(($orderStatusCounts['pending'] / $totalOrdersCount) * 100) : 0,
            'processing' => $totalOrdersCount ? round(($orderStatusCounts['processing'] / $totalOrdersCount) * 100) : 0,
            'cancelled' => $totalOrdersCount ? round(($orderStatusCounts['cancelled'] / $totalOrdersCount) * 100) : 0,
        ];

        return view('admin.dashboard.index', compact(
            'totalSales',
            'totalOrders',
            'totalProducts',
            'totalCustomers',
            'recentOrders',
            'topProducts',
            'salesData',
            'orderStatusCounts',
            'orderStatusPercentages'
        ));
    }

    /**
     * الحصول على بيانات المبيعات للرسم البياني
     */
    private function getSalesData($days)
    {
        // تحديد نطاق التاريخ
        $startDate = now()->subDays($days - 1)->startOfDay();
        $endDate = now()->endOfDay();

        // جلب البيانات مرة واحدة فقط
        $sales = Order::selectRaw('DATE(created_at) as date, SUM(total) as total')
            ->where('status', 'completed')
            ->whereBetween('created_at', [$startDate, $endDate])
            ->groupBy('date')
            ->pluck('total', 'date');

        $labels = [];
        $data = [];

        // بناء الأيام كاملة حتى لو ما فيها مبيعات
        for ($i = $days - 1; $i >= 0; $i--) {
            $date = now()->subDays($i)->format('Y-m-d');

            $labels[] = $date;
            $data[] = $sales[$date] ?? 0; // إذا ماكو مبيعات يرجع 0
        }

        return [
            'labels' => $labels,
            'data' => $data
        ];
    }
}
