// lib/pages/language_page.dart

import 'package:flutter/material.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';
import 'package:medigo_doctor/main.dart'; // For supabase
import 'package:medigo_doctor/locale_provider.dart'; // <-- IMPORT
import 'package:provider/provider.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String _selectedLanguage = 'English';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLanguage();
  }

  Future<void> _fetchLanguage() async {
    setState(() { _isLoading = true; });
    try {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase
          .from('profiles')
          .select('language')
          .eq('id', userId)
          .single();
      if (mounted && data['language'] != null) {
        setState(() {
          _selectedLanguage = data['language'];
        });
      }
    } catch (e) {
      print('Error fetching language: $e');
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _saveLanguage(String langName, String langCode) async {
    // If it's already selected, do nothing
    if (langName == _selectedLanguage) {
       Navigator.of(context).pop();
       return;
    }

    setState(() { _isLoading = true; });
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase
          .from('profiles')
          .update({'language': langName})
          .eq('id', userId);
      
      if (mounted) {
        // --- THIS IS THE FIX ---
        // Call the provider to change the app's language NOW
        Provider.of<LocaleProvider>(context, listen: false)
            .setLocale(Locale(langCode));
        // --- END OF FIX ---

        setState(() {
          _selectedLanguage = langName;
          _isLoading = false;
        });

        Navigator.of(context).pop();
      }

    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving language: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(translations.language),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) => _saveLanguage(value!, 'en'),
            ),
            RadioListTile<String>(
              title: const Text('മലയാളം (Malayalam)'),
              value: 'Malayalam',
              groupValue: _selectedLanguage,
              onChanged: (value) => _saveLanguage(value!, 'ml'),
            ),
            RadioListTile<String>(
              title: const Text('हिन्दी (Hindi)'),
              value: 'Hindi',
              groupValue: _selectedLanguage,
              onChanged: (value) => _saveLanguage(value!, 'hi'),
            ),
          ],
        ),
    );
  }
}