import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/widgets/app_widgets.dart';
import '../../../../core/ui/widgets/status_chip.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionDetailPage extends StatefulWidget {
  final String transactionId;
  const TransactionDetailPage({super.key, required this.transactionId});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  bool _isVoiding = false;
  bool _isPrinting = false;

  TransactionEntity? get _transaction =>
      MockData.transactions.where((t) => t.id == widget.transactionId).firstOrNull;

  Future<void> _showVoidDialog(TransactionEntity tx) async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _VoidDialog(transaction: tx, reasonCtrl: reasonCtrl),
    );

    if (confirmed == true && reasonCtrl.text.trim().isNotEmpty) {
      setState(() => _isVoiding = true);
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() => _isVoiding = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PRN voided successfully.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
    reasonCtrl.dispose();
  }

  Future<void> _printReceipt(TransactionEntity tx) async {
    setState(() => _isPrinting = true);
    // Simulate print job delay (replace with actual print plugin call)
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isPrinting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text('Receipt for ${tx.prn ?? 'PRN'} sent to printer.')),
        ]),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tx = _transaction;
    if (tx == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction Detail')),
        body: const Center(child: Text('Transaction not found.')),
      );
    }

    final fmt = DateFormat(AppConstants.dateDisplayFormat);
    final dtFmt = DateFormat(AppConstants.dateTimeDisplayFormat);
    final currFmt = NumberFormat('#,##0', 'en_US');
    final isOffense = tx.type == TransactionType.trafficOffense;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaction Detail'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        actions: [
          IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PrnHeaderCard(tx: tx, currFmt: currFmt, dateFmt: fmt),
                  const SizedBox(height: 16),
                  _StatusTimeline(tx: tx, dtFmt: dtFmt),
                  const SizedBox(height: 16),
                  _DetailSection(
                    title: isOffense ? 'OFFENDER & VEHICLE' : 'CITIZEN',
                    rows: [
                      InfoRow(label: 'Name', value: tx.offenderName),
                      if (tx.vehicleReg != null) InfoRow(label: 'Vehicle Reg.', value: tx.vehicleReg!),
                      if (tx.maltisRef != null) InfoRow(label: 'MALTIS Ref.', value: tx.maltisRef!),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DetailSection(
                    title: isOffense ? 'OFFENSE' : 'SERVICE',
                    rows: [
                      InfoRow(label: 'Category', value: tx.categoryName, valueFontWeight: FontWeight.w700),
                      InfoRow(label: 'Code', value: tx.categoryCode),
                      InfoRow(label: 'Amount', value: 'MWK ${currFmt.format(tx.amount)}', valueColor: AppColors.primary, valueFontWeight: FontWeight.w800),
                      if (tx.deadline != null)
                        InfoRow(label: 'Payment Deadline', value: fmt.format(tx.deadline!), valueColor: _deadlineColor(tx)),
                      if (tx.paidAt != null)
                        InfoRow(label: 'Paid On', value: fmt.format(tx.paidAt!), valueColor: AppColors.paid, valueFontWeight: FontWeight.w700),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DetailSection(
                    title: 'OFFICER & STATION',
                    rows: [
                      InfoRow(label: 'Officer', value: tx.officerName),
                      InfoRow(label: 'Officer ID', value: tx.officerId),
                      InfoRow(label: 'Station', value: tx.stationName),
                      InfoRow(label: 'Device ID', value: tx.deviceId),
                      InfoRow(label: 'Issued At', value: dtFmt.format(tx.issuedAt)),
                    ],
                  ),
                  if (tx.status == TransactionStatus.voided) ...[
                    const SizedBox(height: 12),
                    _VoidInfoCard(tx: tx, dtFmt: dtFmt),
                  ],
                  const SizedBox(height: 12),
                  _PaymentChannelsCard(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          if (tx.status == TransactionStatus.paid)
            _PrintReceiptBottomBar(isPrinting: _isPrinting, onPrint: () => _printReceipt(tx)),
          if (tx.canBeVoided)
            _VoidBottomBar(isVoiding: _isVoiding, onVoid: () => _showVoidDialog(tx)),
        ],
      ),
    );
  }

  Color _deadlineColor(TransactionEntity tx) {
    if (tx.status == TransactionStatus.overdue) return AppColors.overdue;
    if (tx.isNearingDeadline) return AppColors.warning;
    return AppColors.textPrimary;
  }
}

