import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';
import '../../widgets/confirm_dialog.dart';
import '../dashboard/dashboard_screen.dart';
import '../vehicles/vehicle_list_screen.dart';

/// Navigation destination item definition for the Application Shell.
class NavItem {
  final String title;
  final IconData icon;
  final IconData selectedIcon;

  const NavItem({
    required this.title,
    required this.icon,
    required this.selectedIcon,
  });
}

/// Responsive Desktop-First Admin Application Shell.
/// Features a permanent sidebar on desktop, adaptive drawer on mobile/tablet,
/// top navigation bar with user profile & actions, and content area.
class AppShell extends StatefulWidget {
  final int initialIndex;

  const AppShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<NavItem> _navItems = const [
    NavItem(
      title: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
    ),
    NavItem(
      title: 'Vehicle Fleet',
      icon: Icons.directions_car_outlined,
      selectedIcon: Icons.directions_car,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onSelectNav(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Close drawer if open on mobile
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await ConfirmDialog.show(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out of the Vehicle Management System?',
      confirmLabel: 'Sign Out',
      isDestructive: true,
    );

    if (confirm == true && mounted) {
      AuthRepository().logout();
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final user = AuthRepository().currentUser;

    // Body content pages based on selected nav index
    final pages = [
      DashboardScreen(
        onNavigateToVehicles: () => _onSelectNav(1),
      ),
      const VehicleListScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: isDesktop ? null : _buildMobileDrawer(user),
      body: Row(
        children: [
          // Permanent Desktop Sidebar
          if (isDesktop) _buildDesktopSidebar(user),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                _buildTopAppBar(isDesktop, user),
                const Divider(height: 1),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: pages,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Top App Bar containing hamburger (mobile), search/title, and user profile chip
  Widget _buildTopAppBar(bool isDesktop, dynamic user) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white,
      child: Row(
        children: [
          if (!isDesktop) ...[
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            const SizedBox(width: 8),
          ],

          // Current Section Title
          Text(
            _navItems[_currentIndex].title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),

          const Spacer(),

          // System Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_done_outlined, size: 14, color: AppColors.statusActive),
                SizedBox(width: 6),
                Text(
                  'System Ready',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // User Profile Avatar & Name
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Text(
                  user?.avatarInitials ?? 'AD',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Alex Johnson',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      user?.role ?? 'Fleet Manager',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(width: 12),

          // Logout Action Button
          IconButton(
            icon: const Icon(Icons.logout, size: 20, color: Color(0xFF64748B)),
            tooltip: 'Sign Out',
            onPressed: _handleLogout,
          ),
        ],
      ),
    );
  }

  /// Permanent Modern Dark Sidebar for Desktop
  Widget _buildDesktopSidebar(dynamic user) {
    return Container(
      width: AppConstants.sidebarWidth,
      color: AppColors.sidebarLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Title
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.local_shipping, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appShortName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Admin Portal',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF334155), height: 1),

          // Navigation Links
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'MAIN MENU',
              style: TextStyle(
                color: const Color(0xFF94A3B8).withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _currentIndex == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Material(
                    color: isSelected ? AppColors.sidebarSelected : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () => _onSelectNav(index),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              size: 20,
                              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer info
          const Divider(color: Color(0xFF334155), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              AppConstants.appVersion,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  /// Drawer for Tablet / Mobile viewports
  Widget _buildMobileDrawer(dynamic user) {
    return Drawer(
      backgroundColor: AppColors.sidebarLight,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1E293B)),
            child: Row(
              children: [
                const Icon(Icons.local_shipping, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?.name ?? 'Admin',
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _currentIndex == index;
                return ListTile(
                  leading: Icon(
                    isSelected ? item.selectedIcon : item.icon,
                    color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: AppColors.sidebarSelected,
                  onTap: () => _onSelectNav(index),
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFEF4444)),
            title: const Text('Sign Out', style: TextStyle(color: Color(0xFFEF4444))),
            onTap: _handleLogout,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
