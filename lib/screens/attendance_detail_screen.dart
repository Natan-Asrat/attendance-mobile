import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendance_app/models/attendance.dart';

class AttendanceDetailScreen extends StatelessWidget {
  final Attendance attendance;

  const AttendanceDetailScreen({Key? key, required this.attendance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Details'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow(context, Icons.event, 'Event', attendance.event.title),
                const SizedBox(height: 12),
                _buildDetailRow(context, Icons.person, 'Attendee', attendance.attendee.name),
                const SizedBox(height: 12),
                _buildDetailRow(context, Icons.email, 'Email', attendance.attendee.email),
                const SizedBox(height: 12),
                _buildDetailRow(context, Icons.phone, 'Phone', attendance.attendee.phone),
                const SizedBox(height: 12),
                _buildDetailRow(context, Icons.badge, 'Display Name', attendance.displayName),
                const SizedBox(height: 12),
                _buildDetailRow(context, Icons.check_circle, 'Status',
                    attendance.valid ? 'Valid' : 'Invalid',
                    color: attendance.valid ? Colors.green : Colors.red),
                const SizedBox(height: 12),
                _buildDetailRow(
                    context,
                    Icons.access_time,
                    'Time',
                    DateFormat.yMMMd().add_jm().format(attendance.createdAt)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: color ?? Colors.black87,
                      fontSize: 16,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}