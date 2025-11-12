// lib/pages/manage_leave_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medigo_doctor/supabase_service.dart';

class ManageLeavePage extends StatefulWidget {
  final int doctorBigId;
  const ManageLeavePage({super.key, required this.doctorBigId});

  @override
  State<ManageLeavePage> createState() => _ManageLeavePageState();
}

class _ManageLeavePageState extends State<ManageLeavePage> {
  bool _isLoading = true;
  bool _isSaving = false;
  List<Map<String, dynamic>> _leaves = []; // raw rows from DB

  final DateFormat _displayFormat = DateFormat.yMMMd();

  @override
  void initState() {
    super.initState();
    _fetchLeaves();
  }

  Future<void> _fetchLeaves() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final data = await supabase
          .from('doctor_leave_dates')
          .select()
          .eq('doctor_id', widget.doctorBigId)
          .order('leave_date', ascending: true);

      final items = (data as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      if (mounted) setState(() => _leaves = items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading leaves: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Add a range of leaves (start..end). Inserts one row per date.
  Future<void> _addLeaveRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      initialDateRange: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 1)),
      ),
    );

    if (picked == null) return;

    setState(() => _isSaving = true);

    try {
      // Build set of existing dates (yyyy-mm-dd) for quick check
      final existingSet = <String>{};
      for (final row in _leaves) {
        final raw = row['leave_date'];
        if (raw != null) {
          try {
            final d = DateTime.parse(raw.toString());
            existingSet.add(_dateKey(d));
          } catch (_) {}
        }
      }

      // Build all dates in range
      final rowsToInsert = <Map<String, dynamic>>[];
      DateTime cur = DateTime(picked.start.year, picked.start.month, picked.start.day);
      final end = DateTime(picked.end.year, picked.end.month, picked.end.day);
      while (!cur.isAfter(end)) {
        final key = _dateKey(cur);
        if (!existingSet.contains(key)) {
          rowsToInsert.add({
            'doctor_id': widget.doctorBigId,
            // store full ISO (DB column is date but ISO works; Supabase will accept date portion)
            'leave_date': DateTime(cur.year, cur.month, cur.day).toIso8601String(),
          });
        }
        cur = cur.add(const Duration(days: 1));
      }

      if (rowsToInsert.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All selected dates are already saved.'), backgroundColor: Colors.orange),
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      // Insert all rows at once
      await supabase.from('doctor_leave_dates').insert(rowsToInsert).select();

      // Refresh
      await _fetchLeaves();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${rowsToInsert.length} day(s) of leave.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) _showErrorDialog('Error saving leaves: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Delete all leave rows where leave_date between start..end (inclusive)
  Future<void> _deleteRange(DateTime start, DateTime end) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete range'),
        content: Text('Delete all leaves from ${_displayFormat.format(start)} to ${_displayFormat.format(end)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final startIso = DateTime(start.year, start.month, start.day).toIso8601String();
      final endIso = DateTime(end.year, end.month, end.day).toIso8601String();

      // Use range delete (>= start and <= end)
      await supabase
          .from('doctor_leave_dates')
          .delete()
          .gte('leave_date', startIso)
          .lte('leave_date', endIso);

      await _fetchLeaves();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Range deleted.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) _showErrorDialog('Error deleting range: ${e.toString()}');
    }
  }

  String _dateKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Convert _leaves list into grouped consecutive ranges for display.
  List<_DateRangeGroup> _groupRanges() {
    // extract dates and map date->list of ids (one date usually one id)
    final Map<String, List<int>> map = {};
    for (final row in _leaves) {
      final raw = row['leave_date'];
      int? id;
      try {
        id = (row['id'] is int) ? row['id'] as int : int.tryParse('${row['id']}');
      } catch (_) {}
      if (raw == null) continue;
      DateTime? d;
      try {
        d = DateTime.parse(raw.toString());
      } catch (_) {
        continue;
      }
      final key = _dateKey(d);
      map.putIfAbsent(key, () => []);
      if (id != null) map[key]!.add(id);
    }

    // get sorted unique DateTimes
    final sortedDates = map.keys.map((k) {
      final parts = k.split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    }).toList()
      ..sort((a, b) => a.compareTo(b));

    final List<_DateRangeGroup> result = [];
    if (sortedDates.isEmpty) return result;

    DateTime rangeStart = sortedDates.first;
    DateTime prev = sortedDates.first;

    for (var i = 1; i < sortedDates.length; i++) {
      final cur = sortedDates[i];
      // If current is next day of prev, continue group
      if (cur.difference(prev).inDays == 1) {
        prev = cur;
        continue;
      } else {
        // close group
        final ids = <int>[];
        DateTime d = rangeStart;
        while (!d.isAfter(prev)) {
          final key = _dateKey(d);
          if (map.containsKey(key)) ids.addAll(map[key]!);
          d = d.add(const Duration(days: 1));
        }
        result.add(_DateRangeGroup(start: rangeStart, end: prev, ids: ids));
        // start new group
        rangeStart = cur;
        prev = cur;
      }
    }

    // close last group
    final ids = <int>[];
    DateTime d = rangeStart;
    while (!d.isAfter(prev)) {
      final key = _dateKey(d);
      if (map.containsKey(key)) ids.addAll(map[key]!);
      d = d.add(const Duration(days: 1));
    }
    result.add(_DateRangeGroup(start: rangeStart, end: prev, ids: ids));

    return result;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = !_isLoading && _leaves.isEmpty;
    final groups = _groupRanges();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Leaves'),
        actions: [
          IconButton(onPressed: _fetchLeaves, icon: const Icon(Icons.refresh), tooltip: 'Refresh'),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLeaves,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : isEmpty
                ? _buildEmptyState(theme)
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: groups.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final g = groups[index];
                      final days = g.end.difference(g.start).inDays + 1;
                      final label = (g.start == g.end)
                          ? _displayFormat.format(g.start)
                          : '${_displayFormat.format(g.start)} — ${_displayFormat.format(g.end)}';
                      return Card(
                        child: ExpansionTile(
                          title: Text(label),
                          subtitle: Text('$days day${days > 1 ? 's' : ''}'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: _buildDateChips(g),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => _deleteRange(g.start, g.end),
                                        child: const Text('Delete range'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _addLeaveRange,
        label: _isSaving
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Add Range'),
        icon: _isSaving ? null : const Icon(Icons.add),
      ),
    );
  }

  List<Widget> _buildDateChips(_DateRangeGroup g) {
    final chips = <Widget>[];
    DateTime d = g.start;
    while (!d.isAfter(g.end)) {
      chips.add(Chip(label: Text(_displayFormat.format(d))));
      d = d.add(const Duration(days: 1));
    }
    return chips;
  }

  Widget _buildEmptyState(ThemeData theme) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Icon(Icons.beach_access_outlined, size: 100, color: theme.primaryColor.withOpacity(0.3)),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'No leaves found.\nTap Add Range to create a leave range.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _addLeaveRange,
            icon: const Icon(Icons.add),
            label: const Text('Add Range'),
          ),
        ),
      ],
    );
  }
}

/// Helper representing a contiguous date range (inclusive)
class _DateRangeGroup {
  final DateTime start;
  final DateTime end;
  final List<int> ids; // row ids included in the range
  _DateRangeGroup({required this.start, required this.end, required this.ids});
}
