import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/reminder.dart';

class ReminderProvider extends ChangeNotifier {
  final List<Reminder> _items = [];
  final _uuid = const Uuid();

  ReminderProvider() {
    // Seed sample reminders for a better first-run experience
    if (_items.isEmpty) {
      addReminder(
        'Project proposal',
        DateTime.now().add(const Duration(hours: 6)),
        'Work',
      );
      addReminder(
        'Buy groceries',
        DateTime.now().add(const Duration(days: 1, hours: 2)),
        'Personal',
      );
    }
  }

  List<Reminder> get items => List.unmodifiable(_items);

  void addReminder(String title, DateTime time, String type) {
    final r = Reminder(id: _uuid.v4(), title: title, time: time, type: type);
    _items.add(r);
    notifyListeners();
  }

  void updateReminder(Reminder reminder) {
    final idx = _items.indexWhere((r) => r.id == reminder.id);
    if (idx >= 0) {
      _items[idx] = reminder;
      notifyListeners();
    }
  }

  void removeReminder(String id) {
    _items.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void toggleDone(String id) {
    final idx = _items.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      _items[idx].isDone = !_items[idx].isDone;
      notifyListeners();
    }
  }

  int get completedCount => _items.where((r) => r.isDone).length;

  double get completionRate =>
      _items.isEmpty ? 0 : completedCount / _items.length;
}
