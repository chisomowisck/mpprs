import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/widgets/app_widgets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../offense/domain/entities/offense_category.dart';
import 'category_picker_page.dart';

class NewTrafficOffensePage extends StatefulWidget {
  const NewTrafficOffensePage({super.key});
  @override
  State<NewTrafficOffensePage> createState() => _NewTrafficOffensePageState();
}

class _NewTrafficOffensePageState extends State<NewTrafficOffensePage> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0;

  // Vehicle
  final _regCtrl = TextEditingController();
  final _chassisCtrl = TextEditingController();

  // Offender
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();

  // Offense — now supports multiple categories
  List<OffenseCategory> _categories = [];
  DateTime _offenseDate = DateTime.now();
  final _maltisCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  final _steps = ['Vehicle', 'Offender', 'Offense', 'Review'];

  @override
  void dispose() {
    for (final c in [_regCtrl, _chassisCtrl, _nameCtrl, _phoneCtrl, _licenseCtrl, _maltisCtrl, _locationCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickCategories() async {
    final result = await Navigator.of(context).push<List<OffenseCategory>>(
      MaterialPageRoute(
        builder: (_) => CategoryPickerPage(
          multiSelect: true,
          selectedCategories: _categories,
        ),
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _categories = result);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _offenseDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _offenseDate = picked);
  }

  bool _validateStep() {
    if (_step == 0) return _regCtrl.text.trim().isNotEmpty;
    if (_step == 1) return _nameCtrl.text.trim().isNotEmpty;
    if (_step == 2) return _categories.isNotEmpty;
    return true;
  }

  void _next() {
    if (!_validateStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete required fields.'), backgroundColor: AppColors.error),
      );
      return;
    }
    if (_step < 3) setState(() => _step++);
    else _submit();
  }

  void _submit() {
    context.push('/offense/review', extra: {
      'vehicleReg': _regCtrl.text.trim().toUpperCase(),
      'chassis': _chassisCtrl.text.trim(),
      'offenderName': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'license': _licenseCtrl.text.trim(),
      'categories': _categories,
      // Keep 'category' for backward compat with review/confirm page
      'category': _categories.isNotEmpty ? _categories.first : null,
      'offenseDate': _offenseDate,
      'maltisRef': _maltisCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Traffic Offense'),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => context.pop()),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Save Draft', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ),
        ],
      ),
      body: Column(
        children: [
          _StepIndicator(currentStep: _step, steps: _steps),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.pagePadding),
              child: Form(
                key: _formKey,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildCurrentStep(),
                ),
              ),
            ),
          ),
          _BottomActions(
            step: _step,
            totalSteps: _steps.length,
            onBack: _step > 0 ? () => setState(() => _step--) : null,
            onNext: _next,
            isLastStep: _step == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _VehicleStep(regCtrl: _regCtrl, chassisCtrl: _chassisCtrl);
      case 1:
        return _OffenderStep(nameCtrl: _nameCtrl, phoneCtrl: _phoneCtrl, licenseCtrl: _licenseCtrl);
      case 2:
        return _OffenseStep(
          categories: _categories,
          offenseDate: _offenseDate,
          maltisCtrl: _maltisCtrl,
          locationCtrl: _locationCtrl,
          onPickCategories: _pickCategories,
          onPickDate: _pickDate,
          onRemoveCategory: (cat) => setState(() => _categories.remove(cat)),
        );
      case 3:
        return _ReviewStep(
          vehicleReg: _regCtrl.text.toUpperCase(),
          offenderName: _nameCtrl.text,
          categories: _categories,
          offenseDate: _offenseDate,
          location: _locationCtrl.text,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  const _StepIndicator({required this.currentStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(child: Container(height: 2, color: i ~/ 2 < currentStep ? AppColors.primary : AppColors.border));
          }
          final idx = i ~/ 2;
          final done = idx < currentStep;
          final active = idx == currentStep;
          return Column(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: done || active ? AppColors.primary : AppColors.border,
                  shape: BoxShape.circle,
                ),
                child: done
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                    : Center(child: Text('${idx + 1}', style: TextStyle(color: done || active ? Colors.white : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(height: 4),
              Text(steps[idx], style: TextStyle(fontSize: 9, color: active ? AppColors.primary : AppColors.textTertiary, fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
            ],
          );
        }),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final int step, totalSteps;
  final VoidCallback? onBack, onNext;
  final bool isLastStep;
  const _BottomActions({required this.step, required this.totalSteps, this.onBack, required this.onNext, required this.isLastStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(color: AppColors.surface, boxShadow: AppColors.elevatedShadow),
      child: Row(
        children: [
          if (onBack != null) ...[
            SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(minimumSize: const Size(52, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: onNext,
              child: Text(isLastStep ? 'Review & Issue PRN' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleStep extends StatelessWidget {
  final TextEditingController regCtrl, chassisCtrl;
  const _VehicleStep({required this.regCtrl, required this.chassisCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(key: const ValueKey('vehicle'), crossAxisAlignment: CrossAxisAlignment.start, children: [
      _StepHeader(icon: Icons.directions_car_rounded, title: 'Vehicle Details', subtitle: 'Enter the vehicle registration information'),
      const SizedBox(height: 20),
      TextFormField(
        controller: regCtrl,
        textCapitalization: TextCapitalization.characters,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]'))],
        decoration: const InputDecoration(labelText: 'Registration Number *', prefixIcon: Icon(Icons.confirmation_number_rounded)),
        onChanged: (v) => regCtrl.value = regCtrl.value.copyWith(text: v.toUpperCase(), selection: TextSelection.collapsed(offset: v.length)),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: chassisCtrl,
        decoration: const InputDecoration(labelText: 'Chassis Number (optional)', prefixIcon: Icon(Icons.qr_code_rounded)),
      ),
    ]);
  }
}

class _OffenderStep extends StatelessWidget {
  final TextEditingController nameCtrl, phoneCtrl, licenseCtrl;
  const _OffenderStep({required this.nameCtrl, required this.phoneCtrl, required this.licenseCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(key: const ValueKey('offender'), crossAxisAlignment: CrossAxisAlignment.start, children: [
      _StepHeader(icon: Icons.person_rounded, title: 'Offender Details', subtitle: 'Capture the driver or offender information'),
      const SizedBox(height: 20),
      TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person_outline_rounded)), textCapitalization: TextCapitalization.words),
      const SizedBox(height: 16),
      TextFormField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number (optional)', prefixIcon: Icon(Icons.phone_outlined))),
      const SizedBox(height: 16),
      TextFormField(controller: licenseCtrl, decoration: const InputDecoration(labelText: 'Driver\'s Licence Number', prefixIcon: Icon(Icons.credit_card_rounded))),
    ]);
  }
}

class _OffenseStep extends StatelessWidget {
  final List<OffenseCategory> categories;
  final DateTime offenseDate;
  final TextEditingController maltisCtrl, locationCtrl;
  final VoidCallback onPickCategories, onPickDate;
  final void Function(OffenseCategory) onRemoveCategory;

  const _OffenseStep({
    required this.categories,
    required this.offenseDate,
    required this.maltisCtrl,
    required this.locationCtrl,
    required this.onPickCategories,
    required this.onPickDate,
    required this.onRemoveCategory,
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat(AppConstants.dateDisplayFormat);
    final currFmt = NumberFormat('#,##0', 'en_US');
    final totalAmount = categories.fold<double>(0, (sum, c) => sum + c.defaultAmount);

    return Column(key: const ValueKey('offense'), crossAxisAlignment: CrossAxisAlignment.start, children: [
      _StepHeader(icon: Icons.traffic_rounded, title: 'Offense Details', subtitle: 'Select one or more offense categories'),
      const SizedBox(height: 20),

      // ── Offense category picker button ──────────────────────────────
      GestureDetector(
        onTap: onPickCategories,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: categories.isNotEmpty ? AppColors.primary : AppColors.border,
              width: categories.isNotEmpty ? 1.5 : 1,
            ),
          ),
          child: Row(children: [
            const Icon(Icons.traffic_rounded, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: categories.isEmpty
                  ? const Text('Select Offense Categories *', style: TextStyle(color: AppColors.textTertiary, fontSize: 14))
                  : Text(
                      '${categories.length} offense${categories.length == 1 ? '' : 's'} selected',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary),
                    ),
            ),
            Text(
              categories.isEmpty ? 'Add' : 'Edit',
              style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
          ]),
        ),
      ),

      // ── Selected offenses chips ───────────────────────────────────
      if (categories.isNotEmpty) ...[
        const SizedBox(height: 12),
        ...categories.map((cat) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.unpaidLight, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.traffic_rounded, size: 16, color: AppColors.unpaid),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cat.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Text('${cat.code}  ·  MWK ${currFmt.format(cat.defaultAmount)}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ])),
            GestureDetector(
              onTap: () => onRemoveCategory(cat),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.close_rounded, color: AppColors.error, size: 16),
              ),
            ),
          ]),
        )),

        // Total fine amount
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.paidLight, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const Icon(Icons.payments_rounded, color: AppColors.paid, size: 20),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                categories.length == 1 ? 'Fine Amount' : 'Total Fine (${categories.length} offenses)',
                style: const TextStyle(fontSize: 11, color: AppColors.paid),
              ),
              Text('MWK ${currFmt.format(totalAmount)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.paid)),
            ]),
          ]),
        ),
      ],

      const SizedBox(height: 16),
      // Date picker
      GestureDetector(
        onTap: onPickDate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
          child: Row(children: [
            const Icon(Icons.calendar_today_rounded, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Text('Offense Date: ${dateFmt.format(offenseDate)}', style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
            const Spacer(),
            const Icon(Icons.edit_calendar_rounded, color: AppColors.textTertiary, size: 18),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Location / Road', prefixIcon: Icon(Icons.location_on_outlined))),
      const SizedBox(height: 16),
      TextFormField(controller: maltisCtrl, decoration: const InputDecoration(labelText: 'MALTIS Reference (optional)', prefixIcon: Icon(Icons.link_rounded))),
    ]);
  }
}

class _ReviewStep extends StatelessWidget {
  final String vehicleReg, offenderName;
  final List<OffenseCategory> categories;
  final DateTime offenseDate;
  final String location;

  const _ReviewStep({
    required this.vehicleReg,
    required this.offenderName,
    required this.categories,
    required this.offenseDate,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat(AppConstants.dateDisplayFormat);
    final currFmt = NumberFormat('#,##0', 'en_US');
    final deadline = offenseDate.add(const Duration(days: AppConstants.trafficFineDeadlineDays));
    final totalAmount = categories.fold<double>(0, (sum, c) => sum + c.defaultAmount);

    return Column(key: const ValueKey('review'), crossAxisAlignment: CrossAxisAlignment.start, children: [
      _StepHeader(icon: Icons.fact_check_rounded, title: 'Review & Confirm', subtitle: 'Verify all details before issuing the PRN'),
      const SizedBox(height: 20),
      _SummarySection(title: 'Vehicle', rows: [InfoRow(label: 'Registration', value: vehicleReg)]),
      const SizedBox(height: 12),
      _SummarySection(title: 'Offender', rows: [InfoRow(label: 'Full Name', value: offenderName)]),
      const SizedBox(height: 12),
      _SummarySection(
        title: 'Offense${categories.length > 1 ? 's (${categories.length})' : ''}',
        rows: [
          ...categories.asMap().entries.map((entry) {
            final i = entry.key;
            final cat = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (categories.length > 1) ...[
                  if (i > 0) const Divider(height: 12),
                  Text('Offense ${i + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
                  const SizedBox(height: 4),
                ],
                InfoRow(label: 'Category', value: cat.name),
                InfoRow(label: 'Code', value: cat.code),
                InfoRow(label: 'Revenue Code', value: cat.revenueCode),
                InfoRow(label: 'Fine', value: 'MWK ${currFmt.format(cat.defaultAmount)}'),
              ],
            );
          }),
          if (categories.length > 1) ...[
            const Divider(height: 12),
            InfoRow(label: 'Total Fine', value: 'MWK ${currFmt.format(totalAmount)}', valueFontWeight: FontWeight.w800, valueColor: AppColors.primary),
          ],
          InfoRow(label: 'Offense Date', value: dateFmt.format(offenseDate)),
          if (location.isNotEmpty) InfoRow(label: 'Location', value: location),
        ],
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              categories.length > 1 ? 'Total Fine Amount' : 'Fine Amount',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            Text('MWK ${currFmt.format(totalAmount)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Payment Deadline', style: TextStyle(color: Colors.white70, fontSize: 13)),
            Text(dateFmt.format(deadline), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
        ]),
      ),
    ]);
  }
}

class _SummarySection extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  const _SummarySection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), boxShadow: AppColors.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 0.8)),
        const SizedBox(height: 10),
        ...rows,
      ]),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _StepHeader({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.unpaidLight, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.primary, size: 24)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ])),
    ]);
  }
}
