// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/generated/app_localizations.dart';
import 'theme_provider.dart';
import 'locale_provider.dart';
import 'splash_screen.dart';

// --- Supabase Setup ---
late final SupabaseClient supabase;

// --- App Navigation ---
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://unhpgshvbqbxrpjswgak.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVuaHBnc2h2YnFieHJwanN3Z2FrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIyNDE2MzksImV4cCI6MjA3NzgxNzYzOX0.yb_q6DzgkaYIbeCM_6JiKn_yObYQiIZZHNx0O1Vh4vo',
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

// --- NEW PROFESSIONAL THEME COLORS ---
const Color primaryColor = Color(0xFF1976D2); // Your existing strong blue
const Color primaryColorLight = Color(0xFF63A4FF); // Your existing light blue
const Color secondaryColor = Color(0xFF00897B); // A new professional teal
const Color secondaryColorLight = Color(0xFF4DB6AC); // A lighter teal
const Color cardColorLight = Colors.white;
const Color cardColorDark = Color(0xFF1E1E1E);
const Color scaffoldBgLight = Color(0xFFF4F7FB);
const Color scaffoldBgDark = Color(0xFF121212);

class DoctorApp extends StatelessWidget {
  const DoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    // --- BASE TEXT THEME ---
    final baseTextTheme =
        GoogleFonts.manropeTextTheme(Theme.of(context).textTheme);

    // --- UPDATED LIGHT THEME ---
    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        surface: cardColorLight,
        background: scaffoldBgLight,
      ),
      fontFamily: baseTextTheme.bodyMedium?.fontFamily,
      textTheme: baseTextTheme.copyWith(
        displaySmall:
            baseTextTheme.displaySmall?.copyWith(color: Colors.black87),
        headlineSmall:
            baseTextTheme.headlineSmall?.copyWith(color: Colors.black87),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      appBarTheme: AppBarTheme(
        // --- MODIFIED ---
        backgroundColor: primaryColor, // Use primary color for App Bar
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white), // White icons
        titleTextStyle: baseTextTheme.headlineMedium?.copyWith(
          color: Colors.white, // White title
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: cardColorLight,
        shadowColor: Colors.grey.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      // --- MODIFIED ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          backgroundColor: secondaryColor, // Use secondary color for buttons
          foregroundColor: Colors.white,
          textStyle:
              baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
        labelStyle:
            baseTextTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
        hintStyle:
            baseTextTheme.bodyLarge?.copyWith(color: Colors.grey.shade500),
      ),
      // --- MODIFIED ---
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: secondaryColor, // Use secondary color for active item
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: cardColorLight,
        showUnselectedLabels: true,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            baseTextTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: baseTextTheme.bodySmall,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        iconColor: primaryColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
      ),
      cardColor: cardColorLight,
      dialogTheme: const DialogThemeData(backgroundColor: scaffoldBgLight),
    );

    // --- UPDATED DARK THEME ---
    final darkTextTheme = GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme);

    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColorLight,
      scaffoldBackgroundColor: scaffoldBgDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColorLight,
        onPrimary: Colors.black,
        secondary: secondaryColorLight, // Use lighter teal for dark mode
        onSecondary: Colors.black,
        surface: cardColorDark,
        background: scaffoldBgDark,
      ),
      fontFamily: darkTextTheme.bodyMedium?.fontFamily,
      textTheme: darkTextTheme
          .copyWith(
            displaySmall:
                darkTextTheme.displaySmall?.copyWith(color: Colors.white),
            headlineSmall:
                darkTextTheme.headlineSmall?.copyWith(color: Colors.white),
            headlineMedium: darkTextTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )
          .apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor:
            scaffoldBgDark, // Match dark background for a modern feel
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: darkTextTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColorDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade800, width: 1),
        ),
      ),
      // --- MODIFIED ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          backgroundColor:
              secondaryColorLight, // Use light teal for dark mode buttons
          foregroundColor: Colors.black,
          textStyle:
              darkTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColorDark,
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
        labelStyle:
            darkTextTheme.bodyLarge?.copyWith(color: Colors.grey.shade400),
        hintStyle:
            darkTextTheme.bodyLarge?.copyWith(color: Colors.grey.shade500),
      ),
      // --- MODIFIED ---
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor:
            secondaryColorLight, // Use light teal for active item
        unselectedItemColor: Colors.grey.shade400,
        backgroundColor: cardColorDark,
        showUnselectedLabels: true,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            darkTextTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: darkTextTheme.bodySmall,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        iconColor: primaryColorLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondaryColorLight,
        foregroundColor: Colors.black,
      ),
      cardColor: cardColorDark,
      dialogTheme: const DialogThemeData(backgroundColor: scaffoldBgDark),
    );
    // --- END OF THEMES ---

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'MediGo Doctor Portal',
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