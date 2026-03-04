import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/widgets/app_widgets.dart';
import '../../../../core/ui/widgets/transaction_list_item.dart';
import '../../../../features/transactions/domain/entities/transaction_entity.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  TransactionStatus? _statusFilter;
  TransactionType? _typeFilter;

  List<TransactionEntity> get _filtered {
    return MockData.transactions.where((t) {
      final q = _query.toLowerCase();
      final matchesQuery = q.isEmpty ||
          (t.prn?.toLowerCase().contains(q) ?? false) ||
          t.offenderName.toLowerCase().contains(q) ||
          (t.vehicleReg?.toLowerCase().contains(q) ?? false) ||
          t.categoryName.toLowerCase().contains(q);
      final matchesStatus = _statusFilter == null || t.status == _statusFilter;
      final matchesType = _typeFilter == null || t.type == _typeFilter;
      return matchesQuery && matchesStatus && matchesType;
    }).toList();
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FilterSheet(
        currentStatus: _statusFilter,
        currentType: _typeFilter,
        onApply: (status, type) {
          setState(() {
            _statusFilter = status;
            _typeFilter = type;
          });
          Navigator.pop(context);
        },
        onClear: () {
          setState(() {
            _statusFilter = null;
            _typeFilter = null;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;
    final hasFilters = _statusFilter != null || _typeFilter != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search Transactions'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search PRN, name, vehicle reg...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.7)),
                    suffixIcon: _query.isNotEmpty ? IconButton(icon: const Icon(Icons.clear_rounded, color: Colors.white70), onPressed: () => setState(() { _searchCtrl.clear(); _query = ''; })) : null,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.15),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white38)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _showFilters,
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: hasFilters ? AppColors.secondary : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.tune_rounded, color: hasFilters ? Colors.white : Colors.white70),
                ),
              ),
            ]),
          ),
          // Filter chips
          if (hasFilters) Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(children: [
              const Text('Filters: ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              if (_statusFilter != null) _FilterChip(label: _statusFilter!.label, onRemove: () => setState(() => _statusFilter = null)),
              if (_typeFilter != null) _FilterChip(label: _typeFilter == TransactionType.trafficOffense ? 'Traffic Offense' : 'Service Fee', onRemove: () => setState(() => _typeFilter = null)),
            ]),
          ),
          // Results count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(children: [
              Text('${results.length} result${results.length != 1 ? 's' : ''}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ]),
          ),
          // List
          Expanded(
            child: results.isEmpty
                ? EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No transactions found',
                    subtitle: _query.isNotEmpty ? 'Try a different search term' : 'No transactions match the selected filters',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => TransactionListItem(
                      transaction: results[i],
                      onTap: () => context.push('/transaction/${results[i].id}'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.unpaidLight, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.unpaid, fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        GestureDetector(onTap: onRemove, child: const Icon(Icons.close_rounded, size: 14, color: AppColors.unpaid)),
      ]),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final TransactionStatus? currentStatus;
  final TransactionType? currentType;
  final void Function(TransactionStatus?, TransactionType?) onApply;
  final VoidCallback onClear;
  const _FilterSheet({this.currentStatus, this.currentType, required this.onApply, required this.onClear});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late TransactionStatus? _status;
  late TransactionType? _type;

  @override
  void initState() {
    super.initState();
    _status = widget.currentStatus;
    _type = widget.currentType;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Filter Transactions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const Spacer(),
          TextButton(onPressed: widget.onClear, child: const Text('Clear All')),
        ]),
        const SizedBox(height: 16),
        const Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 0.8)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 6, children: [
          for (final s in TransactionStatus.values)
            FilterChip(
              label: Text(s.label),
              selected: _status == s,
              onSelected: (sel) => setState(() => _status = sel ? s : null),
              selectedColor: AppColors.unpaidLight,
            ),
        ]),
        const SizedBox(height: 16),
        const Text('Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 0.8)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          FilterChip(label: const Text('Traffic Offense'), selected: _type == TransactionType.trafficOffense, onSelected: (s) => setState(() => _type = s ? TransactionType.trafficOffense : null), selectedColor: AppColors.unpaidLight),
          FilterChip(label: const Text('Service Fee'), selected: _type == TransactionType.serviceFee, onSelected: (s) => setState(() => _type = s ? TransactionType.serviceFee : null), selectedColor: AppColors.unpaidLight),
        ]),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () => widget.onApply(_status, _type), child: const Text('Apply Filters')),
      ]),
    );
  }
}

