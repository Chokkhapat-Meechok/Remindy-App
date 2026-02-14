import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/reminder_provider.dart';
import '../models/reminder.dart';

class AddEditScreen extends StatefulWidget {
  final Reminder? reminder;
  const AddEditScreen({super.key, this.reminder});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime _time = DateTime.now();
  String _type = 'Work';

  bool get isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final r = widget.reminder!;
      _titleController.text = r.title;
      _time = r.time;
      _type = r.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Time: ${DateFormat.yMd().add_jm().format(_time)}',
                    ),
                  ),
                  TextButton(onPressed: _pickTime, child: const Text('Pick')),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _type,
                items: const [
                  DropdownMenuItem(value: 'Work', child: Text('Work')),
                  DropdownMenuItem(value: 'Personal', child: Text('Personal')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'Work'),
              ),
              const Spacer(),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _time,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (!mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_time),
    );
    if (t == null) return;
    if (!mounted) return;
    setState(
      () => _time = DateTime(date.year, date.month, date.day, t.hour, t.minute),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final provider = Provider.of<ReminderProvider>(context, listen: false);
    final title = _titleController.text.trim();
    if (isEditing) {
      final r = widget.reminder!;
      r.title = title;
      r.time = _time;
      r.type = _type;
      provider.updateReminder(r);
    } else {
      provider.addReminder(title, _time, _type);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
