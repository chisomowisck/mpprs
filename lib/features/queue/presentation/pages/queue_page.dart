import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/widgets/app_widgets.dart';
import '../../../../core/ui/widgets/status_chip.dart';
import '../../../../features/transactions/domain/entities/transaction_entity.dart';

class QueuePage extends StatefulWidget {
  const QueuePage({super.key});
  @override
  State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  // Simulate offline state for demo
  bool _isOffline = false;

  List<TransactionEntity> get _queueItems => MockData.transactions.where((t) =>
      t.status == TransactionStatus.draft ||
      t.status == TransactionStatus.pendingSync ||
      t.status == TransactionStatus.failedSync).toList();

  void _retryAll() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Retrying sync for all pending items…'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _discardDraft(TransactionEntity tx) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Discard Draft', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Discard the draft for "${tx.categoryName}" (${tx.offenderName})? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, minimumSize: const Size(100, 44)),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft discarded.'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _queueItems;
    final pendingCount = items.where((t) => t.status == TransactionStatus.pendingSync).length;
    final failedCount = items.where((t) => t.status == TransactionStatus.failedSync).length;
    final draftCount = items.where((t) => t.status == TransactionStatus.draft).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Offline Queue'),
        automaticallyImplyLeading: false,
        actions: [
          // Toggle offline mode for demo
          IconButton(
            icon: Icon(_isOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded),
            onPressed: () => setState(() => _isOffline = !_isOffline),
            tooltip: 'Toggle offline (demo)',
          ),
          if (items.isNotEmpty)
            TextButton(
              onPressed: _retryAll,
              child: const Text('Retry All', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Offline banner
          if (_isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.error.withValues(alpha: 0.12),
              child: Row(children: [
                const Icon(Icons.wifi_off_rounded, color: AppColors.error, size: 18),
                const SizedBox(width: 10),
                const Expanded(child: Text('No internet connection — captured data will sync when online', style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600))),
              ]),
            ),
          // Summary chips
          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(children: [
                if (pendingCount > 0) _SummaryChip(label: '$pendingCount Pending', color: AppColors.pending),
                if (failedCount > 0) ...[const SizedBox(width: 8), _SummaryChip(label: '$failedCount Failed', color: AppColors.error)],
                if (draftCount > 0) ...[const SizedBox(width: 8), _SummaryChip(label: '$draftCount Draft', color: AppColors.draft)],
              ]),
            ),
          // List
          Expanded(
            child: items.isEmpty
                ? EmptyState(
                    icon: Icons.cloud_done_rounded,
                    title: 'Queue is clear',
                    subtitle: 'All transactions are synced. No pending items.',
                    action: TextButton.icon(
                      onPressed: () => context.go('/home'),
                      icon: const Icon(Icons.home_rounded, size: 18),
                      label: const Text('Go to Dashboard'),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppConstants.pagePadding),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _QueueItem(
                      transaction: items[i],
                      onRetry: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Retrying ${items[i].categoryName}…'), behavior: SnackBarBehavior.floating),
                        );
                      },
                      onDiscard: items[i].status == TransactionStatus.draft ? () => _discardDraft(items[i]) : null,
                      onTap: () => context.push('/transaction/${items[i].id}'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final Color color;
  const _SummaryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
    );
  }
}

class _QueueItem extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback onRetry;
  final VoidCallback? onDiscard;
  final VoidCallback onTap;
  const _QueueItem({required this.transaction, required this.onRetry, this.onDiscard, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currFmt = NumberFormat('#,##0', 'en_US');
    final dateFmt = DateFormat(AppConstants.dateDisplayFormat);
    final tx = transaction;
    final isFailed = tx.status == TransactionStatus.failedSync;
    final isDraft = tx.status == TransactionStatus.draft;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
        border: Border.all(
          color: isFailed ? AppColors.error.withValues(alpha: 0.3) : AppColors.border.withValues(alpha: 0.5),
          width: isFailed ? 1.5 : 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                _TypeIconSmall(type: tx.type),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(tx.categoryName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text(tx.offenderName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                ),
                StatusChip(status: tx.status, small: true),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Text('MWK ${currFmt.format(tx.amount)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(width: 8),
                const Text('·', style: TextStyle(color: AppColors.textTertiary)),
                const SizedBox(width: 8),
                Text(dateFmt.format(tx.issuedAt), style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
              ]),
              if (isFailed) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.overdueLight, borderRadius: BorderRadius.circular(8)),
                  child: const Row(children: [
                    Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
                    SizedBox(width: 8),
                    Expanded(child: Text('Sync failed. Check connection and retry.', style: TextStyle(fontSize: 11, color: AppColors.error))),
                  ]),
                ),
              ],
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.sync_rounded, size: 16),
                    label: const Text('Retry Sync', style: TextStyle(fontSize: 12)),
                  ),
                ),
                if (onDiscard != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: onDiscard,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Discard', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeIconSmall extends StatelessWidget {
  final TransactionType type;
  const _TypeIconSmall({required this.type});

  @override
  Widget build(BuildContext context) {
    final isOffense = type == TransactionType.trafficOffense;
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: isOffense ? AppColors.unpaidLight : AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(isOffense ? Icons.traffic_rounded : Icons.receipt_long_rounded, color: isOffense ? AppColors.unpaid : AppColors.secondary, size: 18),
    );
  }
}

