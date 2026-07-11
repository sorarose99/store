import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/theme/language_cubit.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/app_shimmer.dart';

// Pages
import '../pages/edit_profile_page.dart';
import '../../../orders/presentation/pages/orders_list_page.dart';
import '../../../wishlist/presentation/pages/wishlist_filled_page.dart';
import '../pages/delivery_addresses_page.dart';
import 'account_settings_page.dart';

// Bloc
import '../blocs/account_bloc.dart';
import '../blocs/account_event.dart';
import '../blocs/account_state.dart';

// Wishlist
import '../../../wishlist/presentation/blocs/wishlist_bloc.dart';
import '../../../wishlist/presentation/blocs/wishlist_state.dart';



class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    super.initState();
    // Fetch data if not already fetched
    final state = context.read<AccountBloc>().state;
    if (state is AccountInitial || state is AccountError) {
      context.read<AccountBloc>().add(const AccountProfileRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: AppBar(
          backgroundColor: context.surfaceColor,
          elevation: 0,
          leading: const SizedBox(), // Placeholder if no back button needed
          centerTitle: true,
          title: Text(
            tr('settings'),
            style: TextStyle(
              color: context.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            if (state is AccountLoading || state is AccountInitial) {
              return const ProfileShimmer();
            } else if (state is AccountError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message,
                        style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<AccountBloc>()
                          .add(const AccountProfileRequested()),
                      child: Text(tr('retry')),
                    ),
                  ],
                ),
              );
            } else if (state is AccountLoaded) {
              return _buildBody(context, state);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AccountLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AccountBloc>().add(const AccountProfileRequested());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(state.user),
            const SizedBox(height: 24),
            _buildStatsCards(state.stats),
            const SizedBox(height: 32),
            _buildSettingsSections(context, state.stats),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('welcome_back'),
                style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
              ),
              const SizedBox(height: 4),
              Text(
                user.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user.email ?? '',
                style: TextStyle(fontSize: 14, color: context.textGrey),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 35,
          backgroundColor: context.border,
          backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
              ? NetworkImage(user.avatar!)
              : null,
          child: (user.avatar == null || user.avatar!.isEmpty)
              ? Icon(Icons.person, size: 35, color: context.textGrey)
              : null,
        ),
      ],
    );
  }

  Widget _buildStatsCards(stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            tr('total_orders'),
            stats.totalOrders.toString(),
            Icons.inventory_2_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            tr('in_preparation'),
            stats.processingOrders.toString(),
            Icons.access_time, // Or hourglass_top
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            tr('completed_orders'),
            stats.completedOrders.toString(),
            Icons.check_circle_outline,
            iconColor: context.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon,
      {Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border),
        boxShadow: [
          BoxShadow(
            color: context.textDark.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor ?? context.textDark.withValues(alpha: 0.87), size: 26),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSections(BuildContext context, stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(tr('content')),
        _buildSectionBox([
          _buildSettingsItem(
            title: tr('profile'),
            icon: Icons.person_outline,
            onTap: () {
              final accountBloc = context.read<AccountBloc>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: accountBloc,
                    child: const EditProfilePage(),
                  ),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            title: tr('change_password'),
            icon: Icons.lock_outline,
            onTap: () {
              final accountBloc = context.read<AccountBloc>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: accountBloc,
                    child: const AccountSettingsPage(),
                  ),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            title: tr('my_orders'),
            icon: Icons.inventory_2_outlined,
            trailing: stats.totalOrders > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      stats.totalOrders.toString(),
                      style: TextStyle(color: context.backgroundColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  )
                : null,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const OrdersListPage())),
          ),
          _buildDivider(),
          _buildSettingsItem(
            title: tr('shipping_addresses'),
            icon: Icons.location_on_outlined,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const DeliveryAddressesPage())),
          ),
          _buildDivider(),
          _buildSettingsItem(
            title: tr('wishlist'),
            icon: Icons.favorite_border_outlined,
            trailing: BlocBuilder<WishlistBloc, WishlistState>(
              builder: (context, state) {
                if (state is WishlistLoaded && state.products.isNotEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${state.products.length}',
                      style: TextStyle(color: context.backgroundColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const WishlistFilledPage())),
          ),
        ]),
        const SizedBox(height: 24),
        _buildSectionTitle(tr('preferences_settings')),
        _buildSectionBox([
          _buildSettingsItem(
            title: tr('language'),
            icon: Icons.language,
            trailing: BlocBuilder<LanguageCubit, Locale>(
              builder: (context, locale) {
                return Text(
                  locale.languageCode == 'ar' ? 'العربية' : 'English',
                  style: TextStyle(
                    color: context.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              },
            ),
            onTap: () {
              final current = context.read<LanguageCubit>().state.languageCode;
              if (current == 'ar') {
                context.read<LanguageCubit>().setEnglish();
                context.setLocale(const Locale('en'));
              } else {
                context.read<LanguageCubit>().setArabic();
                context.setLocale(const Locale('ar'));
              }
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            title: tr('dark_mode'),
            icon: Icons.dark_mode_outlined,
            trailing: BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                return CupertinoSwitch(
                  value: themeMode == ThemeMode.dark,
                  activeTrackColor: context.primaryColor,
                  onChanged: (val) {
                    if (val) {
                      context.read<ThemeCubit>().setDark();
                    } else {
                      context.read<ThemeCubit>().setLight();
                    }
                  },
                );
              },
            ),
            onTap: () {},
            hideChevron: true,
          ),
        ]),
        const SizedBox(height: 24),
        _buildSectionTitle(tr('general_settings')),
        _buildSectionBox([
          _buildSettingsItem(
            title: tr('notifications'),
            icon: Icons.notifications_none_outlined,
            trailing: CupertinoSwitch(
              value: true,
              activeTrackColor: context.primaryColor,
              onChanged: (val) {
                // Notifications logic
              },
            ),
            onTap: () {},
            hideChevron: true,
          ),
          _buildDivider(),
          _buildSettingsItem(
            title: tr('delete_account'),
            icon: Icons.delete_outline,
            onTap: () {
              // Delete account logic / dialog
            },
          ),
          _buildDivider(),
          _buildSettingsItem(
            title: tr('logout'),
            icon: Icons.power_settings_new,
            titleColor: Colors.red,
            iconColor: Colors.red,
            hideChevron: true,
            onTap: () {
              // Proceed to account settings page which handles logout
              final accountBloc = context.read<AccountBloc>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: accountBloc,
                    child: const AccountSettingsPage(),
                  ),
                ),
              );
            },
          ),
        ]),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          color: context.textGrey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionBox(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
    Color? titleColor,
    Color? iconColor,
    bool hideChevron = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(12), // Match container if it's the first/last
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor ?? context.textDark.withValues(alpha: 0.87)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: titleColor ?? context.textDark.withValues(alpha: 0.87),
                ),
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null && !hideChevron)
              Icon(Icons.arrow_back_ios_new,
                  size: 14, color: context.textGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
        height: 1, thickness: 0.5, color: context.border, indent: 50);
  }
}
