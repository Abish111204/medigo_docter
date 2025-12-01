import 'package:flutter/material.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';
import 'package:medigo_doctor/main.dart';
import 'package:medigo_doctor/pages/dashboard_page.dart';
import 'package:medigo_doctor/pages/profile_page.dart'; 
import 'package:medigo_doctor/pages/schedule_page.dart';
import 'package:medigo_doctor/pages/settings_page.dart'; 
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  Future<Map<String, dynamic>?>? _doctorProfileFuture;
  int? _doctorBigId;

  @override
  void initState() {
    super.initState();
    _doctorProfileFuture = _fetchDoctorProfile();
  }

  Future<Map<String, dynamic>?> _fetchDoctorProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    try {
      final data = await supabase
          .from('doctors')
          .select('id, name')
          .eq('user_id', user.id)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          _doctorBigId = data['id'];
        });
        return data;
      }
      return null;
    } catch (e) {
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
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                  begin: const Offset(0, 0.05), end: Offset.zero)
                  .animate(animation),
              child: child,
            ),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5))
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard_rounded),
              label: translations.dashboard,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_month_outlined),
              activeIcon: const Icon(Icons.calendar_month_rounded),
              label: translations.schedule,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings_rounded),
              label: translations.settings,
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
        ),
      ),
    );
  }

  AppBar _buildAppBar(
      BuildContext context, String title, AppLocalizations translations) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    return AppBar(
      leading: _selectedIndex == 0
          ? IconButton(
              icon: CircleAvatar(
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                child: Icon(Icons.person_rounded,
                    color: theme.primaryColor, size: 20),
              ),
              tooltip: translations.profile,
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  // --- FIXED: Removed 'const' keyword ---
                  MaterialPageRoute(builder: (context) => ProfilePage()),
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
          ? FutureBuilder<Map<String, dynamic>?>(
              future: _doctorProfileFuture,
              builder: (context, snapshot) {
                String name = snapshot.data?['name'] ?? 'Doctor';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translations.welcome,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16))
                        .animate()
                        .fadeIn(),
                  ],
                );
              },
            )
          : Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: theme.iconTheme.color,
          ),
          onPressed: () {
            final newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
            themeProvider.setThemeMode(newMode);
            _updateTheme(isDarkMode);
          },
        ),
        const SizedBox(width: 8),
      ],
      automaticallyImplyLeading: _selectedIndex != 0,
    );
  }

  Future<void> _updateTheme(bool isDark) async {
    final themeString = !isDark ? 'Dark' : 'Light';
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await supabase
          .from('profiles')
          .update({'theme': themeString}).eq('id', userId);
    } catch (e) {
      print(e);
    }
  }
}