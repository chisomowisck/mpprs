import 'package:flutter/material.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/offense/domain/entities/offense_category.dart';
import 'package:intl/intl.dart';

class CategoryPickerPage extends StatefulWidget {
  final bool isServiceFee;
  /// When true, allows selecting multiple offense categories at once.
  final bool multiSelect;
  /// Pre-selected categories when opening in multi-select mode.
  final List<OffenseCategory> selectedCategories;

  const CategoryPickerPage({
    super.key,
    this.isServiceFee = false,
    this.multiSelect = false,
    this.selectedCategories = const [],
  });

  @override
  State<CategoryPickerPage> createState() => _CategoryPickerPageState();
}

class _CategoryPickerPageState extends State<CategoryPickerPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  late final Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.selectedCategories.map((c) => c.id).toSet();
  }

  List<OffenseCategory> get _filteredOffense {
    if (_query.isEmpty) return MockData.offenseCategories;
    return MockData.offenseCategories.where((c) =>
        c.name.toLowerCase().contains(_query) || c.code.toLowerCase().contains(_query)).toList();
  }

  List<ServiceCategory> get _filteredService {
    if (_query.isEmpty) return MockData.serviceCategories;
    return MockData.serviceCategories.where((c) =>
        c.name.toLowerCase().contains(_query) || c.code.toLowerCase().contains(_query)).toList();
  }

  Map<String, List<OffenseCategory>> get _grouped {
    final map = <String, List<OffenseCategory>>{};
    for (final c in _filteredOffense) {
      (map[c.groupName] ??= []).add(c);
    }
    return map;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleOffense(OffenseCategory cat) {
    setState(() {
      if (_selectedIds.contains(cat.id)) {
        _selectedIds.remove(cat.id);
      } else {
        _selectedIds.add(cat.id);
      }
    });
  }

  void _confirmMultiSelect() {
    final selected = MockData.offenseCategories
        .where((c) => _selectedIds.contains(c.id))
        .toList();
    Navigator.of(context).pop(selected);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat('#,##0', 'en_US');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isServiceFee ? 'Service Category' : 'Offense Category'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by name or code...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.7)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white38)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Multi-select summary bar
          if (widget.multiSelect && _selectedIds.isNotEmpty)
            Container(
              color: AppColors.primary.withValues(alpha: 0.08),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(children: [
                Container(
                  width: 24, height: 24,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Center(child: Text('${_selectedIds.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${_selectedIds.length} offense${_selectedIds.length == 1 ? '' : 's'} selected',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedIds.clear()),
                  child: const Text('Clear', style: TextStyle(color: AppColors.error, fontSize: 12)),
                ),
              ]),
            ),
          Expanded(
            child: widget.isServiceFee
                ? _buildServiceList(currencyFmt)
                : _buildOffenseGroups(currencyFmt),
          ),
        ],
      ),
      // Confirm button for multi-select
      bottomNavigationBar: widget.multiSelect
          ? Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(color: AppColors.surface, boxShadow: AppColors.elevatedShadow),
              child: ElevatedButton.icon(
                onPressed: _selectedIds.isNotEmpty ? _confirmMultiSelect : null,
                icon: const Icon(Icons.check_circle_rounded, size: 18),
                label: Text(_selectedIds.isEmpty
                    ? 'Select at least one offense'
                    : 'Confirm ${_selectedIds.length} Offense${_selectedIds.length == 1 ? '' : 's'}'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildOffenseGroups(NumberFormat fmt) {
    final grouped = _grouped;
    if (grouped.isEmpty) return _empty();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(entry.key, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 0.8)),
            ),
            ...entry.value.map((cat) {
              final isSelected = _selectedIds.contains(cat.id);
              return _CategoryTile(
                code: cat.code,
                name: cat.name,
                amount: cat.defaultAmount,
                currencyFmt: fmt,
                multiSelect: widget.multiSelect,
                isSelected: isSelected,
                onTap: widget.multiSelect
                    ? () => _toggleOffense(cat)
                    : () => Navigator.of(context).pop(cat),
              );
            }),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildServiceList(NumberFormat fmt) {
    final cats = _filteredService;
    if (cats.isEmpty) return _empty();
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cats.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _CategoryTile(
        code: cats[i].code,
        name: cats[i].name,
        amount: cats[i].defaultAmount,
        onTap: () => Navigator.of(context).pop(cats[i]),
        currencyFmt: fmt,
      ),
    );
  }

  Widget _empty() => const Center(child: Text('No categories found.', style: TextStyle(color: AppColors.textSecondary)));
}

class _CategoryTile extends StatelessWidget {
  final String code, name;
  final double amount;
  final VoidCallback onTap;
  final NumberFormat currencyFmt;
  final bool multiSelect;
  final bool isSelected;

  const _CategoryTile({
    required this.code,
    required this.name,
    required this.amount,
    required this.onTap,
    required this.currencyFmt,
    this.multiSelect = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.07) : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppColors.cardShadow,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border.withValues(alpha: 0.5),
          width: isSelected ? 1.5 : 0.5,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: multiSelect
            ? AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                ),
                child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 15) : null,
              )
            : Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.unpaidLight, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.traffic_rounded, size: 18, color: AppColors.unpaid),
              ),
        title: Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
        subtitle: Text(code, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('MWK ${currencyFmt.format(amount)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
            const SizedBox(height: 2),
            const Text('Fine', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }
}
