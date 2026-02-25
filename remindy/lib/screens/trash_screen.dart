import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/reminder_provider.dart';
import '../services/undo_queue.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReminderProvider>(context);
    final items = provider.trashItems;

    return Scaffold(
      appBar: AppBar(title: const Text('Trash')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: items.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 96,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Trash is empty',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text('Deleted notes will appear here'),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final r = items[i];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(r.title),
                      subtitle: Text(
                        r.description.isNotEmpty
                            ? r.description
                            : DateFormat.yMd().add_jm().format(r.createdAt),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Restore',
                            icon: const Icon(Icons.restore),
                            onPressed: () {
                              provider.restoreReminder(r.id);
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Restored'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            tooltip: 'Delete permanently',
                            icon: const Icon(Icons.delete_forever),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Delete permanently?'),
                                  content: const Text(
                                    'This will remove the note forever.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(c).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(c).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                final backup = provider
                                    .deletePermanentlyWithBackup(r.id);
                                if (backup != null) {
                                  UndoQueue.instance.push(
                                    UndoAction(
                                      message: 'Deleted permanently',
                                      onUndo: () =>
                                          provider.insertReminder(backup),
                                      duration: const Duration(seconds: 5),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
