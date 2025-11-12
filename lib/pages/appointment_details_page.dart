// lib/pages/appointment_details_page.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';
import 'package:medigo_doctor/main.dart'; // For supabase
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final Map<String, dynamic> appointment;

  const AppointmentDetailsPage({
    super.key,
    required this.appointment,
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
    _currentStatus = widget.appointment['status'] ?? 'Upcoming';
    
    _reportsFuture = _fetchMedicalReports();
    _fetchDoctorName();
  }

  Future<void> _fetchDoctorName() async {
    if (_doctorId == null) return;
    try {
      final data = await supabase
          .from('doctors')
          .select('name')
          .eq('user_id', _doctorId!)
          .single();
      if (mounted && data['name'] != null) {
        setState(() {
          _doctorName = data['name'];
        });
      }
    } catch (e) {
      print("Error fetching doctor's name: $e");
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Could not launch $launchUri';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error calling: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // THIS FUNCTION IS THE KEY
  // It fetches reports from BOTH the patient and the doctor
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

      for (var report in doctorReports) {
        allReports.add({
          'title': report['report_title'] ?? 'Untitled',
          'date': report['uploaded_at'],
          'path': report['file_url'],
          'bucket': 'medical_reports', // Doctor's bucket
          'uploaded_by': 'Doctor',
        });
      }

      for (var report in patientReports) {
        allReports.add({
          'title': report['description'] ?? report['file_name'] ?? 'Untitled',
          'date': report['created_at'],
          'path': report['file_path'],
          'bucket': 'medical_records', // Patient's bucket
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
    try {
      await supabase
          .from('appointments')
          .update({'status': newStatus})
          .eq('id', widget.appointment['id']);

      if (mounted) {
        setState(() {
          _currentStatus = newStatus;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Appointment marked as $newStatus'),
          backgroundColor: Colors.green,
        ));
        
        // Send a 'true' value back to the previous screen to signal a refresh
        Navigator.of(context).pop(true);
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
        'jpg': 'image/jpeg', 'jpeg': 'image/jpeg',
        'png': 'image/png', 'pdf': 'application/pdf',
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
        'doctor_id': widget.appointment['doctor_id'], // Use the bigint ID
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
        // Show a non-blocking error
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Warning: Failed to copy to patient records. $e'),
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

  Future<void> _openReport(String bucket, String filePath, String title) async {
    try {
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Pop with 'false' to indicate no major change
            Navigator.of(context).pop(false);
          },
        ),
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
                    translations.patientDetails,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                      context, Icons.person_outline, translations.name, patientName),
                  _buildDetailRow(context, Icons.cake_outlined, translations.age, age),
                  _buildDetailRow(context, Icons.wc_outlined, translations.gender, gender),
                  if (_patientPhoneNumber != null)
                    _buildPhoneRow(context, _patientPhoneNumber!)
                  else
                    _buildDetailRow(
                        context, Icons.phone_disabled, translations.phone, 'Not provided'),
                ],
              ),
            ),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // Appointment Status Section
          Text(
            translations.appointmentStatus,
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
                        ? null 
                        : () => _updateAppointmentStatus('Completed'),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.cancel),
                    label: Text(translations.statusMissed),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentStatus == 'Missed'
                          ? Colors.grey
                          : Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _currentStatus == 'Missed'
                        ? null
                        : () => _updateAppointmentStatus('Missed'),
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
                translations.medicalReports,
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
                      tooltip: translations.uploadNewReport,
                      onPressed: _uploadReport,
                    ),
            ],
          ),
          const SizedBox(height: 8),

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
                  ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.phone_outlined, size: 20, color: theme.primaryColor),
          const SizedBox(width: 16),
          Text(
            '${AppLocalizations.of(context)!.phone}: ',
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
          // --- CALL BUTTON ---
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