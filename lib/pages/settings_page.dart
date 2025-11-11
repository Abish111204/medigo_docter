// --- lib/pages/settings_page.dart ---

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';
import 'package:medigo_doctor/main.dart'; // To get 'supabase'
import 'package:medigo_doctor/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // --- Profile Card ---
        Card(
            elevation: 2,
            color: Theme.of(context).primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: Icon(
                      Icons.person_outline,
                      size: 28,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Doctor Profile', // You can translate this
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          supabase.auth.currentUser?.email ?? '',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.8)
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
        ),

        // --- Preferences ---
        _buildSectionHeader(context, translations.preferences),
        Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6_outlined),
                  title: Text(translations.darkTheme),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (isDark) {
                      final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
                      themeProvider.setThemeMode(newMode);
                      _updateTheme(isDark);
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.edit_calendar_outlined),
                  title: Text(translations.editSchedule),
                  subtitle: const Text('Coming Soon'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Build the "Edit Schedule" page
                  },
                ),
              ],
            )
        ),

        // --- Account ---
        _buildSectionHeader(context, "Account"),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: Text(translations.logout),
            onTap: () async {
              await supabase.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
          ),
        ),

      ].animate(interval: 50.ms)
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
    );
  }

  // Helper to save the theme
  Future<void> _updateTheme(bool isDark) async {
    final themeString = isDark ? 'Dark' : 'Light';
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await supabase.from('profiles').update({
        'theme': themeString,
      }).eq('id', userId);
    } catch (e) {
      print('Error saving theme: $e');
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0, left: 12.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}