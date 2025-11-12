// lib/login_page.dart

import 'package:flutter/material.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';
import 'package:medigo_doctor/main.dart'; // For supabase
import 'package:medigo_doctor/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'main_screen.dart'; // This file will be created next
import 'locale_provider.dart';

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

  Future<void> _signIn(AppLocalizations translations) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted && response.user != null) {
        // 1. Check if this user is in the 'doctors' table
        final doctorData = await supabase
            .from('doctors')
            .select('user_id, id') 
            .eq('user_id', response.user!.id)
            .maybeSingle();

        if (doctorData != null && mounted) {
          // 2. Fetch theme and language from 'profiles' table
          try {
            final profileData = await supabase
                .from('profiles')
                .select('theme, language')
                .eq('id', response.user!.id)
                .single();

            final themeProvider =
                Provider.of<ThemeProvider>(context, listen: false);
            final savedTheme = profileData['theme'] ?? 'Light';
            themeProvider.setThemeMode(
                savedTheme == 'Dark' ? ThemeMode.dark : ThemeMode.light);
            
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
            print("Couldn't fetch preferences, using defaults.");
          }

          // 3. Go to the main screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          // 4. If not a doctor, sign out and show error
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
          _errorMessage = "An unexpected error occurred. Please try again.";
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
    final translations = AppLocalizations.of(context)!;
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
                  Image.asset( 
                    'assets/images/logo.png', // Make sure you have this logo
                    height: 100,
                  ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 16),
                  Text(
                    translations.doctorLogin, // <-- FIXED KEY
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: translations.email,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: translations.password,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_passwordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2),
                  const SizedBox(height: 24),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () => _signIn(translations),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          child: Text(translations.signIn),
                        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}