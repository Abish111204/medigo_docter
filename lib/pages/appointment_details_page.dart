// lib/pages/appointment_details_page.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';
import 'package:medigo_doctor/main.dart'; // To get 'supabase'
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback? onStatusChanged;

  const AppointmentDetailsPage({
    super.key,
    required this.appointment,
    this.onStatusChanged,
  });

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  late Future<List<Map<String, dynamic>>> _reportsFuture;
  bool _isUploading = false;
  String? _patientId;
  String? _doctorId;
  String _doctorName = 'Doctor';
  String? _patientPhoneNumber;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();

    final profileData = widget.appointment['profiles'];
    if (profileData is Map<String, dynamic>) {
      if (profileData['id'] != null) {
        _patientId = profileData['id'];
      }
      if (profileData['phone_number'] != null) {
        _patientPhoneNumber = profileData['phone_number'].toString();
      }
    }

    _doctorId = supabase.auth.currentUser?.id;
    _currentStatus = widget.appointment['status'] ?? 'Confirmed';

    // This function will now fetch from BOTH tables
    _reportsFuture = _fetchMedicalReports();

    _fetchDoctorName();
  }

  Future<void> _fetchDoctorName() async {
    // ... (This function is correct, no change needed)
    if (_doctorId == null) return;
    try {
      final data = await supabase
          .from('doctors')
          .select('name')
          .eq('user_id', _doctorId!)
          .single();
      if (data['name'] != null) {
        setState(() {
          _doctorName = data['name'];
        });
      }
    } catch (e) {
      print("Error fetching doctor's name: $e");
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // ... (This function is correct, no change needed)
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Could not launch dialer.'),
                backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- THIS IS THE MODIFIED FUNCTION ---
  Future<List<Map<String, dynamic>>> _fetchMedicalReports() async {
    if (_patientId == null) {
      return [];
    }
    
    try {
      // 1. Fetch reports uploaded by the doctor
      final doctorUploadsFuture = supabase
          .from('patient_medical_reports')
          .select()
          .eq('patient_id', _patientId!)
          .order('uploaded_at', ascending: false);

      // 2. Fetch reports uploaded by the patient
      final patientUploadsFuture = supabase
          .from('medical_records')
          .select()
          .eq('user_id', _patientId!)
          .order('created_at', ascending: false);

      // Run both queries at the same time
      final List<dynamic> results = await Future.wait([
        doctorUploadsFuture,
        patientUploadsFuture,
      ]);

      final List<Map<String, dynamic>> doctorReports =
          (results[0] as List).cast<Map<String, dynamic>>();

      final List<Map<String, dynamic>> patientReports =
          (results[1] as List).cast<Map<String, dynamic>>();

      // 3. Combine them into one list
      final List<Map<String, dynamic>> allReports = [];

      // Add doctor reports with a tag
      for (var report in doctorReports) {
        allReports.add({
          'title': report['report_title'] ?? 'Untitled',
          'date': report['uploaded_at'],
          'path': report['file_url'],
          'bucket': 'medical_reports', // So we know where to download from
          'uploaded_by': 'Doctor',
        });
      }

      // Add patient reports with a tag
      for (var report in patientReports) {
        allReports.add({
          'title': report['description'] ?? report['file_name'] ?? 'Untitled',
          'date': report['created_at'],
          'path': report['file_path'],
          'bucket': 'medical_records', // The patient's bucket
          'uploaded_by': 'Patient',
        });
      }

      // 4. Sort the combined list by date
      allReports.sort((a, b) => 
          DateTime.parse(b['date']).compareTo(DateTime.parse(a['date']))
      );

      return allReports;

    } catch (e) {
      print('Error fetching combined reports: $e');
      return [];
    }
  }

  Future<void> _updateAppointmentStatus(String newStatus) async {
    // ... (This function is correct, no change needed)
    try {
      await supabase
          .from('appointments')
          .update({'status': newStatus})
          .eq('id', widget.appointment['id']);

      setState(() {
        _currentStatus = newStatus;
      });

      widget.onStatusChanged?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Appointment marked as $newStatus'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _uploadReport() async {
    // ... (This function is correct, no change needed)
    if (_patientId == null || _doctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error: Patient or Doctor ID is missing.')));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );

      if (result == null || result.files.single.path == null) {
        setState(() {
          _isUploading = false;
        });
        return; 
      }

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      final extension = result.files.first.extension?.toLowerCase() ?? 'bin';
      const mimeTypes = {
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
        'pdf': 'application/pdf',
      };
      final contentType = mimeTypes[extension] ?? 'application/octet-stream';

      final filePath =
          '$_patientId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // 1. UPLOAD TO DOCTOR'S BUCKET
      await supabase.storage.from('medical_reports').upload(
            filePath,
            file,
            fileOptions: FileOptions(contentType: contentType),
          );

      // 2. INSERT INTO DOCTOR'S TABLE
      await supabase.from('patient_medical_reports').insert({
        'patient_id': _patientId,
        'appointment_id': widget.appointment['id'],
        'report_title': fileName,
        'file_url': filePath, 
        'doctor_id': _doctorId,
      });

      // 3. CALL EDGE FUNCTION TO COPY TO PATIENT'S BUCKET
      try {
        await supabase.functions.invoke(
          'copy-to-patient-records', 
          body: {
            'source_path': filePath, 
            'patient_id': _patientId,
            'file_name': fileName,
            'description': 'Uploaded by $_doctorName',
          },
        );
      } catch (e) {
        print('Could not copy file to patient records: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Warning: File saved to doctor, but failed to copy to patient. $e'),
            backgroundColor: Colors.orange,
          ));
        }
      }

      setState(() {
        _reportsFuture = _fetchMedicalReports(); // Refresh combined list
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('$fileName uploaded successfully.'),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error uploading report: $e'),
            backgroundColor: Colors.red));
      }
    }
  }

  // --- THIS IS THE MODIFIED FUNCTION ---
  Future<void> _openReport(String bucket, String filePath, String title) async {
    try {
      // Use the 'bucket' variable to download from the correct place
      final bytes = await supabase.storage.from(bucket).download(filePath);

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$title');
      await file.writeAsBytes(bytes);

      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        throw Exception('Could not open file: ${result.message}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final patientName =
        (widget.appointment['patient_name'] ?? 'No Name').toString();
    final age = (widget.appointment['patient_age'] ?? '...').toString();
    final gender = (widget.appointment['patient_gender'] ?? '...').toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(patientName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Patient Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patient Details',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                      context, Icons.person_outline, 'Name', patientName),
                  _buildDetailRow(context, Icons.cake_outlined, 'Age', age),
                  _buildDetailRow(context, Icons.wc_outlined, 'Gender', gender),
                  if (_patientPhoneNumber != null)
                    _buildPhoneRow(context, _patientPhoneNumber!)
                  else
                    _buildDetailRow(
                        context, Icons.phone_disabled, 'Phone', 'Not provided'),
                ],
              ),
            ),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // Appointment Status Section
          // ... (This section is correct, no change needed)
          Text(
            'Appointment Status',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // "Mark as Completed" Button
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: Text(translations.statusCompleted),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentStatus == 'Completed'
                          ? Colors.grey
                          : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _currentStatus == 'Completed'
                        ? null // Disable if already completed
                        : () => _updateAppointmentStatus('Completed'),
                  ),
                  // "Mark as Pending" Button
                  ElevatedButton.icon(
                    icon: const Icon(Icons.pending_actions),
                    label: const Text('Pending'), // You can translate this
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          (_currentStatus == 'Completed' ||
                                  _currentStatus == 'Missed')
                              ? theme.primaryColor
                              : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: (_currentStatus == 'Completed' ||
                            _currentStatus == 'Missed')
                        ? () => _updateAppointmentStatus(
                            'Confirmed') // Set back to 'Confirmed'
                        : null, // Disable if already pending
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // Medical Reports Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Medical Reports',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              _isUploading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(
                      icon: Icon(Icons.upload_file_outlined,
                          color: theme.primaryColor),
                      tooltip: 'Upload New Report',
                      onPressed: _uploadReport,
                    ),
            ],
          ),
          const SizedBox(height: 8),

          // --- THIS IS THE MODIFIED WIDGET ---
          // Reports List
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _reportsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final reports = snapshot.data!;
              if (reports.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No medical reports found for this patient.'),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  // Get data from our new combined map
                  final report = reports[index];
                  final title = report['title'];
                  final date =
                      DateFormat.yMMMd().format(DateTime.parse(report['date']));
                  final bucket = report['bucket'];
                  final path = report['path'];
                  final uploadedBy = report['uploaded_by']; // 'Doctor' or 'Patient'

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        uploadedBy == 'Doctor' 
                          ? Icons.medical_services_outlined 
                          : Icons.person_outline,
                        color: theme.primaryColor
                      ),
                      title: Text(title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Uploaded by $uploadedBy on $date'),
                      trailing: const Icon(Icons.download_for_offline_outlined),
                      onTap: () => _openReport(bucket, path, title),
                    ),
                  ).animate().fadeIn(delay: (index * 50).ms);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, IconData icon, String label, String value) {
    // ... (This function is correct, no change needed)
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.primaryColor),
          const SizedBox(width: 16),
          Text(
            '$label: ',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneRow(BuildContext context, String phoneNumber) {
    // ... (This function is correct, no change needed)
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.phone_outlined, size: 20, color: theme.primaryColor),
          const SizedBox(width: 16),
          Text(
            'Phone: ',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
          Expanded(
            child: Text(
              phoneNumber,
              style:
                  theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
          IconButton(
            icon: Icon(Icons.call, color: Colors.green.shade700),
            onPressed: () => _makePhoneCall(phoneNumber),
            tooltip: 'Call patient',
          )
        ],
      ),
    );
  }
}