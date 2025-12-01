import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/generated/app_localizations.dart';
import 'theme_provider.dart';
import 'locale_provider.dart';
import 'splash_screen.dart';

late final SupabaseClient supabase;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://unhpgshvbqbxrpjswgak.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVuaHBnc2h2YnFieHJwanN3Z2FrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIyNDE2MzksImV4cCI6MjA3NzgxNzYzOX0.yb_q6DzgkaYIbeCM_6JiKn_yObYQiIZZHNx0O1Vh4vo',
  );
  supabase = Supabase.instance.client;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
      ],
      child: const DoctorApp(),
    ),
  );
}

// --- PROFESSIONAL MEDICAL PALETTE ---
const Color primaryColor = Color(0xFF009688); // Professional Teal
const Color primaryDark = Color(0xFF00796B);
const Color secondaryColor = Color(0xFF37474F); // Blue Grey
const Color accentColor = Color(0xFFFF6F00); // Amber/Orange for actions

const Color surfaceLight = Color(0xFFF8F9FA); // Very light grey-white
const Color surfaceDark = Color(0xFF121212);
const Color cardDark = Color(0xFF1E1E1E);

class DoctorApp extends StatelessWidget {
  const DoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    // Use Lato for clean, professional readability
    final textTheme = GoogleFonts.latoTextTheme();

    // --- LIGHT THEME ---
    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: surfaceLight,
      textTheme: textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: Colors.white,
        background: surfaceLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceLight,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: secondaryColor),
        titleTextStyle: GoogleFonts.lato(
          color: secondaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: Colors.white,
        showUnselectedLabels: true,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.lato(fontWeight: FontWeight.w500, fontSize: 12),
      ),
      useMaterial3: true,
    );

    // --- DARK THEME ---
    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: surfaceDark,
      textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: const Color(0xFF80CBC4),
        tertiary: accentColor,
        surface: cardDark,
        background: surfaceDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.lato(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardDark,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        hintStyle: TextStyle(color: Colors.grey.shade500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: const Color(0xFF80CBC4),
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: const Color(0xFF1E1E1E),
        showUnselectedLabels: true,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.lato(fontWeight: FontWeight.w500, fontSize: 12),
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'MediGo Doctor',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      locale: localeProvider.locale,
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