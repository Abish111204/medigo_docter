import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';
import 'package:medigo_doctor/main.dart';
import 'package:medigo_doctor/pages/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _profileFuture;
  final _userId = supabase.auth.currentUser!.id;
  final _email = supabase.auth.currentUser!.email;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfile();
  }

  Future<Map<String, dynamic>> _fetchProfile() async {
    try {
      final data = await supabase.from('profiles').select().eq('id', _userId).single();
      return data;
    } catch (e) { return {}; }
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: Text(translations.profile)),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text(translations.noNameSet));

          final profile = snapshot.data!;
          final firstName = profile['first_name'] ?? '';
          final lastName = profile['last_name'] ?? '';
          final fullName = (firstName.isEmpty && lastName.isEmpty) ? translations.noNameSet : '$firstName $lastName'.trim();
          final phone = profile['phone_number'] ?? translations.noPhoneSet;
          final dob = profile['dob'] ?? translations.notSet;

          return ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    child: Icon(Icons.person_rounded, size: 60, color: theme.primaryColor),
                  ).animate().scale(),
                  const SizedBox(height: 16),
                  Text(fullName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Text(_email ?? 'No Email', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
                ],
              ).animate().fadeIn(duration: 300.ms),
              
              const SizedBox(height: 32),
              
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildDetailRow(context, Icons.phone_rounded, translations.phoneNumber, phone),
                      const Divider(height: 32),
                      _buildDetailRow(context, Icons.calendar_month_rounded, translations.dob, dob),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 32),
              
              ElevatedButton.icon(
                icon: const Icon(Icons.edit_rounded),
                label: Text(translations.editProfile),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => EditProfilePage(profile: profile)),
                  );
                  if (result == true) setState(() { _profileFuture = _fetchProfile(); });
                },
              ).animate().fadeIn(delay: 200.ms),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: theme.primaryColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}