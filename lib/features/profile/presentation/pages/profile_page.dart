import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AuthCubit>().state;
    final user = state is AuthAuthenticated ? state.user : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        automaticallyImplyLeading: false,
      ),
      body: user == null
          ? const Center(child: Text('Not authenticated'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.pagePadding),
              child: Column(
                children: [
                  _ProfileHeader(user: user),
                  const SizedBox(height: 16),
                  _IdentityCard(user: user),
                  const SizedBox(height: 16),
                  _PermissionsCard(user: user),
                  const SizedBox(height: 16),
                  _AppInfoCard(),
                  const SizedBox(height: 16),
                  _LogoutButton(onLogout: () => _logout(context)),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out of MPPRS?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthCubit>().logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, minimumSize: const Size(100, 44)),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final UserEntity user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.elevatedShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 12),
          Text(user.fullName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(user.roleLabel, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          Text(user.stationName, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── Identity Card ────────────────────────────────────────────────────────────

class _IdentityCard extends StatelessWidget {
  final UserEntity user;
  const _IdentityCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'IDENTITY',
      icon: Icons.badge_rounded,
      children: [
        _ProfileRow(label: 'Full Name', value: user.fullName),
        _ProfileRow(label: 'Username', value: user.username),
        _ProfileRow(label: 'Badge Number', value: user.badgeNumber),
        _ProfileRow(label: 'Role', value: user.roleLabel, valueColor: AppColors.primary),
        _ProfileRow(label: 'Station', value: user.stationName),
        _ProfileRow(label: 'Device ID', value: user.deviceId, canCopy: true),
      ],
    );
  }
}

// ─── Permissions Card ─────────────────────────────────────────────────────────

class _PermissionsCard extends StatelessWidget {
  final UserEntity user;
  const _PermissionsCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'PERMISSIONS',
      icon: Icons.security_rounded,
      children: [
        _PermissionRow(label: 'Issue Traffic Offense PRN', granted: true),
        _PermissionRow(label: 'Issue Service Fee PRN', granted: true),
        _PermissionRow(label: 'Void PRN', granted: user.canVoidPrn),
        _PermissionRow(label: 'View Station PRNs', granted: user.canViewStationPrns),
        _PermissionRow(label: 'Export / Finance Reports', granted: user.role == UserRole.financeViewer),
      ],
    );
  }
}

// ─── App Info Card ────────────────────────────────────────────────────────────

class _AppInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'APPLICATION',
      icon: Icons.info_outline_rounded,
      children: [
        _ProfileRow(label: 'App Version', value: 'v${AppConstants.appVersion}'),
        _ProfileRow(label: 'Environment', value: 'Production'),
        _ProfileRow(label: 'System', value: AppConstants.appFullName),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Diagnostics export coming soon.'), behavior: SnackBarBehavior.floating),
            );
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('Export Diagnostics'),
        ),
      ],
    );
  }
}

// ─── Logout Button ────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;
  const _LogoutButton({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onLogout,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(color: AppColors.error, width: 1.5),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.logout_rounded, size: 20),
      label: const Text('Sign Out'),
    );
  }
}

// ─── Reusable Section Container ───────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _Section({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), boxShadow: AppColors.cardShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 1.2)),
          ]),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

// ─── Profile Row ──────────────────────────────────────────────────────────────

class _ProfileRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool canCopy;
  const _ProfileRow({required this.label, required this.value, this.valueColor, this.canCopy = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? AppColors.textPrimary), textAlign: TextAlign.right)),
          if (canCopy) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!'), duration: Duration(seconds: 1), behavior: SnackBarBehavior.floating));
              },
              child: const Icon(Icons.copy_rounded, size: 14, color: AppColors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Permission Row ───────────────────────────────────────────────────────────

class _PermissionRow extends StatelessWidget {
  final String label;
  final bool granted;
  const _PermissionRow({required this.label, required this.granted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(granted ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 18, color: granted ? AppColors.paid : AppColors.border),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: granted ? AppColors.textPrimary : AppColors.textTertiary))),
        ],
      ),
    );
  }
}

