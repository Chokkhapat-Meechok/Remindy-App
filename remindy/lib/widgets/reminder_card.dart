import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/reminder.dart';
import '../providers/reminder_provider.dart';
import '../screens/add_edit_screen.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  const ReminderCard({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReminderProvider>(context, listen: false);
    final color = reminder.type == 'Work'
        ? Colors.blue.shade100
        : Colors.green.shade100;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Slidable(
        key: ValueKey(reminder.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditScreen(reminder: reminder),
                ),
              ),
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => provider.removeReminder(reminder.id),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          color: color,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              reminder.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(DateFormat.yMd().add_jm().format(reminder.time)),
            trailing: Switch(
              value: reminder.isDone,
              onChanged: (_) => provider.toggleDone(reminder.id),
            ),
          ),
        ),
      ),
    );
  }
}
