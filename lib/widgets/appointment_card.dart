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
    } catch (e) { /* ignore */ }

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'Cancelled':
      case 'Missed':
        statusColor = Colors.red;
        statusIcon = Icons.cancel_outlined;
        break;
      case 'Completed':
        statusColor = Colors.grey;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'Confirmed':
      case 'Upcoming':
      default:
        statusColor = theme.primaryColor;
        statusIcon = Icons.schedule_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                Container(width: 6, height: 110, color: statusColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedTime,
                                  style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                if (token != null)
                                  Text('Token #$token', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(statusIcon, size: 14, color: statusColor),
                                  const SizedBox(width: 4),
                                  Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey.shade100,
                              child: Icon(Icons.person_rounded, size: 20, color: Colors.grey.shade600),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(patientName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('$age yrs, $gender', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}