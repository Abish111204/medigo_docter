import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';
import 'package:medigo_doctor/main.dart';
import 'package:medigo_doctor/pages/appointment_details_page.dart';
import 'package:medigo_doctor/widgets/appointment_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardPage extends StatefulWidget {
  final int? doctorBigId;
  const DashboardPage({super.key, this.doctorBigId});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<List<Map<String, dynamic>>> _todayAppointmentsFuture;
  final String _today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    if (widget.doctorBigId != null) {
      _todayAppointmentsFuture = _fetchTodayAppointments(widget.doctorBigId!);
    } else {
      _todayAppointmentsFuture = Future.value([]);
    }
  }

  @override
  void didUpdateWidget(covariant DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.doctorBigId != null && oldWidget.doctorBigId == null) {
      setState(() {
        _todayAppointmentsFuture = _fetchTodayAppointments(widget.doctorBigId!);
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchTodayAppointments(int doctorId) async {
    try {
      final data = await supabase
          .from('appointments')
          .select('*, profiles(*)')
          .eq('doctor_id', doctorId)
          .eq('appointment_date', _today)
          .order('appointment_time', ascending: true);
      return (data as List).cast<Map<String, dynamic>>();
    } catch (e) { return []; }
  }

  void _refreshAppointments() {
    if (widget.doctorBigId != null) {
      setState(() {
        _todayAppointmentsFuture = _fetchTodayAppointments(widget.doctorBigId!);
      });
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, d MMMM').format(DateTime.now()),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  translations.todayAppointments,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(),
          
          const SizedBox(height: 16),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _refreshAppointments(),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _todayAppointmentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final appointments = snapshot.data ?? [];
                  if (appointments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_available_rounded, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            translations.noAppointmentsToday,
                            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      return AppointmentCard(
                        appointment: appointment,
                        onTap: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AppointmentDetailsPage(appointment: appointment),
                            ),
                          );
                          if (result == true) _refreshAppointments();
                        },
                      ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}