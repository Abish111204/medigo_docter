// lib/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';
import 'package:medigo_doctor/main.dart'; // For supabase
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
      // Select all columns from profiles
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', _userId)
          .single();
      return data;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error fetching profile: $e'),
              backgroundColor: Colors.red),
        );
      }
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(translations.profile),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(translations.noNameSet));
          }

          final profile = snapshot.data!;
          
          // NEW: Combine first_name and last_name
          final firstName = profile['first_name'] ?? '';
          final lastName = profile['last_name'] ?? '';
          final fullName = (firstName.isEmpty && lastName.isEmpty)
              ? translations.noNameSet
              : '$firstName $lastName'.trim();
              
          final phone = profile['phone_number'] ?? translations.noPhoneSet;
          final dob = profile['dob'] ?? translations.notSet;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Profile Header
              Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person_outline,
                      size: 60,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fullName, // CHANGED
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _email ?? 'No Email',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 24),
              // Profile Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // We don't show name here, but if you did,
                      // you would use the new 'fullName' variable
                      _buildDetailRow(
                        context,
                        Icons.phone_outlined,
                        translations.phoneNumber,
                        phone,
                      ),
                      const Divider(),
                      _buildDetailRow(
                        context,
                        Icons.calendar_today_outlined,
                        translations.dob,
                        dob,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: Text(translations.editProfile),
                onPressed: () async {
                  // Navigate to edit page and wait for a result
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(profile: profile),
                    ),
                  );
                  // If 'true' is returned, the profile was saved, so refresh
                  if (result == true) {
                    setState(() {
                      _profileFuture = _fetchProfile();
                    });
                  }
                },
              ).animate().fadeIn(delay: 200.ms),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 22, color: theme.primaryColor),
          const SizedBox(width: 16),
          Text(
            label,
            style: theme.textTheme.titleMedium,
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}