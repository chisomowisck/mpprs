import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../../features/transactions/domain/entities/transaction_entity.dart';
import 'status_chip.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback? onTap;

  const TransactionListItem({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0', 'en_US');
    final dateFormat = DateFormat('dd MMM yyyy');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColors.cardShadow,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 0.5),
        ),
        child: Row(
          children: [
            _TypeIcon(type: transaction.type),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          transaction.prn ?? 'Draft – ${transaction.categoryName}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusChip(status: transaction.status, small: true),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${transaction.offenderName}${transaction.vehicleReg != null ? ' · ${transaction.vehicleReg}' : ''}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'MWK ${currencyFormat.format(transaction.amount)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dateFormat.format(transaction.issuedAt),
                    style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  final TransactionType type;
  const _TypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final isOffense = type == TransactionType.trafficOffense;
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isOffense ? AppColors.unpaidLight : AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        isOffense ? Icons.traffic_rounded : Icons.receipt_long_rounded,
        color: isOffense ? AppColors.unpaid : AppColors.secondary,
        size: 20,
      ),
    );
  }
}

