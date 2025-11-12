// lib/main_screen.dart

import 'package:flutter/material.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';
import 'package:medigo_doctor/main.dart'; // For supabase
import 'package:medigo_doctor/pages/dashboard_page.dart';
import 'package:medigo_doctor/pages/profile_page.dart';
import 'package:medigo_doctor/pages/schedule_page.dart';
import 'package:medigo_doctor/pages/settings_page.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

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

  // --- vvv THIS FUNCTION IS UPDATED vvv ---
  Future<Map<String, dynamic>?> _fetchDoctorProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return null;
    }
    try {
      // 1. REVERTED: Select 'name' from the doctors table
      final data = await supabase
          .from('doctors')
          .select('id, name') // <-- CHANGED BACK
          .eq('user_id', user.id)
          .maybeSingle(); 

      if (data != null && mounted) {
        setState(() {
          _doctorBigId = data['id'];
        });
        return data;
      } else {
        if (mounted) {
          print('No doctor record found for user: ${user.id}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Could not find matching doctor profile.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }
    } catch (e) {
      print('Error fetching doctor profile: $e');
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error fetching profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
      }
      return null;
    }
  }
  // --- ^^^ THIS FUNCTION IS UPDATED ^^^ ---

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

  AppBar _buildAppBar(
      BuildContext context, String title, AppLocalizations translations) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return AppBar(
      leading: _selectedIndex == 0
          ? IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              tooltip: translations.profile,
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
                if (result == true) {
                  setState(() {
                    _doctorProfileFuture = _fetchDoctorProfile();
                  });
                }
              },
            )
          : null,
      title: _selectedIndex == 0
          // --- vvv THIS WIDGET IS UPDATED vvv ---
          ? FutureBuilder<Map<String, dynamic>?>(
              future: _doctorProfileFuture,
              builder: (context, snapshot) {
                // 2. REVERTED: Use 'name' from snapshot
                String name = '...';
                if (snapshot.hasData && snapshot.data != null) {
                  name = snapshot.data!['name'] ?? 'Doctor';
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translations.welcome,
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      name, // <-- CHANGED BACK
                    ),
                  ],
                );
              },
            )
          // --- ^^^ THIS WIDGET IS UPDATED ^^^ ---
          : Text(
              title,
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
      automaticallyImplyLeading: _selectedIndex != 0,
    );
  }

  Future<void> _updateTheme(bool isDark) async {
    final themeString = !isDark ? 'Dark' : 'Light'; // Toggled value
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
}