<?php

namespace App\Providers;

use App\Models\ContactMessage;
use App\Models\Notification;
use App\Models\Setting;
use App\Services\CartService;
use Illuminate\Pagination\Paginator;
use Illuminate\Support\Facades\Blade;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\Facades\View;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        if (app()->environment('production')) {
            URL::forceScheme('https');
        }

        Paginator::useBootstrap();

        // لاضافة اصدار لملفات js,css حتى يعتبرها الكاش بالمتصفحات ملفات جديدة
        Blade::directive('versioned', function ($path) {
            return "<?php
        \$pathValue = $path;

        \$fullPath = public_path(\$pathValue);

        if (file_exists(\$fullPath)) {
            echo asset(\$pathValue) . '?v=' . filemtime(\$fullPath);
        } else {
            echo asset(\$pathValue);
        }
    ?>";
        });

        View::composer('*', function ($view) {
            $settings = cache()->rememberForever('settings_all', function () {
                return Setting::where('group', 'store')
                    ->pluck('value', 'key')
                    ->toArray();
            });

            $view->with('globalSettings', $settings);
        });
        View::composer('partials.header', function ($view) {
            $cartService = app(CartService::class);

            $view->with('cartCount', $cartService->countItems());
        });

        // show count contact messages and show latest 5 message
        View::composer('admin.partials.header', function ($view) {
            $latestMessages = ContactMessage::latest()->take(5)->get();
            $latestNotifications = Notification::where('audience', 'admin')->latest()->take(5)->get();

            $view->with([
                'unreadMessagesCount' => ContactMessage::where('is_read', false)->count(),
                'unreadNotificationsCount' => Notification::where('is_read', false)->count(),
                'latestMessages' => $latestMessages,
                'latestNotifications' => $latestNotifications,
            ]);
        });
    }
}
