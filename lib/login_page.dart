import 'package:flutter/material.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';
import 'package:medigo_doctor/main.dart';
import 'package:medigo_doctor/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'main_screen.dart';
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
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted && response.user != null) {
        final doctorData = await supabase
            .from('doctors')
            .select('user_id, id') 
            .eq('user_id', response.user!.id)
            .maybeSingle();

        if (doctorData != null && mounted) {
          try {
            final profileData = await supabase
                .from('profiles')
                .select('theme, language')
                .eq('id', response.user!.id)
                .single();

            final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
            final savedTheme = profileData['theme'] ?? 'Light';
            themeProvider.setThemeMode(savedTheme == 'Dark' ? ThemeMode.dark : ThemeMode.light);
            
            final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
            final savedLang = profileData['language'] ?? 'English';
            if (savedLang == 'Malayalam') localeProvider.setLocale(const Locale('ml'));
            else if (savedLang == 'Hindi') localeProvider.setLocale(const Locale('hi'));
            else localeProvider.setLocale(const Locale('en'));

          } catch (e) { print("Preferences error: $e"); }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          await supabase.auth.signOut();
          setState(() {
            _errorMessage = "Access Denied: Doctor account required.";
            _isLoading = false;
          });
        }
      }
    } on AuthException catch (e) {
      if (mounted) setState(() { _errorMessage = e.message; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _errorMessage = "Unexpected error: $e"; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1576091160550-2187d80a02ff?auto=format&fit=crop&q=80',
              fit: BoxFit.cover,
            ),
          ),
          // 2. Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDark ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.7),
                    isDark ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
          // 3. Login Form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 2),
                    ),
                    child: Icon(
                      Icons.local_hospital_rounded,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                  
                  const SizedBox(height: 16),
                  Text(
                    'MediGo Doctor',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: 1.0
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 40),

                  Card(
                    elevation: 8,
                    color: Theme.of(context).cardTheme.color?.withOpacity(0.9),
                    shadowColor: Colors.black.withOpacity(0.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              translations.doctorLogin,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              translations.signInToContinue,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 32),
                            
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: translations.email,
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                              validator: (value) => (value == null || !value.contains('@')) ? 'Invalid email' : null,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: translations.password,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                                ),
                              ),
                              obscureText: !_passwordVisible,
                              validator: (value) => (value == null || value.length < 6) ? 'Min 6 chars' : null,
                            ),
                            
                            const SizedBox(height: 24),
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              
                            ElevatedButton(
                              onPressed: _isLoading ? null : () => _signIn(translations),
                              child: _isLoading 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                                : Text(translations.signIn.toUpperCase()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}