import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/widgets/app_widgets.dart';

class ReviewConfirmPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const ReviewConfirmPage({super.key, required this.data});

  @override
  State<ReviewConfirmPage> createState() => _ReviewConfirmPageState();
}

class _ReviewConfirmPageState extends State<ReviewConfirmPage> {
  bool _isIssuing = false;
  bool _confirmed = false;

  Future<void> _issuePrn() async {
    if (!_confirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please confirm the details are correct.'), backgroundColor: AppColors.warning),
      );
      return;
    }
    setState(() => _isIssuing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final category = widget.data['category'];
    final amount = category?.defaultAmount ?? 0.0;
    final deadline = (widget.data['offenseDate'] as DateTime).add(const Duration(days: AppConstants.trafficFineDeadlineDays));

    context.pushReplacement('/offense/prn-issued', extra: {
      // 'prn': 'MPPRS-${DateTime.now().year}-${(100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString()}',
      'prn': '2535001005566',
      'vehicleReg': widget.data['vehicleReg'],
      'offenderName': widget.data['offenderName'],
      'categoryName': category?.name ?? '',
      'categoryCode': category?.code ?? '',
      'amount': amount,
      'deadline': deadline,
      'offenseDate': widget.data['offenseDate'],
      'location': widget.data['location'] ?? '',
      'maltisRef': widget.data['maltisRef'] ?? '',
      'officerName': 'Sgt. Samuel Phiri',
      'stationName': 'Lilongwe Central Police Station',
      'isTrafficOffense': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat(AppConstants.dateDisplayFormat);
    final currFmt = NumberFormat('#,##0', 'en_US');
    final category = widget.data['category'];
    final amount = category?.defaultAmount ?? 0.0;
    final offenseDate = widget.data['offenseDate'] as DateTime;
    final deadline = offenseDate.add(const Duration(days: AppConstants.trafficFineDeadlineDays));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Review & Confirm'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header warning
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.secondaryLight, borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(child: Text('Review all details carefully. A PRN once issued is final and cannot be edited.', style: TextStyle(fontSize: 12, color: AppColors.warning))),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  _ReviewSection(title: 'VEHICLE', children: [
                    InfoRow(label: 'Registration', value: widget.data['vehicleReg'] ?? '—'),
                    if ((widget.data['chassis'] as String?)?.isNotEmpty == true)
                      InfoRow(label: 'Chassis No.', value: widget.data['chassis']),
                  ]),
                  const SizedBox(height: 12),
                  _ReviewSection(title: 'OFFENDER', children: [
                    InfoRow(label: 'Name', value: widget.data['offenderName'] ?? '—'),
                    if ((widget.data['phone'] as String?)?.isNotEmpty == true)
                      InfoRow(label: 'Phone', value: widget.data['phone']),
                    if ((widget.data['license'] as String?)?.isNotEmpty == true)
                      InfoRow(label: 'Licence No.', value: widget.data['license']),
                  ]),
                  const SizedBox(height: 12),
                  _ReviewSection(title: 'OFFENSE', children: [
                    InfoRow(label: 'Category', value: category?.name ?? '—', valueFontWeight: FontWeight.w700),
                    InfoRow(label: 'Code', value: category?.code ?? '—'),
                    InfoRow(label: 'Revenue Code', value: category?.revenueCode ?? '—'),
                    InfoRow(label: 'Offense Date', value: fmt.format(offenseDate)),
                    if ((widget.data['location'] as String?)?.isNotEmpty == true)
                      InfoRow(label: 'Location', value: widget.data['location']),
                    if ((widget.data['maltisRef'] as String?)?.isNotEmpty == true)
                      InfoRow(label: 'MALTIS Ref.', value: widget.data['maltisRef']),
                  ]),
                  const SizedBox(height: 16),
                  // Amount + deadline highlight
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Fine Amount', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('MWK ${currFmt.format(amount)}', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                        ]),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.payments_rounded, color: Colors.white, size: 28),
                        ),
                      ]),
                      const Divider(color: Colors.white24, height: 24),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Payment Deadline', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(fmt.format(deadline), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                      ]),
                      const SizedBox(height: 4),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Payment Window', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const Text('21 days', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  // Confirmation checkbox
                  GestureDetector(
                    onTap: () => setState(() => _confirmed = !_confirmed),
                    child: Row(children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          color: _confirmed ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: _confirmed ? AppColors.primary : AppColors.border, width: 2),
                        ),
                        child: _confirmed ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('I confirm that the above details have been verified and are correct.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                    ]),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(color: AppColors.surface, boxShadow: AppColors.elevatedShadow),
            child: PrimaryButton(label: 'Issue PRN', isLoading: _isIssuing, icon: Icons.receipt_long_rounded, onPressed: _issuePrn),
          ),
        ],
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _ReviewSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), boxShadow: AppColors.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 1.2)),
        const SizedBox(height: 10),
        ...children,
      ]),
    );
  }
}