// ─── PRN Header Card ─────────────────────────────────────────────────────────

class _PrnHeaderCard extends StatelessWidget {
  final TransactionEntity tx;
  final NumberFormat currFmt;
  final DateFormat dateFmt;
  const _PrnHeaderCard({required this.tx, required this.currFmt, required this.dateFmt});

  @override
  Widget build(BuildContext context) {
    final isOffense = tx.type == TransactionType.trafficOffense;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.elevatedShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Icon(isOffense ? Icons.traffic_rounded : Icons.receipt_long_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(isOffense ? 'Traffic Offense' : 'Service Fee', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const Spacer(),
              StatusChip(status: tx.status),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Payment Reference Number (PRN)', style: TextStyle(color: Colors.white60, fontSize: 11, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          if (tx.prn != null)
            Row(
              children: [
                Expanded(child: Text(tx.prn!, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.8))),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: tx.prn!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PRN copied'), duration: Duration(seconds: 2), behavior: SnackBarBehavior.floating),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(7)),
                    child: const Icon(Icons.copy_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ],
            )
          else
            const Text('(No PRN – Draft)', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 14),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Fine / Fee Amount', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text('MWK ${currFmt.format(tx.amount)}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                ]),
              ),
              if (tx.deadline != null)
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text('Pay By', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(dateFmt.format(tx.deadline!), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                ]),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Status Timeline ──────────────────────────────────────────────────────────

class _StatusTimeline extends StatelessWidget {
  final TransactionEntity tx;
  final DateFormat dtFmt;
  const _StatusTimeline({required this.tx, required this.dtFmt});

  List<_TimelineEvent> _buildEvents() {
    final events = <_TimelineEvent>[
      _TimelineEvent(
        icon: Icons.add_circle_outline_rounded,
        label: 'Issued',
        sublabel: dtFmt.format(tx.issuedAt),
        color: AppColors.primary,
        done: true,
      ),
    ];

    if (tx.status == TransactionStatus.paid && tx.paidAt != null) {
      events.add(_TimelineEvent(icon: Icons.check_circle_rounded, label: 'Paid', sublabel: dtFmt.format(tx.paidAt!), color: AppColors.paid, done: true));
    } else if (tx.status == TransactionStatus.voided && tx.voidedAt != null) {
      events.add(_TimelineEvent(icon: Icons.cancel_rounded, label: 'Voided', sublabel: tx.voidedAt != null ? dtFmt.format(tx.voidedAt!) : null, color: AppColors.voided, done: true));
    } else if (tx.status == TransactionStatus.overdue) {
      events.add(_TimelineEvent(icon: Icons.warning_rounded, label: 'Overdue', sublabel: 'Payment deadline passed', color: AppColors.overdue, done: true));
    } else if (tx.status == TransactionStatus.issuedUnpaid) {
      events.add(_TimelineEvent(icon: Icons.hourglass_empty_rounded, label: 'Awaiting Payment', sublabel: 'Pending', color: AppColors.unpaid, done: false));
    } else if (tx.status == TransactionStatus.pendingSync) {
      events.add(_TimelineEvent(icon: Icons.sync_rounded, label: 'Pending Sync', sublabel: 'Will sync when online', color: AppColors.pending, done: false));
    }
    return events;
  }

  @override
  Widget build(BuildContext context) {
    final events = _buildEvents();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), boxShadow: AppColors.cardShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('STATUS TIMELINE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 1.2)),
          const SizedBox(height: 14),
          ...List.generate(events.length, (i) {
            final e = events[i];
            final isLast = i == events.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: e.done ? e.color.withValues(alpha: 0.15) : AppColors.surfaceVariant, shape: BoxShape.circle),
                      child: Icon(e.icon, color: e.done ? e.color : AppColors.textTertiary, size: 17),
                    ),
                    if (!isLast) Container(width: 2, height: 28, color: AppColors.border),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(e.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: e.done ? AppColors.textPrimary : AppColors.textTertiary)),
                        if (e.sublabel != null) Text(e.sublabel!, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineEvent {
  final IconData icon;
  final String label;
  final String? sublabel;
  final Color color;
  final bool done;
  const _TimelineEvent({required this.icon, required this.label, this.sublabel, required this.color, required this.done});
}

// ─── Detail Section ───────────────────────────────────────────────────────────

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  const _DetailSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), boxShadow: AppColors.cardShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }
}

