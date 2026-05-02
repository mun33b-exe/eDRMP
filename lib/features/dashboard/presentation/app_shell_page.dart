import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/logic/connectivity_notifier.dart';
import '../../../core/widgets/connectivity_banner.dart';
import '../../../theme/colors.dart';
import '../../devices/presentation/my_devices_page.dart';
import '../../notifications/presentation/notifications_page.dart';
import '../../profile/presentation/profile_page.dart';
import 'dashboard_page.dart';

// ---------------------------------------------------------------------------
// Tab index constants
// ---------------------------------------------------------------------------
const int _kTabHome = 0;
const int _kTabDevices = 1;
const int _kTabFir = 3;
const int _kTabProfile = 4;

/// Root shell for the citizen user.
///
/// Renders the design-faithful bottom nav from the [BottomNav] JSX component
/// in `components.jsx`:
///   Home | Devices | [FAB Register] | FIR | Profile
///
/// The floating centre FAB is elevated with a navy shadow and navigates to
/// the Add Device flow (Phase 3 stub navigated via [RouteNames.addDevice]).
class AppShellPage extends ConsumerStatefulWidget {
  const AppShellPage({this.initialTab = _kTabHome, super.key});

  final int initialTab;

  @override
  ConsumerState<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends ConsumerState<AppShellPage> {
  late int _selectedTab;

  static const List<Widget> _pages = [
    DashboardPage(),
    MyDevicesPage(),
    SizedBox.shrink(), // slot 2: FAB navigates away, never rendered
    NotificationsPage(), // FIR tab slot — Phase 4 will replace with FirHistoryPage
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      // Centre FAB — navigate to add device.
      context.push(RouteNames.addDevice);
      return;
    }
    setState(() => _selectedTab = index);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final isOnline = ref.watch(connectivityProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.scaffoldBackground,
      body: Column(
        children: [
          ConnectivityBanner(isOnline: isOnline),
          Expanded(
            child: IndexedStack(
              index: _selectedTab == 2 ? 0 : _selectedTab,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _CitizenBottomNav(
        selectedIndex: _selectedTab,
        isDark: isDark,
        onTap: _onTabTapped,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom navigation — pixel-match of BottomNav component (components.jsx)
// ---------------------------------------------------------------------------

class _CitizenBottomNav extends StatelessWidget {
  const _CitizenBottomNav({
    required this.selectedIndex,
    required this.isDark,
    required this.onTap,
  });

  final int selectedIndex;
  final bool isDark;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    const selected = AppColors.primary;
    final unselected = isDark ? AppColors.darkTextPrimary : AppColors.textMuted;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: AppStrings.navHome,
                isActive: selectedIndex == _kTabHome,
                color: selectedIndex == _kTabHome ? selected : unselected,
                onTap: () => onTap(_kTabHome),
              ),
              _NavItem(
                icon: Icons.devices_outlined,
                activeIcon: Icons.devices,
                label: AppStrings.navDevices,
                isActive: selectedIndex == _kTabDevices,
                color: selectedIndex == _kTabDevices ? selected : unselected,
                onTap: () => onTap(_kTabDevices),
              ),
              _CentreFab(onTap: () => onTap(2)),
              _NavItem(
                icon: Icons.shield_outlined,
                activeIcon: Icons.shield,
                label: AppStrings.navFir,
                isActive: selectedIndex == _kTabFir,
                color: selectedIndex == _kTabFir ? selected : unselected,
                onTap: () => onTap(_kTabFir),
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: AppStrings.navProfile,
                isActive: selectedIndex == _kTabProfile,
                color: selectedIndex == _kTabProfile ? selected : unselected,
                onTap: () => onTap(_kTabProfile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppPadding.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(isActive ? activeIcon : icon, size: 22, color: color),
              AppSpacing.vXs,
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CentreFab extends StatelessWidget {
  const _CentreFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -AppPadding.lg),
        child: Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppRadius.allLg,
            boxShadow: [
              BoxShadow(
                color: Color(0x660B2A5B),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.add, size: 24, color: Colors.white),
        ),
      ),
    );
  }
}
