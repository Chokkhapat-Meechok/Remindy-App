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
  final _descController = TextEditingController();
  DateTime _time = DateTime.now();
  String _type = 'Work';
  bool _hasTitle = false;
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();

  bool get isEditing => widget.reminder != null;

  final List<String> _types = const ['Work', 'Personal'];

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final r = widget.reminder!;
      _titleController.text = r.title;
      _time = r.dueAt ?? DateTime.now();
      _type = r.type;
      _descController.text = r.description;
      _hasTitle = r.title.trim().isNotEmpty;
    }
    _titleController.addListener(() {
      final nonEmpty = _titleController.text.trim().isNotEmpty;
      if (nonEmpty != _hasTitle) setState(() => _hasTitle = nonEmpty);
    });
    _titleFocus.addListener(() => setState(() {}));
    _descFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _titleFocus.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Reminder' : 'Add Reminder'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: cs.onSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Section
              Text('Title', style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                ),
                child: TextField(
                  focusNode: _titleFocus,
                  controller: _titleController,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18, // 👈 ค่านี้ทำให้กลางจริง
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Description Section
              Text('Description', style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 120),
                  child: TextField(
                    focusNode: _descFocus,
                    controller: _descController,
                    minLines: 4,
                    maxLines: 8,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Time Section
              Text('Time', style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(DateFormat.yMMMd().add_jm().format(_time)),
                      ),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Category Section
              Text('Category', style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: _types.map((t) {
                    final selected = t == _type;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _type = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? cs.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              t,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : cs.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _hasTitle ? _save : null,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              elevation: 0,
              backgroundColor: _hasTitle
                  ? cs.primary
                  : cs.primary.withAlpha((0.4 * 255).round()),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              isEditing ? 'Save' : 'Add Reminder',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
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
    if (date == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_time),
    );
    if (t == null || !mounted) return;
    setState(
      () => _time = DateTime(date.year, date.month, date.day, t.hour, t.minute),
    );
  }

  void _save() {
    if (!_hasTitle) return;
    final provider = Provider.of<ReminderProvider>(context, listen: false);
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    if (isEditing) {
      final r = widget.reminder!;
      final updated = Reminder(
        id: r.id,
        title: title,
        description: desc,
        dueAt: _time,
        type: _type,
        isCompleted: r.isCompleted,
        isDeleted: r.isDeleted,
      );
      provider.updateReminder(updated);
    } else {
      provider.addReminder(title, _time, _type, description: desc);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
