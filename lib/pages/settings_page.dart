import 'package:flutter/material.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';
import 'package:medigo_doctor/main.dart';
import 'package:medigo_doctor/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:medigo_doctor/login_page.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'availability_page.dart';
import 'language_page.dart';
// Explicitly hiding SettingsPage if it was exported from here to avoid cycles, 
// though 'show' is usually enough.
import 'package:medigo_doctor/pages/manage_leave_page.dart';

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
    try { await supabase.from('profiles').update({'theme': themeString}).eq('id', userId); } catch (e) { /* ignore */ }
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
        padding: const EdgeInsets.all(20.0),
        children: [
          Card(
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    child: Icon(Icons.person_rounded, size: 36, color: theme.primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.email ?? 'Doctor', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text("MediGo Doctor", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),

          const SizedBox(height: 32),

          Text(translations.schedule.toUpperCase(), style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _buildSettingTile(
                  icon: Icons.event_available_rounded,
                  title: translations.manageAvailability,
                  onTap: () => widget.doctorBigId != null ? Navigator.of(context).push(MaterialPageRoute(builder: (context) => AvailabilityPage(doctorBigId: widget.doctorBigId!))) : null,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildSettingTile(
                  icon: Icons.event_busy_rounded,
                  title: translations.manageLeave,
                  onTap: () => widget.doctorBigId != null ? Navigator.of(context).push(MaterialPageRoute(builder: (context) => ManageLeavePage(doctorBigId: widget.doctorBigId!))) : null,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 24),

          Text(translations.appSettings.toUpperCase(), style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: theme.primaryColor),
                  ),
                  title: Text(translations.darkMode),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                      _updateTheme(value);
                    },
                    activeColor: theme.primaryColor,
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildSettingTile(
                  icon: Icons.language_rounded,
                  title: translations.language,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LanguagePage())),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 32),

          ElevatedButton.icon(
            icon: const Icon(Icons.logout_rounded),
            label: Text(translations.signOut),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              foregroundColor: Colors.red,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () async {
              await supabase.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
              }
            },
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildSettingTile({required IconData icon, required String title, required VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }
}