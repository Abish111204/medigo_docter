// lib/widgets/appointment_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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


    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '$formattedTime - $patientName',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (token != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$token',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${translations.age}: $age   •   ${translations.gender}: $gender',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  StatusBadge(status: status),
                  Row(
                    children: [
                      Text(
                        'View Details', // You can translate this
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// --- NEW WIDGET: Status Badge ---
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'Cancelled':
        color = Colors.red;
        text = translations.statusCancelled;
        icon = Icons.cancel;
        break;
      case 'Completed':
        color = Colors.grey;
        text = translations.statusCompleted;
        icon = Icons.check_circle;
        break;
      case 'Missed':
        color = Colors.orange;
        text = translations.statusMissed; 
        icon = Icons.error_outline;
        break;
      case 'Confirmed':
      case 'Upcoming':
      default:
        color = Colors.green;
        text = 'Upcoming'; // Default
        icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
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