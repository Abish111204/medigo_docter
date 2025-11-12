// lib/pages/schedule_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';
import 'package:medigo_doctor/main.dart';
import 'package:medigo_doctor/pages/appointment_details_page.dart';
import 'package:medigo_doctor/widgets/appointment_card.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SchedulePage extends StatefulWidget {
  final int? doctorBigId; // The 'id' from the doctors table
  const SchedulePage({super.key, this.doctorBigId});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Future<List<Map<String, dynamic>>> _appointmentsFuture;
  Map<String, List<Map<String, dynamic>>> _appointmentsCache = {};

  // --- NEW: For the Notes feature ---
  final TextEditingController _noteController = TextEditingController();
  bool _isNoteLoading = false;
  bool _isNoteSaving = false;
  Map<String, String> _notesCache = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    if (widget.doctorBigId != null) {
      _appointmentsFuture = _fetchAppointmentsForMonth(_focusedDay);
      _fetchNoteForDay(_selectedDay!);
    } else {
      _appointmentsFuture = Future.value([]);
    }
  }

  @override
  void didUpdateWidget(covariant SchedulePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.doctorBigId != null && oldWidget.doctorBigId == null) {
      setState(() {
        _appointmentsFuture = _fetchAppointmentsForMonth(_focusedDay);
        _fetchNoteForDay(_selectedDay!);
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAppointmentsForMonth(DateTime month) async {
    if (widget.doctorBigId == null) return [];

    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    try {
      final data = await supabase
          .from('appointments')
          .select('*, profiles(*)')
          .eq('doctor_id', widget.doctorBigId!)
          .gte('appointment_date', firstDay.toIso8601String())
          .lte('appointment_date', lastDay.toIso8601String());
      
      final appointments = (data as List).cast<Map<String, dynamic>>();
      _appointmentsCache = _groupAppointmentsByDay(appointments);
      setState(() {}); // Update the UI with event markers
      return appointments;
    } catch (e) {
      print('Error fetching month appointments: $e');
      return [];
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupAppointmentsByDay(List<Map<String, dynamic>> appointments) {
    Map<String, List<Map<String, dynamic>>> map = {};
    for (var app in appointments) {
      final day = app['appointment_date'];
      if (map[day] == null) {
        map[day] = [];
      }
      map[day]!.add(app);
    }
    return map;
  }

  List<Map<String, dynamic>> _getAppointmentsForDay(DateTime day) {
    final dayString = DateFormat('yyyy-MM-dd').format(day);
    return _appointmentsCache[dayString] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      // Fetch the note for the newly selected day
      _fetchNoteForDay(selectedDay);
    }
  }

  void _onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    // Fetch appointments for the new month
    _appointmentsFuture = _fetchAppointmentsForMonth(focusedDay);
  }

  void _refreshSelectedDayAppointments() {
    setState(() {
      // This just rebuilds the list from cache
    });
  }

  // --- NEW: Fetch the note for the selected day ---
  Future<void> _fetchNoteForDay(DateTime day) async {
    if (widget.doctorBigId == null) return;
    setState(() { _isNoteLoading = true; });
    
    final dateString = DateFormat('yyyy-MM-dd').format(day);

    // Check cache first
    if (_notesCache.containsKey(dateString)) {
      _noteController.text = _notesCache[dateString]!;
      setState(() { _isNoteLoading = false; });
      return;
    }
    
    // If not in cache, fetch from Supabase
    try {
      final data = await supabase
          .from('doctor_daily_notes')
          .select('note_text')
          .eq('doctor_id', widget.doctorBigId!)
          .eq('note_date', dateString)
          .maybeSingle();

      if (mounted) {
        final note = (data?['note_text'] as String?) ?? '';
        _noteController.text = note;
        _notesCache[dateString] = note; // Save to cache
      }
    } catch (e) {
      print('Error fetching note: $e');
      _noteController.text = ''; // Clear on error
    } finally {
      if (mounted) {
        setState(() { _isNoteLoading = false; });
      }
    }
  }

  // --- NEW: Save the note for the selected day ---
  Future<void> _saveNote() async {
    if (widget.doctorBigId == null || _selectedDay == null) return;
    setState(() { _isNoteSaving = true; });

    final translations = AppLocalizations.of(context)!;
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    final noteText = _noteController.text;

    try {
      // 'upsert' will create a new note or update an existing one
      await supabase
          .from('doctor_daily_notes')
          .upsert({
            'doctor_id': widget.doctorBigId,
            'note_date': dateString,
            'note_text': noteText,
          }, onConflict: 'doctor_id, note_date'); // Use the UNIQUE constraint

      _notesCache[dateString] = noteText; // Update cache

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(translations.noteSaved), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isNoteSaving = false; });
        FocusScope.of(context).unfocus(); // Hide keyboard
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    if (widget.doctorBigId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: ListView( // Use ListView to allow notes and appointments to scroll
        padding: const EdgeInsets.all(0),
        children: [
          // --- 1. STYLED CALENDAR ---
          Card(
            margin: const EdgeInsets.all(16.0),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              onPageChanged: _onPageChanged,
              eventLoader: _getAppointmentsForDay,
              // --- Professional Styling ---
              calendarStyle: CalendarStyle(
                // Selected day
                selectedDecoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                // Today
                todayDecoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
                // Event markers
                markerDecoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                ),
                // Weekend/Outside day styling
                weekendTextStyle: TextStyle(color: theme.colorScheme.error.withOpacity(0.7)),
                outsideDaysVisible: false,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                leftChevronIcon: Icon(Icons.chevron_left, color: theme.primaryColor),
                rightChevronIcon: Icon(Icons.chevron_right, color: theme.primaryColor),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms),
          
          // --- 2. NEW: "MY NOTES" SECTION ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "${translations.myNotes} - ${DateFormat.yMMMd().format(_selectedDay!)}",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isNoteLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _noteController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: translations.typeYourNoteHere,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _isNoteSaving
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _saveNote,
                              child: Text(translations.saveNote),
                            ),
                      ],
                    ),
            ),
          ).animate().fadeIn(delay: 200.ms),

          // --- 3. APPOINTMENTS FOR THE DAY ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Text(
              "${translations.schedule} - ${DateFormat.yMMMd().format(_selectedDay!)}",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          _buildAppointmentList(_getAppointmentsForDay(_selectedDay!)),
          const SizedBox(height: 16), // Padding at the bottom
        ],
      ),
    );
  }

  Widget _buildAppointmentList(List<Map<String, dynamic>> appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            AppLocalizations.of(context)!.noAppointments,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ).animate().fadeIn(delay: 200.ms);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: appointments.length,
      shrinkWrap: true, // Important inside a ListView
      physics: const NeverScrollableScrollPhysics(), // Important inside a ListView
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return AppointmentCard(
          appointment: appointment,
          onTap: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AppointmentDetailsPage(
                  appointment: appointment,
                ),
              ),
            );
            if (result == true) {
              // Full refresh
              _appointmentsFuture = _fetchAppointmentsForMonth(_focusedDay);
            } else {
              // Just refresh this day's list
              _refreshSelectedDayAppointments();
            }
          },
        )
        // This makes each card animate in
        .animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, duration: 200.ms);
      },
    );
  }
}