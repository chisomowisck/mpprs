import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/widgets/app_widgets.dart';

class PrnIssuedPage extends StatelessWidget {
  final Map<String, dynamic> data;
  const PrnIssuedPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat(AppConstants.dateDisplayFormat);
    final dtFmt = DateFormat(AppConstants.dateTimeDisplayFormat);
    final currFmt = NumberFormat('#,##0', 'en_US');

    final prn = data['prn'] as String;
    final amount = (data['amount'] as double?) ?? 0.0;
    final deadline = data['deadline'] as DateTime;
    final officerName = data['officerName'] as String? ?? '';
    final stationName = data['stationName'] as String? ?? '';
    final offenderName = data['offenderName'] as String? ?? '';
    final vehicleReg = data['vehicleReg'] as String? ?? '';
    final categoryName = data['categoryName'] as String? ?? '';
    final maltisRef = data['maltisRef'] as String? ?? '';
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PRN Issued'),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => context.go('/home')),
        actions: [
          IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Success banner
          Container(
            color: AppColors.paidLight,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.paid, size: 22),
              const SizedBox(width: 10),
              const Expanded(child: Text('PRN issued successfully. Receipt ready.', style: TextStyle(color: AppColors.paid, fontWeight: FontWeight.w600, fontSize: 13))),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.pagePadding),
              child: Column(
                children: [
                  // PRN highlighted
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(children: [
                      const Text('Payment Reference Number (PRN)', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 0.5)),
                      const SizedBox(height: 10),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Flexible(child: Text(prn, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 1), textAlign: TextAlign.center)),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: prn));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PRN copied to clipboard'), duration: Duration(seconds: 2)));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Column(children: [
                          const Text('Fine Amount', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          Text('MWK ${currFmt.format(amount)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                        ]),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          const Text('Pay By', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          Text(fmt.format(deadline), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                        ]),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  // Receipt card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppColors.cardShadow,
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Receipt header
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            const Text('Official Receipt', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                            const Spacer(),
                            Text(dtFmt.format(now), style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                               InfoRow(label: 'Offender', value: offenderName),
                              if (vehicleReg.isNotEmpty) InfoRow(label: 'Vehicle Reg.', value: vehicleReg),
                              const Divider(height: 16),
                              if (data['categories'] != null && (data['categories'] as List).length > 1) ...[
                                const Text('DETAILS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 1)),
                                const SizedBox(height: 8),
                                ...(data['categories'] as List).asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final cat = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Text('${i + 1}. ${cat.name}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                                        Text('MWK ${currFmt.format(cat.defaultAmount)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                      ],
                                    ),
                                  );
                                }),
                              ] else ...[
                                InfoRow(label: data['isTrafficOffense'] == false ? 'Service' : 'Offense', value: categoryName, valueFontWeight: FontWeight.w700),
                              ],
                              if (maltisRef.isNotEmpty) InfoRow(label: 'MALTIS Ref.', value: maltisRef),
                              const Divider(height: 16),
                              InfoRow(label: 'TOTAL AMOUNT', value: 'MWK ${currFmt.format(amount)}', valueColor: AppColors.primary, valueFontWeight: FontWeight.w800),
                              InfoRow(label: 'Payment Deadline', value: fmt.format(deadline), valueColor: AppColors.warning, valueFontWeight: FontWeight.w700),
                              const Divider(height: 16),
                              InfoRow(label: 'Officer', value: officerName),
                              InfoRow(label: 'Station', value: stationName),
                            ],
                          ),
                        ),
                        // Payment channels
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('PAYMENT CHANNELS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 1)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8, runSpacing: 6,
                              children: AppConstants.paymentChannels.map((ch) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
                                child: Text(ch, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              )).toList(),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom actions
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(color: AppColors.surface, boxShadow: AppColors.elevatedShadow),
            child: Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.print_rounded, size: 18), label: const Text('Print'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(onPressed: () => context.go('/home'), icon: const Icon(Icons.home_rounded, size: 18), label: const Text('Done'))),
            ]),
          ),
        ],
      ),
    );
  }
}

