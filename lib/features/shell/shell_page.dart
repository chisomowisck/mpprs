import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class ShellPage extends StatelessWidget {
  final Widget child;
  const ShellPage({super.key, required this.child});

  static const _tabs = [
    _NavTab('/home', Icons.home_rounded, Icons.home_outlined, 'Home'),
    _NavTab('/new', Icons.add_circle_rounded, Icons.add_circle_outline_rounded, 'New'),
    _NavTab('/search', Icons.search_rounded, Icons.search_rounded, 'Search'),
    _NavTab('/queue', Icons.cloud_sync_rounded, Icons.cloud_sync_outlined, 'Queue'),
    _NavTab('/profile', Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
  ];

  int _getSelectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _tabs.length; i++) {
      if (loc.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final isSelected = i == selectedIndex;
                return Expanded(
                  child: _NavItem(
                    tab: tab,
                    isSelected: isSelected,
                    onTap: () => context.go(tab.path),
                    showBadge: tab.path == '/queue',
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _NavTab tab;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showBadge;

  const _NavItem({required this.tab, required this.isSelected, required this.onTap, this.showBadge = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? tab.activeIcon : tab.icon,
                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
                  size: 24,
                ),
                if (showBadge)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: AppColors.pending, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tab.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTab {
  final String path;
  final IconData activeIcon;
  final IconData icon;
  final String label;
  const _NavTab(this.path, this.activeIcon, this.icon, this.label);
}

