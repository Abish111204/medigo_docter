// lib/pages/edit_profile_page.dart

import 'package:flutter/material.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';
import 'package:medigo_doctor/main.dart'; // For supabase
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profile;
  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.profile['first_name']);
    _lastNameController =
        TextEditingController(text: widget.profile['last_name']);
    _phoneController =
        TextEditingController(text: widget.profile['phone_number']);
    _dobController = TextEditingController(text: widget.profile['dob']);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // --- vvv THIS FUNCTION IS UPDATED vvv ---
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final translations = AppLocalizations.of(context)!;
    final userId = supabase.auth.currentUser!.id;
    
    // Combine names for the 'doctors' table
    final String firstName = _firstNameController.text.trim();
    final String lastName = _lastNameController.text.trim();
    final String combinedName = '$firstName $lastName'.trim();

    try {
      // 1. Update 'profiles' table (This is correct)
      await supabase.from('profiles').update({
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': _phoneController.text.trim(),
        'dob': _dobController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      // 2. REVERTED: Update 'doctors' table with the single 'name' column
      await supabase.from('doctors').update({
        'name': combinedName, // <-- CHANGED BACK
      }).eq('user_id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translations.profileUpdated),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return 'true' to signal success
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  // --- ^^^ THIS FUNCTION IS UPDATED ^^^ ---

  Future<void> _selectDate() async {
    DateTime initialDate;
    try {
      initialDate = DateTime.parse(_dobController.text);
    } catch (e) {
      initialDate = DateTime(2000);
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(translations.editProfile),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // This is for 'profiles.first_name' (CORRECT)
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: translations.firstName, 
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return 'First name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // This is for 'profiles.last_name' (CORRECT)
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: translations.lastName, 
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a last name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: translations.phoneNumber,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dobController,
              decoration: InputDecoration(
                labelText: translations.dob,
                prefixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              readOnly: true,
              onTap: _selectDate,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your date of birth';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    icon: const Icon(Icons.save_outlined),
                    label: Text(translations.saveChanges),
                    onPressed: _updateProfile,
                  ),
          ],
        ),
      ),
    );
  }
}