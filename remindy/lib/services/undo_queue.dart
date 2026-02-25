import 'dart:collection';
import 'package:flutter/material.dart';
import '../app.dart' show scaffoldMessengerKey;

class UndoAction {
  final String message;
  final VoidCallback onUndo;
  final Duration duration;

  UndoAction({
    required this.message,
    required this.onUndo,
    this.duration = const Duration(seconds: 4),
  });
}

/// Global Undo queue that shows one styled SnackBar at a time and allows
/// undoing each queued action.
class UndoQueue {
  UndoQueue._();
  static final UndoQueue instance = UndoQueue._();

  final Queue<UndoAction> _queue = Queue();
  bool _active = false;

  void push(UndoAction action) {
    _queue.addLast(action);
    _tryProcessNext();
  }

  void _tryProcessNext() {
    if (_active || _queue.isEmpty) return;
    _active = true;
    final action = _queue.removeFirst();

    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) {
      // If no messenger available, just execute timeout without undo
      Future.delayed(action.duration, () => _active = false);
      return;
    }

    final snack = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      duration: action.duration,
      backgroundColor: Colors.grey.shade900,
      content: Row(
        children: [
          const Icon(Icons.undo, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              action.message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      action: SnackBarAction(
        label: 'Undo',
        textColor: Colors.amber[300],
        onPressed: () {
          try {
            action.onUndo();
          } catch (_) {}
        },
      ),
    );

    messenger.clearSnackBars();
    messenger.showSnackBar(snack).closed.then((_) {
      _active = false;
      // process next queued action
      Future.microtask(_tryProcessNext);
    });
  }
}
