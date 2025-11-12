// lib/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'manage_leave_page.dart';

import 'package:medigo_doctor/l10n/generated/app_localizations.dart';
import 'package:medigo_doctor/main.dart'; // For supabase
import 'package:medigo_doctor/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:medigo_doctor/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'availability_page.dart';
import 'language_page.dart';
// Import only ManageLeavePage to avoid symbol conflicts if the other file also declares AvailabilityPage
import 'manage_leave_page.dart' show ManageLeavePage;


class SettingsPage extends StatefulWidget {
  final int? doctorBigId;
  const SettingsPage({super.key, this.doctorBigId});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> _updateTheme(bool isDark) async {
    final themeString = isDark ? 'Dark' : 'Light';
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await supabase.from('profiles').update({
        'theme': themeString,
      }).eq('id', userId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving theme: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    final user = supabase.auth.currentUser;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Profile Header ---
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.person_outline,
                  size: 32,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.email ?? 'Doctor',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "MediGo Doctor",
                      style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 24),

          // --- Schedule Section ---
          Text(
            translations.schedule.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.event_available_outlined),
                  title: Text(translations.manageAvailability),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    if (widget.doctorBigId == null) return; // Not loaded yet
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AvailabilityPage(
                          doctorBigId: widget.doctorBigId!,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                         leading: const Icon(Icons.event_busy_outlined),
                         title: Text(translations.manageLeave),
                         trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                             if (widget.doctorBigId == null) return;
                            Navigator.of(context).push(
                         MaterialPageRoute(
                         builder: (context) => ManageLeavePage(
                          doctorBigId: widget.doctorBigId!,
        ),
      ),
    );
  },
),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 24),

          // --- App Settings Section ---
          Text(
            translations.appSettings.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  ),
                  title: Text(translations.darkMode),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      themeProvider.setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light);
                      _updateTheme(value);
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: Text(translations.language),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const LanguagePage()),
                    );
                  },
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          // --- Sign Out Button ---
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: Text(translations.signOut),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () async {
              await supabase.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()), 
                  (route) => false,
                );
              }
            },
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}