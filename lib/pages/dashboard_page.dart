// --- lib/pages/dashboard_page.dart ---

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';
import 'package:medigo_doctor/main.dart'; // To get 'supabase'
import 'package:medigo_doctor/pages/appointment_details_page.dart';
import 'package:medigo_doctor/widgets/appointment_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future<List<Map<String, dynamic>>>? _todayApptsFuture;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  // --- MODIFIED: This function will be passed as a callback ---
  Future<void> _loadDashboard() async {
    // We wrap in setState to ensure the FutureBuilder rebuilds
    setState(() {
       _todayApptsFuture = _fetchTodayAppointments();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchTodayAppointments() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw 'Not logged in!';

    // --- THIS IS THE FIX (Part 1) ---
    // 1. Get the doctor's *profile id* (from the doctors table)
    // We assume the patient app uses the DOCTOR'S PROFILE ID (UUID) to book
    final doctorData = await supabase
        .from('doctors')
        .select('id')
        .eq('user_id', userId) // Find doctor profile using auth user id
        .single();

    final doctorId = doctorData['id']; // This is the ID patients use to book
    // --- END OF FIX 1 ---

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // --- THIS IS THE FIX 2 ---
    final appointmentsData = await supabase
        .from('appointments')
        .select('*, profiles(id, phone_number)') // Also get patient ID
        .eq('doctor_id', doctorId) // <-- Use doctorId (from doctors table)
        // --- ADDED 'Pending' to the filter ---
        .inFilter('status', ['Confirmed', 'Upcoming', 'Completed', 'Pending', 'Missed']) 
        .eq('appointment_date', today)
        .order('appointment_time', ascending: true);
    // --- END OF FIX 2 ---

    return (appointmentsData as List).cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 1. Today's Appointments
        _buildSectionHeader(context, translations.todaysAppointments),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _todayApptsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
            }
            final appointments = snapshot.data!;
            if (appointments.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    translations.noAppointmentsToday,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ).animate().fadeIn();
            }

            return ListView.builder(
              itemCount: appointments.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final appt = appointments[index];
                
                return AppointmentCard(
                  appointment: appt,
                  onTap: () async {
                    // --- MODIFIED: Pass the _loadDashboard callback ---
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppointmentDetailsPage(
                          appointment: appt,
                          onStatusChanged: _loadDashboard, // Pass refresh func
                        ),
                      ),
                    );
                  },
                ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
              },
            );
          },
        ),
      ].animate(interval: 50.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}