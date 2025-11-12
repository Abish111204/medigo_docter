// lib/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';
import 'package:medigo_doctor/main.dart';
// --- THIS IS THE MISSING LINE ---
import 'package:medigo_doctor/pages/appointment_details_page.dart';
// --- END OF FIX ---
import 'package:medigo_doctor/widgets/appointment_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardPage extends StatefulWidget {
  final int? doctorBigId; // The 'id' from the doctors table
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
      _todayAppointmentsFuture = Future.value([]); // Init with empty
    }
  }

  @override
  void didUpdateWidget(covariant DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the doctorBigId was null and is now available, fetch appointments
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
          .select('*, profiles(*)') // Fetch patient info from profiles
          .eq('doctor_id', doctorId)
          .eq('appointment_date', _today)
          .order('appointment_time', ascending: true);

      return (data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching today\'s appointments: $e');
      return [];
    }
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text(
              translations.todayAppointments,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary, // Use Teal
              ),
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _refreshAppointments();
              },
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _todayAppointmentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final appointments = snapshot.data!;
                  if (appointments.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          translations.noAppointmentsToday,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      return AppointmentCard(
                        appointment: appointment,
                        onTap: () async {
                          // Navigate to details and wait for a possible update
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AppointmentDetailsPage(
                                appointment: appointment,
                              ),
                            ),
                          );
                          // If the details page returns true, refresh the list
                          if (result == true) {
                            _refreshAppointments();
                          }
                        },
                      )
                          .animate()
                          .fadeIn(delay: (index * 50).ms)
                          .slideX(begin: 0.1, duration: 200.ms);
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