// lib/main_screen.dart

import 'package:flutter/material.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';
import 'package:medigo_doctor/main.dart'; // For supabase
import 'package:medigo_doctor/pages/dashboard_page.dart';
import 'package:medigo_doctor/pages/schedule_page.dart';
import 'package:medigo_doctor/pages/settings_page.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'login_page.dart'; 

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  Future<Map<String, dynamic>?>? _doctorProfileFuture;
  int? _doctorBigId; // This is the 'id' from the doctors table

  @override
  void initState() {
    super.initState();
    _doctorProfileFuture = _fetchDoctorProfile();
  }

  Future<Map<String, dynamic>?> _fetchDoctorProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return null;
    }
    try {
      final data = await supabase
          .from('doctors')
          .select('id, name') 
          .eq('user_id', user.id)
          .single();
      
      if (mounted) {
        setState(() {
          _doctorBigId = data['id']; 
        });
      }
      return data;
    } catch (e) {
      print('Error fetching doctor profile: $e');
      return null;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    
    final List<String> pageTitles = [
      translations.dashboard,
      translations.schedule,
      translations.settings,
    ];

    return Scaffold(
      appBar: _buildAppBar(context, pageTitles[_selectedIndex], translations),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              DashboardPage(doctorBigId: _doctorBigId),
              SchedulePage(doctorBigId: _doctorBigId),
              // Pass the doctor ID to settings
              SettingsPage(doctorBigId: _doctorBigId),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: translations.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month_outlined),
            activeIcon: const Icon(Icons.calendar_month),
            label: translations.schedule,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: translations.settings,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, String title, AppLocalizations translations) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return AppBar(
      title: _selectedIndex == 0
          ? FutureBuilder<Map<String, dynamic>?>(
              future: _doctorProfileFuture,
              builder: (context, snapshot) {
                String name = snapshot.hasData ? (snapshot.data!['name'] ?? 'Doctor') : '...';
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.person_outline,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translations.welcome, // <-- FIXED KEY
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            )
          : Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
      actions: [
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
          onPressed: () {
            final newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
            themeProvider.setThemeMode(newMode);
            _updateTheme(isDarkMode); // Save preference
          },
        ),
      ],
      automaticallyImplyLeading: false,
    );
  }

  // Copied this from your original main.dart
  Future<void> _updateTheme(bool isDark) async {
    final themeString = !isDark ? 'Dark' : 'Light'; // Toggled value
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      // Assumes theme is stored on 'profiles' table
      await supabase.from('profiles').update({ 
        'theme': themeString,
      }).eq('id', userId);
    } catch (e) {
      print('Error saving theme: $e');
    }
  }
}