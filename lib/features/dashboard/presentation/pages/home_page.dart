import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/widgets/app_card.dart';
import '../../../../core/ui/widgets/app_widgets.dart';
import '../../../../core/ui/widgets/transaction_list_item.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../features/transactions/domain/entities/transaction_entity.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;
    final transactions = MockData.transactions;
    final todayIssued = transactions.where((t) => t.issuedAt.day == DateTime.now().day).length;
    final paidToday = transactions.where((t) => t.paidAt != null && t.paidAt!.day == DateTime.now().day).length;
    final overdueCount = transactions.where((t) => t.status == TransactionStatus.overdue).length;
    final pendingSync = transactions.where((t) => t.status == TransactionStatus.pendingSync).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Good ${_greeting()}, ${user.fullName.split(' ').first}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${user.stationName}  ·  ${user.roleLabel}',
                                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/profile'),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                child: Text(
                                  user.fullName.split(' ').map((w) => w[0]).take(2).join(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Stats
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      StatCard(label: 'Issued Today', value: '$todayIssued', icon: Icons.receipt_rounded, color: AppColors.info),
                      StatCard(label: 'Paid Today', value: '$paidToday', icon: Icons.check_circle_rounded, color: AppColors.success),
                      StatCard(label: 'Overdue', value: '$overdueCount', icon: Icons.warning_rounded, color: AppColors.error, onTap: () => context.go('/search')),
                      StatCard(label: 'Pending Sync', value: '$pendingSync', icon: Icons.sync_rounded, color: AppColors.warning, onTap: () => context.go('/queue')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Quick Actions
                  const SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _QuickAction(icon: Icons.add_road_rounded, label: 'New Traffic\nOffense', color: AppColors.primary, onTap: () => context.go('/offense/new'))),
                      const SizedBox(width: 12),
                      Expanded(child: _QuickAction(icon: Icons.receipt_long_rounded, label: 'New Service\nFee', color: AppColors.secondary, onTap: () => context.go('/service-fee/new'))),
                      const SizedBox(width: 12),
                      Expanded(child: _QuickAction(icon: Icons.search_rounded, label: 'Search\nPRN', color: AppColors.info, onTap: () => context.go('/search'))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Recent Transactions
                  SectionHeader(title: 'Recent Transactions', actionLabel: 'View All', onAction: () => context.go('/search')),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  if (i < transactions.length - 1) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TransactionListItem(
                        transaction: transactions[i],
                        onTap: () => context.push('/transaction/${transactions[i].id}'),
                      ),
                    );
                  }
                  return TransactionListItem(
                    transaction: transactions[i],
                    onTap: () => context.push('/transaction/${transactions[i].id}'),
                  );
                },
                childCount: transactions.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          boxShadow: AppColors.cardShadow,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 0.5),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

