// lib/widgets/appointment_card.dart

import 'package:flutter/material.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translations = AppLocalizations.of(context)!;

    // Safely parse data
    final patientName = (appointment['patient_name'] ?? 'No Name').toString();
    final token = appointment['token_number'];
    final age = (appointment['patient_age'] ?? '...').toString();
    final gender = (appointment['patient_gender'] ?? '...').toString();
    final status = (appointment['status'] ?? 'Upcoming').toString();

    String formattedTime = '...';
    try {
      final timeParts = appointment['appointment_time'].toString().split(':');
      final time = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
      formattedTime = time.format(context);
    } catch (e) { /* ignore parse errors */ }

    // --- NEW: Determine accent color based on status ---
    Color accentColor;
    switch (status) {
      case 'Cancelled':
      case 'Missed':
        accentColor = theme.colorScheme.error;
        break;
      case 'Completed':
        accentColor = Colors.grey;
        break;
      case 'Confirmed':
      case 'Upcoming':
      default:
        accentColor = theme.colorScheme.secondary; // Use Teal
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        // --- NEW: Added IntrinsicHeight and Row for the accent bar ---
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- NEW: Accent Bar ---
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              // --- Original Content, but now Expanded ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // --- MODIFIED: Flexible for long names ---
                          Flexible(
                            child: Text(
                              patientName, // Name first
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // --- MODIFIED: Time and Token ---
                          Text(
                            token != null ? '$formattedTime (#$token)' : formattedTime,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${translations.age}: $age   •   ${translations.gender}: $gender',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                              theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          StatusBadge(status: status),
                          // --- MODIFIED: Changed "View Details" to an icon ---
                          Icon(
                            Icons.chevron_right_rounded,
                            color: theme.colorScheme.secondary,
                            size: 28,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- NEW WIDGET: Status Badge (Unchanged from before, but still needed) ---
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'Cancelled':
        color = theme.colorScheme.error;
        text = translations.statusCancelled;
        icon = Icons.cancel_outlined;
        break;
      case 'Completed':
        color = Colors.grey.shade600;
        text = translations.statusCompleted;
        icon = Icons.check_circle_outline;
        break;
      case 'Missed':
        color = Colors.orange.shade700;
        text = translations.statusMissed;
        icon = Icons.error_outline;
        break;
      case 'Confirmed':
      case 'Upcoming':
      default:
        color = theme.colorScheme.secondary; // Use Teal
        text = 'Upcoming'; // Default
        icon = Icons.hourglass_top_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20), // More rounded
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}