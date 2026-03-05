import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/widgets/app_widgets.dart';
import '../../../offense/domain/entities/offense_category.dart';
import '../../../offense/presentation/pages/category_picker_page.dart';

class NewServiceFeePage extends StatefulWidget {
  const NewServiceFeePage({super.key});
  @override
  State<NewServiceFeePage> createState() => _NewServiceFeePageState();
}

class _NewServiceFeePageState extends State<NewServiceFeePage> {
  final _formKey = GlobalKey<FormState>();
  final _citizenIdCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  List<ServiceCategory> _categories = [];
  DateTime _requestDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (final c in [_citizenIdCtrl, _nameCtrl, _phoneCtrl, _descCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickCategory() async {
    final result = await Navigator.of(context).push<List<ServiceCategory>>(
      MaterialPageRoute(
        builder: (_) => CategoryPickerPage(
          isServiceFee: true,
          multiSelect: true,
          selectedServiceCategories: _categories,
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
      initialDate: _requestDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _requestDate = picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one service category.'), backgroundColor: AppColors.error));
      return;
    }
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final totalAmount = _categories.fold<double>(0, (sum, c) => sum + c.defaultAmount);
    // Find the shortest deadline among selected services
    final minDeadline = _categories.map((c) => c.deadlineDays).reduce((a, b) => a < b ? a : b);
    final deadline = _requestDate.add(Duration(days: minDeadline));

    context.pushReplacement('/offense/prn-issued', extra: {
      'prn': '2656432895246',
      'vehicleReg': '',
      'offenderName': _nameCtrl.text.trim(),
      'categoryName': _categories.length == 1 ? _categories.first.name : '${_categories.length} Services Selected',
      'categoryCode': _categories.length == 1 ? _categories.first.code : 'MULTIPLE',
      'amount': totalAmount,
      'deadline': deadline,
      'offenseDate': _requestDate,
      'location': '',
      'maltisRef': '',
      'officerName': 'Sgt. Samuel Phiri',
      'stationName': 'Lilongwe Central Police Station',
      'isTrafficOffense': false,
      'categories': _categories, // Pass the full list for potential use in issuance page
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat(AppConstants.dateDisplayFormat);
    final currFmt = NumberFormat('#,##0', 'en_US');
    final totalAmount = _categories.fold<double>(0, (sum, c) => sum + c.defaultAmount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Service Fee Request'),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => context.pop()),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(icon: Icons.person_rounded, title: 'Citizen Details'),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _citizenIdCtrl,
                      decoration: const InputDecoration(labelText: 'National ID / Passport *', prefixIcon: Icon(Icons.credit_card_rounded)),
                      validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Citizen Full Name *', prefixIcon: Icon(Icons.person_outline_rounded)),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone Number (optional)', prefixIcon: Icon(Icons.phone_outlined)),
                    ),
                    const SizedBox(height: 24),
                    _SectionHeader(icon: Icons.receipt_long_rounded, title: 'Service Details'),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: _pickCategory,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _categories.isNotEmpty ? AppColors.primary : AppColors.border, width: _categories.isNotEmpty ? 1.5 : 1),
                        ),
                        child: Row(children: [
                          const Icon(Icons.receipt_long_rounded, color: AppColors.textSecondary, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _categories.isEmpty
                                ? const Text('Select Service Category *', style: TextStyle(color: AppColors.textTertiary, fontSize: 14))
                                : Text(
                                    '${_categories.length} service${_categories.length == 1 ? '' : 's'} selected',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary),
                                  ),
                          ),
                          Text(
                            _categories.isEmpty ? 'Add' : 'Edit',
                            style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                        ]),
                      ),
                    ),
                    if (_categories.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ..._categories.map((cat) => Container(
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
                                child: const Icon(Icons.receipt_long_rounded, size: 16, color: AppColors.unpaid),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(cat.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                Text('${cat.code}  ·  MWK ${currFmt.format(cat.defaultAmount)}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ])),
                              GestureDetector(
                                onTap: () => setState(() => _categories.remove(cat)),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                  child: const Icon(Icons.close_rounded, color: AppColors.error, size: 16),
                                ),
                              ),
                            ]),
                          )),
                    ],
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Service Description (optional)', prefixIcon: Padding(padding: EdgeInsets.only(bottom: 20), child: Icon(Icons.notes_rounded))),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                        child: Row(children: [
                          const Icon(Icons.calendar_today_rounded, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 12),
                          Text('Request Date: ${dateFmt.format(_requestDate)}', style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                          const Spacer(),
                          const Icon(Icons.edit_calendar_rounded, color: AppColors.textTertiary, size: 18),
                        ]),
                      ),
                    ),
                    if (_categories.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              _categories.length == 1 ? 'Service Fee' : 'Total Service Fees',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Text('MWK ${currFmt.format(totalAmount)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                          ]),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            const Text('Payment Window', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('${_categories.map((c) => c.deadlineDays).reduce((a, b) => a < b ? a : b)} days', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          ]),
                        ]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(color: AppColors.surface, boxShadow: AppColors.elevatedShadow),
              child: PrimaryButton(label: 'Issue PRN', isLoading: _isSubmitting, icon: Icons.receipt_long_rounded, onPressed: _submit),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.unpaidLight, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: AppColors.primary, size: 18)),
      const SizedBox(width: 10),
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    ]);
  }
}

