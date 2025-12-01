import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';
import 'package:medigo_doctor/main.dart';
import 'package:medigo_doctor/pages/appointment_details_page.dart';
import 'package:medigo_doctor/widgets/appointment_card.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SchedulePage extends StatefulWidget {
  final int? doctorBigId;
  const SchedulePage({super.key, this.doctorBigId});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Future<List<Map<String, dynamic>>> _appointmentsFuture;
  Map<String, List<Map<String, dynamic>>> _appointmentsCache = {};

  final TextEditingController _noteController = TextEditingController();
  bool _isNoteLoading = false;
  bool _isNoteSaving = false;

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
      if (mounted) setState(() {});
      return appointments;
    } catch (e) { return []; }
  }

  Map<String, List<Map<String, dynamic>>> _groupAppointmentsByDay(List<Map<String, dynamic>> appointments) {
    Map<String, List<Map<String, dynamic>>> map = {};
    for (var app in appointments) {
      final day = app['appointment_date'];
      if (map[day] == null) map[day] = [];
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
      _fetchNoteForDay(selectedDay);
    }
  }

  Future<void> _fetchNoteForDay(DateTime day) async {
    if (widget.doctorBigId == null) return;
    setState(() => _isNoteLoading = true);
    final dateString = DateFormat('yyyy-MM-dd').format(day);

    try {
      final data = await supabase
          .from('doctor_daily_notes')
          .select('note_text')
          .eq('doctor_id', widget.doctorBigId!)
          .eq('note_date', dateString)
          .maybeSingle();

      if (mounted) _noteController.text = (data?['note_text'] as String?) ?? '';
    } catch (e) { _noteController.text = ''; } 
    finally { if (mounted) setState(() => _isNoteLoading = false); }
  }

  Future<void> _saveNote() async {
    if (widget.doctorBigId == null || _selectedDay == null) return;
    setState(() => _isNoteSaving = true);
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    
    try {
      await supabase.from('doctor_daily_notes').upsert({
        'doctor_id': widget.doctorBigId,
        'note_date': dateString,
        'note_text': _noteController.text,
      }, onConflict: 'doctor_id, note_date');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note saved!'), backgroundColor: Colors.green));
    } catch (e) { /* ignore */ } 
    finally { if (mounted) setState(() => _isNoteSaving = false); FocusScope.of(context).unfocus(); }
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (widget.doctorBigId == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          Card(
            margin: const EdgeInsets.all(16.0),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                onPageChanged: (focusedDay) {
                   _focusedDay = focusedDay;
                   _appointmentsFuture = _fetchAppointmentsForMonth(focusedDay);
                },
                eventLoader: _getAppointmentsForDay,
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(color: theme.primaryColor, shape: BoxShape.circle),
                  todayDecoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.2), shape: BoxShape.circle),
                  todayTextStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                  markerDecoration: BoxDecoration(color: theme.colorScheme.secondary, shape: BoxShape.circle),
                ),
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
              ),
            ),
          ).animate().fadeIn().slideY(begin: -0.1),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(translations.myNotes, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _isNoteLoading ? const LinearProgressIndicator() : TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: translations.typeYourNoteHere,
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _isNoteSaving 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : TextButton.icon(
                          onPressed: _saveNote,
                          icon: const Icon(Icons.save_rounded, size: 18),
                          label: Text(translations.saveNote),
                        ),
                  )
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              "${translations.schedule} - ${DateFormat.MMMd().format(_selectedDay!)}",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          
          _buildAppointmentList(_getAppointmentsForDay(_selectedDay!)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(List<Map<String, dynamic>> appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text("No appointments.", style: TextStyle(color: Colors.grey.shade500)),
        ),
      ).animate().fadeIn(delay: 200.ms);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: appointments.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return AppointmentCard(
          appointment: appointment,
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AppointmentDetailsPage(appointment: appointment)),
            );
            setState(() {}); // Refresh
          },
        ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);
      },
    );
  }
}