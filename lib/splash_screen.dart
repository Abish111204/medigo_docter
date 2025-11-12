// lib/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:medigo_doctor/main.dart'; // For supabase
import 'package:medigo_doctor/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_page.dart';
import 'main_screen.dart';
import 'locale_provider.dart';

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
        // Check if the user is in the 'doctors' table
        final doctorData = await supabase
            .from('doctors')
            .select('id')
            .eq('user_id', session.user.id)
            .maybeSingle(); // Use maybeSingle to avoid error if empty

        if (doctorData != null && mounted) {
          // User is a doctor, proceed.
          
          // Fetch user preferences from 'profiles' table
          try {
             final profileData = await supabase
                .from('profiles')
                .select('theme, language')
                .eq('id', session.user.id)
                .single();
            
            // Set Theme
            final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
            final savedTheme = profileData['theme'] ?? 'Light';
            themeProvider.setThemeMode(savedTheme == 'Dark' ? ThemeMode.dark : ThemeMode.light);

            // Set Language
            final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
            final savedLang = profileData['language'] ?? 'English';
            if (savedLang == 'Malayalam') {
              localeProvider.setLocale(const Locale('ml'));
            } else if (savedLang == 'Hindi') {
              localeProvider.setLocale(const Locale('hi'));
            } else {
              localeProvider.setLocale(const Locale('en'));
            }

          } catch (e) {
             print("Error fetching preferences: $e");
          }

          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainScreen()));
        } else {
          // Not a doctor, sign out
          await supabase.auth.signOut();
          if (mounted) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage(isNotDoctor: true)));
          }
        }
      } catch (e) {
        // This catches other errors
        if (mounted) {
          print("Error during splash redirect: $e");
          await supabase.auth.signOut();
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginPage(isNotDoctor: true)));
        }
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
            // Use your asset image
            Image.asset('assets/images/logo.png', height: 100),
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