// lib/pages/availability_page.dart

import 'package:flutter/material.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';
import 'package:medigo_doctor/main.dart'; // For supabase
import 'package:flutter_animate/flutter_animate.dart';

class AvailabilityPage extends StatefulWidget {
  final int doctorBigId;
  const AvailabilityPage({super.key, required this.doctorBigId});

  @override
  State<AvailabilityPage> createState() => _AvailabilityPageState();
}

class _AvailabilityPageState extends State<AvailabilityPage> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchAvailability();
  }

  Future<void> _fetchAvailability() async {
    setState(() { _isLoading = true; });
    try {
      final data = await supabase
          .from('doctors')
          .select('consult_start_time, consult_end_time')
          .eq('id', widget.doctorBigId)
          .single();
      
      if (mounted) {
        setState(() {
          _startTime = _parseTime(data['consult_start_time']);
          _endTime = _parseTime(data['consult_end_time']);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching availability: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null) return null;
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return null;
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Not Set';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return TimeOfDay.fromDateTime(dt).format(context);
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final initialTime = (isStartTime ? _startTime : _endTime) ?? TimeOfDay.now();
    final newTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (newTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = newTime;
        } else {
          _endTime = newTime;
        }
      });
    }
  }

  Future<void> _saveAvailability() async {
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both a start and end time.'), backgroundColor: Colors.red),
      );
      return;
    }

    if ((_startTime!.hour * 60 + _startTime!.minute) >= (_endTime!.hour * 60 + _endTime!.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() { _isSaving = true; });
    final translations = AppLocalizations.of(context)!;

    try {
      final startTimeString = '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}:00';
      final endTimeString = '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}:00';

      await supabase.from('doctors').update({
        'consult_start_time': startTimeString,
        'consult_end_time': endTimeString,
      }).eq('id', widget.doctorBigId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(translations.availabilityUpdated), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${translations.errorUpdatingAvailability}: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isSaving = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(translations.manageAvailability),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  translations.setYourHours,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.timer_outlined, color: theme.primaryColor),
                        title: Text(translations.startTime),
                        trailing: Text(
                          _formatTime(_startTime),
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        onTap: () => _selectTime(context, true),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      ListTile(
                        leading: Icon(Icons.timer_off_outlined, color: theme.colorScheme.error),
                        title: Text(translations.endTime),
                        trailing: Text(
                          _formatTime(_endTime),
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        onTap: () => _selectTime(context, false),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                const SizedBox(height: 32),
                _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: Text(translations.save),
                      onPressed: _saveAvailability,
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              ],
            ),
    );
  }
}