/*
 * ========================================
 * MEDIGO - DOCTOR PORTAL (REFACTORED)
 * ========================================
 *
 * --- FIXES APPLIED (v14) ---
 * 1. (MainScreen): Replaced IndexedStack with a simple
 * page builder. This forces pages to reload data
 * when their tab is tapped, ensuring the schedule
 * is always up-to-date.
 * 2. (MainScreen): The main AppBar is now used for all pages.
 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/generated/app_localizations.dart';
import 'theme_provider.dart';
// --- Importing the separated pages ---
import 'pages/dashboard_page.dart';
import 'pages/schedule_page.dart';
import 'pages/settings_page.dart';

// --- Supabase Setup ---
late final SupabaseClient supabase;

// --- App Navigation ---
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://unhpgshvbqbxrpjswgak.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVuaHBnc2h2YnFieHJwanN3Z2FrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIyNDE2MzksImV4cCI6MjA3NzgxNzYzOX0.yb_q6DzgkaYIbeCM_6JiKn_yObYQiIZZHNx0O1Vh4vo',
  );
  supabase = Supabase.instance.client;
  runApp(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const DoctorApp(),
      )
  );
}

// --- App Theme (Same as Patient App) ---
class DoctorApp extends StatelessWidget {
  const DoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    const Color primaryColor = Color(0xFF1976D2);
    const Color primaryColorLight = Color(0xFF63A4FF);
    const Color cardColorLight = Colors.white;
    const Color cardColorDark = Color(0xFF1E1E1E);
    const Color scaffoldBgLight = Color(0xFFF4F7FB);
    const Color scaffoldBgDark = Color(0xFF121212);
    final textTheme = GoogleFonts.manropeTextTheme(Theme.of(context).textTheme);

    // --- LIGHT THEME ---
    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: Colors.white,
      ),
      fontFamily: textTheme.bodyMedium?.fontFamily,
      textTheme: textTheme.copyWith(
        displaySmall: textTheme.displaySmall?.copyWith(color: Colors.black87),
        headlineSmall: textTheme.headlineSmall?.copyWith(color: Colors.black87),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBgLight,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: textTheme.headlineMedium?.copyWith(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        color: cardColorLight,
        shadowColor: Colors.grey.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: cardColorLight,
        showUnselectedLabels: true,
        elevation: 5,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: textTheme.bodySmall,
      ),
      cardColor: cardColorLight, dialogTheme: const DialogThemeData(backgroundColor: scaffoldBgLight),
    );

    // --- DARK THEME ---
    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColorLight, // Use the lighter blue for contrast
      scaffoldBackgroundColor: scaffoldBgDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColorLight,
        onPrimary: Colors.black, // Text on buttons
        background: scaffoldBgDark,
      ),
      fontFamily: textTheme.bodyMedium?.fontFamily,
      textTheme: textTheme.copyWith(
        displaySmall: textTheme.displaySmall?.copyWith(color: Colors.white),
        headlineSmall: textTheme.headlineSmall?.copyWith(color: Colors.white),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBgDark, // Match background
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: textTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        color: cardColorDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          backgroundColor: primaryColorLight,
          foregroundColor: Colors.black, // Dark text on light blue
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColorDark, // Use card color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColorLight, width: 2),
        ),
        labelStyle: textTheme.bodyLarge?.copyWith(color: Colors.grey.shade400),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primaryColorLight,
        unselectedItemColor: Colors.grey.shade400,
        backgroundColor: cardColorDark,
        showUnselectedLabels: true,
        elevation: 5,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: textTheme.bodySmall,
      ),
      cardColor: cardColorDark, dialogTheme: const DialogThemeData(backgroundColor: scaffoldBgDark),
    );
    // --- END OF THEMES ---

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'MediGo Doctor Portal',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(),
    );
  }
}

// --- Main Screen (with Bottom Navigation) ---
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _doctorName = 'Doctor'; // Default name

  // --- UPDATED: Pages are now imported ---
  final List<Widget> _pages = [
    const DashboardPage(),
    const SchedulePage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchDoctorName();
  }

  Future<void> _fetchDoctorName() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await supabase
          .from('doctors')
          .select('name')
          .eq('user_id', userId);

      if (data.isNotEmpty && mounted) {
        setState(() {
          _doctorName = data[0]['name'];
        });
      }
    } catch (e) {
      print('Error fetching doctor name: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    final List<String> pageTitles = [
      translations.dashboard,
      translations.schedule,
      translations.settings,
    ];

    return Scaffold(
      // --- THIS IS THE FIX ---
      // The AppBar is now shown on all pages.
      appBar: AppBar( 
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                pageTitles[_selectedIndex],
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
            ),
            if (_selectedIndex == 0) // Only show on dashboard
              Text(
                  'Welcome back, $_doctorName',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[600])
              ),
          ],
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
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await supabase.auth.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),
      // --- THIS IS THE FIX for fast refreshing ---
      // Replaced IndexedStack with a simple getter
      body: _pages[_selectedIndex],
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
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
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


// --- SPLASH SCREEN ---
// ... (This file is unchanged) ...

// --- LOGIN PAGE ---
// ... (This file is unchanged) ...


// --- SPLASH SCREEN ---
// ... (This file is unchanged, you already have the correct version)
// ...

// --- LOGIN PAGE ---
// ... (This file is unchanged, you already have the correct version)
// ...


// --- SPLASH SCREEN ---
// ... (This file is unchanged, you already have the correct version)
// ...

// --- LOGIN PAGE ---
// ... (This file is unchanged, you already have the correct version)
// ...


// --- SPLASH SCREEN ---
// ... (This file is unchanged, no need to copy)
// ...

// --- LOGIN PAGE ---
// ... (This file is unchanged, no need to copy)
// ...


// --- SPLASH SCREEN ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final session = supabase.auth.currentSession;
    if (session == null) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()));
    } else {
      try {
        final doctorData = await supabase
            .from('doctors')
            .select('id, theme') // Also fetch theme
            .eq('user_id', session.user.id);

        if (doctorData.isNotEmpty && mounted) {
          final doctor = doctorData[0];

          final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
          final savedTheme = doctor['theme'] ?? 'Light';
          themeProvider.setThemeMode(savedTheme == 'Dark' ? ThemeMode.dark : ThemeMode.light);

          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainScreen()));
        } else {
          // No doctor found for this user
          await supabase.auth.signOut();
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginPage(isNotDoctor: true)));
        }
      } catch (e) {
        // This catches other errors
        await supabase.auth.signOut();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage(isNotDoctor: true)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_rounded,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'MediGo Doctor Portal',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

// --- LOGIN PAGE ---
class LoginPage extends StatefulWidget {
  final bool isNotDoctor;
  const LoginPage({super.key, this.isNotDoctor = false});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.isNotDoctor) {
      _errorMessage = "This login is for doctors only.";
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted && response.user != null) {
        final doctorData = await supabase
            .from('doctors')
            .select('id')
            .eq('user_id', response.user!.id);

        if (doctorData.isNotEmpty && mounted) {
          try {
            final profileData = await supabase
                .from('profiles')
                .select('theme')
                .eq('id', response.user!.id)
                .single();

            final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
            final savedTheme = profileData['theme'] ?? 'Light';
            themeProvider.setThemeMode(savedTheme == 'Dark' ? ThemeMode.dark : ThemeMode.light);
          } catch (e) {
            print("Couldn't fetch theme, using default.");
          }

          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainScreen()));
        } else {
          await supabase.auth.signOut();
          setState(() {
            _errorMessage = "This account does not have doctor permissions.";
            _isLoading = false;
          });
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "This account does not have doctor permissions.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.medical_services_rounded,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'MediGo Doctor Portal',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to view your appointments',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                    value!.isEmpty || !value.contains('@')
                        ? 'Please enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) => value!.length < 6
                        ? 'Password must be at least 6 characters'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: _signIn,
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}