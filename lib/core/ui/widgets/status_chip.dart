import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../../features/transactions/domain/entities/transaction_entity.dart';

class StatusChip extends StatelessWidget {
  final TransactionStatus status;
  final bool small;

  const StatusChip({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);
    final fontSize = small ? 10.0 : 11.5;
    final hPad = small ? 6.0 : 10.0;
    final vPad = small ? 2.0 : 4.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: config.foreground, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: config.foreground,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  _ChipConfig _getConfig(TransactionStatus s) {
    switch (s) {
      case TransactionStatus.paid:
        return _ChipConfig(AppColors.paidLight, AppColors.paid);
      case TransactionStatus.issuedUnpaid:
        return _ChipConfig(AppColors.unpaidLight, AppColors.unpaid);
      case TransactionStatus.overdue:
        return _ChipConfig(AppColors.overdueLight, AppColors.overdue);
      case TransactionStatus.voided:
        return _ChipConfig(AppColors.voidedLight, AppColors.voided);
      case TransactionStatus.pendingSync:
        return _ChipConfig(AppColors.pendingLight, AppColors.pending);
      case TransactionStatus.failedSync:
        return _ChipConfig(AppColors.overdueLight, AppColors.error);
      case TransactionStatus.draft:
        return _ChipConfig(AppColors.draftLight, AppColors.draft);
      case TransactionStatus.error:
        return _ChipConfig(AppColors.overdueLight, AppColors.error);
    }
  }
}

class _ChipConfig {
  final Color background;
  final Color foreground;
  const _ChipConfig(this.background, this.foreground);
}

