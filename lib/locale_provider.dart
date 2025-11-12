// lib/locale_provider.dart

import 'package:flutter/material.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';

class LocaleProvider extends ChangeNotifier {
  // Default to English
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale newLocale) {
    // Check if the language is supported
    if (!AppLocalizations.supportedLocales.contains(newLocale)) {
      return; // If not, do nothing
    }

    _locale = newLocale;
    notifyListeners(); // Tell the app to rebuild with the new language
  }
}