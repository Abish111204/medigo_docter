import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';
import 'package:medigo_doctor/main.dart'; // To get 'supabase'
import 'package:medigo_doctor/pages/appointment_details_page.dart';
import 'package:medigo_doctor/widgets/appointment_card.dart';
import 'package:table_calendar/table_calendar.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  String? _doctorId;
  final _noteController = TextEditingController();

  bool _isAppointmentsLoading = true;
  bool _isNoteLoading = true;

  Map<DateTime, List<dynamic>> _events = {};
  List<Map<String, dynamic>> _allAppointments = [];
  List<Map<String, dynamic>> _selectedDayAppointments = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isAppointmentsLoading = true;
    });

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _isAppointmentsLoading = false);
      return;
    }

    try {
      final doctorData = await supabase
          .from('doctors')
          .select('id')
          .eq('user_id', userId)
          .single();
          
      // --- THIS IS THE FIX ---
      // Convert the doctor ID to a String to prevent the type error
      _doctorId = doctorData['id'].toString();
      // --- END OF FIX ---

      if (_doctorId == null) {
        if (mounted) setState(() => _isAppointmentsLoading = false);
        return;
      }

      final appointmentsData = await supabase
          .from('appointments')
          .select('*, profiles(id, phone_number)')
          .eq('doctor_id', _doctorId!)
          .order('appointment_date', ascending: false);

      _allAppointments = (appointmentsData as List).cast<Map<String, dynamic>>();

      _events = {};
      for (var appt in _allAppointments) {
        try {
          final date = DateTime.parse(appt['appointment_date'].toString());

          final dayOnly = DateTime.utc(date.year, date.month, date.day);
          if (_events[dayOnly] == null) {
            _events[dayOnly] = [];
          }
          _events[dayOnly]!.add(appt);
        } catch (e) {
          print('Invalid date format: ${appt['appointment_date']}');
        }
      }

      final today = DateTime.now();
      final todayUTC = DateTime.utc(today.year, today.month, today.day);
      _onDaySelected(todayUTC, todayUTC);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error loading data: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) {
      setState(() {
        _isAppointmentsLoading = false;
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final normalizedDay =
        DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day);
    if (!isSameDay(_selectedDay, normalizedDay)) {
      setState(() {
        _selectedDay = normalizedDay;
        _focusedDay = focusedDay;
      });
      _loadNoteForDay(normalizedDay);
      _filterAppointmentsForDay(normalizedDay);
    }
  }

  void _filterAppointmentsForDay(DateTime day) {
    setState(() {
      _selectedDayAppointments =
          (_events[day] ?? []).cast<Map<String, dynamic>>();
    });
  }

  Future<void> _loadNoteForDay(DateTime day) async {
    if (mounted) setState(() => _isNoteLoading = true);
    _noteController.clear();
    final userId = supabase.auth.currentUser!.id;
    final dateString = DateFormat('yyyy-MM-dd').format(day);

    try {
      final data = await supabase
          .from('calendar_notes')
          .select('note_text')
          .eq('user_id', userId)
          .eq('note_date', dateString)
          .maybeSingle();

      if (data != null && data['note_text'] != null) {
        if (mounted) _noteController.text = data['note_text'].toString();
      }
    } catch (e) {
      /* ignore */
    }
    if (mounted) setState(() => _isNoteLoading = false);
  }

  Future<void> _saveNoteForDay() async {
    setState(() => _isNoteLoading = true);
    final translations = AppLocalizations.of(context)!;
    final text = _noteController.text;
    final userId = supabase.auth.currentUser!.id;
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDay);

    try {
      await supabase.from('calendar_notes').upsert({
        'user_id': userId,
        'note_date': dateString,
        'note_text': text,
      }, onConflict: 'user_id, note_date');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(translations.noteSaved),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _isNoteLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TableCalendar(
              locale: Localizations.localeOf(context).languageCode,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2040, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              eventLoader: (day) {
                final normalizedDay =
                    DateTime.utc(day.year, day.month, day.day);
                return _events[normalizedDay] ?? [];
              },
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                markerDecoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  formatButtonTextStyle: TextStyle(
                    color: theme.primaryColor,
                  )),
            ),
          ),
        ).animate().fadeIn().slideY(begin: 0.1, end: 0),
        const SizedBox(height: 16),
        _buildSectionHeader(
            context,
            "${translations.myNotes} for ${DateFormat.yMMMd().format(_selectedDay)}"),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                      ElevatedButton(
                        onPressed: _isNoteLoading ? null : _saveNoteForDay,
                        child: Text(translations.saveNote),
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms),
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionHeader(
            context,
            "${translations.schedule} on ${DateFormat.yMMMd().format(_selectedDay)}"),
        _buildAppointmentList(context, translations),
      ],
    );
  }

  Widget _buildAppointmentList(
      BuildContext context, AppLocalizations translations) {
    if (_isAppointmentsLoading) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ));
    }

    if (_selectedDayAppointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 16.0),
          child: Text(
            translations.noAppointmentsToday,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ).animate().fadeIn();
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _selectedDayAppointments.length,
      itemBuilder: (context, index) {
        final appt = _selectedDayAppointments[index];
        return AppointmentCard(
          appointment: appt,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AppointmentDetailsPage(
                  appointment: appt,
                  onStatusChanged: _loadInitialData,
                ),
              ),
            );
          },
        ).animate().fadeIn(delay: (index * 50).ms, duration: 400.ms);
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0, top: 8.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}