// ─── Void Info Card ───────────────────────────────────────────────────────────

class _VoidInfoCard extends StatelessWidget {
  final TransactionEntity tx;
  final DateFormat dtFmt;
  const _VoidInfoCard({required this.tx, required this.dtFmt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.voidedLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.voided.withValues(alpha: 0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.cancel_rounded, color: AppColors.voided, size: 18),
            const SizedBox(width: 8),
            const Text('VOID INFORMATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.voided, letterSpacing: 1.2)),
          ]),
          const SizedBox(height: 10),
          if (tx.voidReason != null) InfoRow(label: 'Reason', value: tx.voidReason!),
          if (tx.voidedBy != null) InfoRow(label: 'Voided By', value: tx.voidedBy!),
          if (tx.voidedAt != null) InfoRow(label: 'Voided At', value: dtFmt.format(tx.voidedAt!)),
        ],
      ),
    );
  }
}

// ─── Payment Channels Card ────────────────────────────────────────────────────

class _PaymentChannelsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), boxShadow: AppColors.cardShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PAYMENT CHANNELS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 6,
            children: AppConstants.paymentChannels.map((ch) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
              child: Text(ch, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Print Receipt Bottom Bar ─────────────────────────────────────────────────

class _PrintReceiptBottomBar extends StatelessWidget {
  final bool isPrinting;
  final VoidCallback onPrint;
  const _PrintReceiptBottomBar({required this.isPrinting, required this.onPrint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(color: AppColors.surface, boxShadow: AppColors.elevatedShadow),
      child: ElevatedButton.icon(
        onPressed: isPrinting ? null : onPrint,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: isPrinting
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.print_rounded, size: 20),
        label: Text(isPrinting ? 'Printing Receipt…' : 'Print Receipt'),
      ),
    );
  }
}

// ─── Void Bottom Bar ──────────────────────────────────────────────────────────

class _VoidBottomBar extends StatelessWidget {
  final bool isVoiding;
  final VoidCallback onVoid;
  const _VoidBottomBar({required this.isVoiding, required this.onVoid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(color: AppColors.surface, boxShadow: AppColors.elevatedShadow),
      child: OutlinedButton.icon(
        onPressed: isVoiding ? null : onVoid,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: isVoiding
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error))
            : const Icon(Icons.cancel_outlined, size: 20),
        label: Text(isVoiding ? 'Voiding PRN…' : 'Void This PRN'),
      ),
    );
  }
}

// ─── Void Confirmation Dialog ─────────────────────────────────────────────────

class _VoidDialog extends StatefulWidget {
  final TransactionEntity transaction;
  final TextEditingController reasonCtrl;
  const _VoidDialog({required this.transaction, required this.reasonCtrl});

  @override
  State<_VoidDialog> createState() => _VoidDialogState();
}

class _VoidDialogState extends State<_VoidDialog> {
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.overdueLight, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Text('Void PRN', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
      ]),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.overdueLight, borderRadius: BorderRadius.circular(8)),
            child: Text(
              'This action will void PRN ${widget.transaction.prn ?? ''}. This cannot be undone.',
              style: const TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Reason for voiding *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          TextField(
            controller: widget.reasonCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Describe why this PRN is being voided...',
              hintStyle: const TextStyle(fontSize: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              contentPadding: const EdgeInsets.all(12),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => setState(() => _confirmed = !_confirmed),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color: _confirmed ? AppColors.error : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: _confirmed ? AppColors.error : AppColors.border, width: 2),
                ),
                child: _confirmed ? const Icon(Icons.check_rounded, color: Colors.white, size: 13) : null,
              ),
              const SizedBox(width: 10),
              const Expanded(child: Text('I confirm I have supervisor authority to void this PRN.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
            ]),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: (_confirmed && widget.reasonCtrl.text.trim().isNotEmpty) ? () => Navigator.of(context).pop(true) : null,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, minimumSize: const Size(100, 44)),
          child: const Text('Void PRN'),
        ),
      ],
    );
  }
}


