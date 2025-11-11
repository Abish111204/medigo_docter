import 'package:flutter/material.dart';
import 'package:medigo_doctor/l10n/generated/app_localizations.dart';

// --- NEW WIDGET: Status Badge ---
// (This widget is unchanged from your version, but included for completeness)
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
      case 'Missed': // <-- This is the new status for expired pending appointments
        color = Colors.orange;
        text = 'Missed'; // You can translate this
        icon = Icons.error_outline;
        break;
      case 'Confirmed':
      case 'Upcoming':
      case 'Pending':
      default:
        // This will now handle '0', '1', etc. if they come from the DB
        bool isPending = status == 'Pending' || status == '0';

        color = isPending ? Colors.green : Colors.blue;
        text = isPending ? 'Pending' : translations.statusConfirmed;
        icon = isPending ? Icons.pending_actions : Icons.check_circle_outline;
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

    // --- LOGIC FOR EXPIRED APPOINTMENTS ---
    DateTime? appointmentDateTime;
    String formattedTime = '...';
    try {
      // 1. Parse date and time
      final date = DateTime.parse(appointment['appointment_date'].toString());
      final timeParts = appointment['appointment_time'].toString().split(':');
      final time = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
      
      // 2. Create full DateTime object
      appointmentDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      formattedTime = time.format(context);

    } catch (e) { /* ignore parse errors */ }

    // 3. Determine status
    final String baseStatus = (appointment['status'] ?? 'Pending').toString();
    String effectiveStatus = baseStatus; // Status to display
    bool isHighlighted = false;

    // 4. Check if expired
    if (baseStatus == 'Pending' && 
        appointmentDateTime != null && 
        appointmentDateTime.isBefore(DateTime.now())) 
    {
      effectiveStatus = 'Missed'; // <-- This is the new logic
      isHighlighted = true;
    }
    // --- END OF LOGIC ---

    // Safely parse other data
    final patientName = (appointment['patient_name'] ?? 'No Name').toString();
    final token = appointment['token_number'];
    final age = (appointment['patient_age'] ?? '...').toString();
    final gender = (appointment['patient_gender'] ?? '...').toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      // --- This is the highlight ---
      shadowColor: isHighlighted ? Colors.orange.shade300 : null,
      elevation: isHighlighted ? 6 : null,
      // --- End of highlight ---
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
                        color: isHighlighted ? Colors.orange.shade800 : theme.primaryColor,
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
                        '${translations.tokenNumber} $token',
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
                '${translations.patientAge}: $age   •   ${translations.gender}: $gender',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- This now uses the 'effectiveStatus' ---
                  StatusBadge(status: effectiveStatus),
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