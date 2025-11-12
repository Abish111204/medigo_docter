// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/generated/app_localizations.dart';
import 'theme_provider.dart';
import 'locale_provider.dart'; // <-- 1. IMPORT
import 'splash_screen.dart'; 

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
    // --- 2. ADD MultiProvider ---
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
      ],
      child: const DoctorApp(),
    )
  );
}

// --- App Theme (Same as Patient App) ---
class DoctorApp extends StatelessWidget {
  const DoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- 3. LISTEN TO PROVIDERS ---
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

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
      cardColor: cardColorLight, dialogTheme: DialogThemeData(backgroundColor: scaffoldBgLight),
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
      cardColor: cardColorDark, dialogTheme: DialogThemeData(backgroundColor: scaffoldBgDark),
    );
    // --- END OF THEMES ---

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'MediGo Doctor Portal',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      // --- 4. SET THE LOCALE ---
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(), // <-- This is now the only home
    );
  }
}