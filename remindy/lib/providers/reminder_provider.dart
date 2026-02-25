import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  final List<Reminder> _items = [];
  final _uuid = const Uuid();

  static const _prefsKey = 'reminders_json';

  ReminderProvider() {
    _loadFromPrefs();
  }

  // Public items: exclude deleted (soft-deleted) notes
  List<Reminder> get items =>
      List.unmodifiable(_items.where((r) => !r.isDeleted));

  // Return all items including deleted
  List<Reminder> get allItems => List.unmodifiable(_items);

  void addReminder(
    String title,
    DateTime? dueAt,
    String type, {
    String description = '',
  }) {
    final r = Reminder(
      id: _uuid.v4(),
      title: title,
      description: description,
      dueAt: dueAt,
      type: type,
    );
    _items.add(r);
    _saveToPrefs();
    // schedule notification if dueAt provided
    if (r.dueAt != null) {
      NotificationService.instance.scheduleReminder(r).catchError((e) {
        if (kDebugMode) print('Schedule notif error: $e');
      });
    }
    notifyListeners();
  }

  void updateReminder(Reminder reminder) {
    final idx = _items.indexWhere((r) => r.id == reminder.id);
    if (idx >= 0) {
      // preserve createdAt
      final existing = _items[idx];
      _items[idx] = Reminder(
        id: reminder.id,
        title: reminder.title,
        description: reminder.description,
        createdAt: existing.createdAt,
        dueAt: reminder.dueAt,
        type: reminder.type,
        isCompleted: reminder.isCompleted,
        isDeleted: reminder.isDeleted,
      );
      // reschedule notification for updated reminder
      NotificationService.instance.cancelReminder(reminder.id).catchError((e) {
        if (kDebugMode) print('Cancel notif error: $e');
      });
      if (reminder.dueAt != null &&
          !reminder.isDeleted &&
          !reminder.isCompleted) {
        NotificationService.instance.scheduleReminder(_items[idx]).catchError((
          e,
        ) {
          if (kDebugMode) print('Schedule notif error: $e');
        });
      }
      notifyListeners();
      _saveToPrefs();
    }
  }

  // Soft delete: move to Trash
  void removeReminder(String id) {
    final idx = _items.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      _items[idx].isDeleted = true;
      // cancel scheduled notification for soft-deleted item
      NotificationService.instance.cancelReminder(id).catchError((e) {
        if (kDebugMode) print('Cancel notif error: $e');
      });
      _saveToPrefs();
      notifyListeners();
    }
  }

  // Permanently delete
  void deletePermanently(String id) {
    _items.removeWhere((r) => r.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  // Permanently delete but return the removed item for possible undo
  Reminder? deletePermanentlyWithBackup(String id) {
    final idx = _items.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      final removed = _items.removeAt(idx);
      // cancel notification when permanently deleted
      NotificationService.instance.cancelReminder(id).catchError((e) {
        if (kDebugMode) print('Cancel notif error: $e');
      });
      _saveToPrefs();
      notifyListeners();
      return removed;
    }
    return null;
  }

  // Insert an existing reminder object (used for undoing permanent delete)
  void insertReminder(Reminder reminder) {
    _items.add(reminder);
    _saveToPrefs();
    // schedule notification when reinserting (undo)
    if (reminder.dueAt != null &&
        !reminder.isDeleted &&
        !reminder.isCompleted) {
      NotificationService.instance.scheduleReminder(reminder).catchError((e) {
        if (kDebugMode) print('Schedule notif error: $e');
      });
    }
    notifyListeners();
  }

  // Restore from trash
  void restoreReminder(String id) {
    final idx = _items.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      _items[idx].isDeleted = false;
      // reschedule notification on restore
      final r = _items[idx];
      if (r.dueAt != null && !r.isCompleted) {
        NotificationService.instance.scheduleReminder(r).catchError((e) {
          if (kDebugMode) print('Schedule notif error: $e');
        });
      }
      _saveToPrefs();
      notifyListeners();
    }
  }

  void toggleCompleted(String id) {
    final idx = _items.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      _items[idx].isCompleted = !_items[idx].isCompleted;
      _saveToPrefs();
      notifyListeners();
    }
  }

  int get completedCount =>
      _items.where((r) => r.isCompleted && !r.isDeleted).length;

  double get completionRate => _items.where((r) => !r.isDeleted).isEmpty
      ? 0
      : completedCount / _items.where((r) => !r.isDeleted).length;

  // Convenience getters for tab filters
  List<Reminder> get todayItems {
    final now = DateTime.now();
    return _items
        .where((r) => !r.isDeleted && r.dueAt != null)
        .where(
          (r) =>
              r.dueAt!.year == now.year &&
              r.dueAt!.month == now.month &&
              r.dueAt!.day == now.day,
        )
        .toList();
  }

  List<Reminder> get completedItems =>
      _items.where((r) => r.isCompleted && !r.isDeleted).toList();

  List<Reminder> get trashItems => _items.where((r) => r.isDeleted).toList();

  Reminder? getById(String id) {
    try {
      return _items.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _items.map((r) => r.toJson()).toList();
      await prefs.setString(_prefsKey, jsonEncode(list));
    } catch (e) {
      if (kDebugMode) print('Save prefs error: $e');
    }
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) {
        // seed defaults
        addReminder(
          'Project proposal',
          DateTime.now().add(const Duration(hours: 6)),
          'Work',
          description: 'Prepare slides and outline',
        );
        addReminder(
          'Buy groceries',
          DateTime.now().add(const Duration(days: 1, hours: 2)),
          'Personal',
          description: 'Milk, eggs, bread',
        );
        return;
      }
      final data = jsonDecode(raw) as List<dynamic>;
      _items.clear();
      for (final e in data) {
        _items.add(Reminder.fromJson(Map<String, dynamic>.from(e as Map)));
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Load prefs error: $e');
    }
  }
}
