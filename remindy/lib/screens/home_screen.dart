import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../services/auth_service.dart';
import '../providers/reminder_provider.dart';
import '../models/reminder.dart';
import 'add_edit_screen.dart';
import 'trash_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const primaryColor = Color(0xFF3B82F6);
  static const secondaryColor = Color(0xFF10B981);
  static const backgroundColor = Color(0xFFF9FAFB);
  static const inactiveColor = Color(0xFF9CA3AF);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<int> _filterIndex = ValueNotifier<int>(0);
  int _selectedIndex = 0;

  @override
  void dispose() {
    _filterIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReminderProvider>(context);

    Widget buildHeader(ReminderProvider p) {
      final textTheme = Theme.of(context).textTheme;
      final pending = p.items.where((r) => !r.isCompleted).length;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remindy',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pending > 0
                        ? '$pending task pending'
                        : 'Stay focused today',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Consumer<AuthService>(
              builder: (context, auth, _) {
                final loggedIn = auth.isLoggedIn;
                if (loggedIn) {
                  final name = auth.displayName ?? 'U';
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 2),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                        name[0].toUpperCase(),
                        style: textTheme.titleMedium,
                      ),
                    ),
                  );
                }

                return IconButton(
                  onPressed: () => setState(() => _selectedIndex = 2),
                  icon: const Icon(Icons.account_circle_outlined),
                  color: Colors.black54,
                );
              },
            ),
          ],
        ),
      );
    }

    Widget buildSegmented() {
      final labels = ['All', 'Today', 'Completed'];
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: SizedBox(
          height: 40,
          child: Row(
            children: List.generate(labels.length, (i) {
              return Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: _filterIndex,
                  builder: (context, value, _) {
                    final selected = value == i;
                    return GestureDetector(
                      onTap: () => _filterIndex.value = i,
                      child: Container(
                        height: 40,
                        margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? HomeScreen.primaryColor
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          labels[i],
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: selected
                                    ? Colors.white
                                    : HomeScreen.inactiveColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ),
      );
    }

    Widget buildList() {
      return ValueListenableBuilder<int>(
        valueListenable: _filterIndex,
        builder: (context, value, _) {
          final items = value == 0
              ? provider.items
              : value == 1
              ? provider.todayItems
              : provider.completedItems;

          if (items.isEmpty) return const _EmptyState();
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final r = items[i];
                return Dismissible(
                  key: ValueKey(r.id),
                  direction: DismissDirection.horizontal,
                  // Swapped gestures per user request:
                  // startToEnd (swipe RIGHT) => edit (navigate, do NOT dismiss)
                  // endToStart (swipe LEFT) => soft delete (move to Trash)
                  background: Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha((0.1 * 255).round()),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 24.0),
                    child: Icon(
                      Icons.edit_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24.0),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // Swipe RIGHT -> navigate to edit, do not dismiss
                      if (kDebugMode) {
                        // ignore: avoid_print
                        print(
                          'Dismiss DEBUG (swipe RIGHT -> edit): id=${r.id} direction=$direction',
                        );
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditScreen(reminder: r),
                        ),
                      );
                      return false; // do not dismiss
                    }

                    if (direction == DismissDirection.endToStart) {
                      // Swipe LEFT -> soft delete (move to Trash)
                      if (kDebugMode) {
                        // ignore: avoid_print
                        print(
                          'Dismiss DEBUG (swipe LEFT -> delete): id=${r.id} direction=$direction',
                        );
                      }
                      provider.removeReminder(r.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Moved to Trash'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () => provider.restoreReminder(r.id),
                          ),
                        ),
                      );
                      return true; // allow dismiss animation
                    }

                    return false;
                  },
                  child: _NoteCard(reminder: r),
                );
              },
            ),
          );
        },
      );
    }

    Widget mainBody() {
      return SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            buildHeader(provider),
            buildSegmented(),
            Expanded(child: buildList()),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: HomeScreen.backgroundColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: [mainBody(), const TrashScreen(), const ProfileScreen()],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddEditScreen())),
        child: const Icon(Icons.add),
        backgroundColor: HomeScreen.primaryColor,
        elevation: 2,
        tooltip: 'Add',
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (idx) => setState(() => _selectedIndex = idx),
        selectedItemColor: HomeScreen.primaryColor,
        unselectedItemColor: HomeScreen.inactiveColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete_outline),
            label: 'Trash',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ----------------------
// Note Card Widget
// ----------------------
class _NoteCard extends StatelessWidget {
  final Reminder reminder;
  const _NoteCard({Key? key, required this.reminder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final primary = HomeScreen.primaryColor;

    final dateTxt = reminder.dueAt != null
        ? DateFormat('MMM d, yyyy h:mm a').format(reminder.dueAt!)
        : DateFormat('MMM d, yyyy h:mm a').format(reminder.createdAt);

    // Category badge
    Widget? categoryBadge;
    if ((reminder.type ?? '').isNotEmpty) {
      final type = (reminder.type ?? '').toLowerCase();
      final bg = type.contains('work')
          ? HomeScreen.primaryColor
          : type.contains('personal')
          ? Colors.purple
          : Colors.grey.shade300;
      final fg = (bg.computeLuminance() < 0.5) ? Colors.white : Colors.black;
      categoryBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          reminder.type!,
          style: textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    reminder.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description preview (optional)
                  if ((reminder.description ?? '').isNotEmpty)
                    Text(
                      reminder.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Meta row: category badge + date
                  Row(
                    children: [
                      if (categoryBadge != null) categoryBadge,
                      if (categoryBadge != null) const SizedBox(width: 10),
                      Text(
                        dateTxt,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Toggle aligned to right
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Switch(
                  value: reminder.isCompleted,
                  onChanged: (_) => Provider.of<ReminderProvider>(
                    context,
                    listen: false,
                  ).toggleCompleted(reminder.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------
// Empty State Widget
// ----------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 250),
        builder: (context, v, child) => Opacity(opacity: v, child: child),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 56,
              color: HomeScreen.primaryColor.withAlpha((0.6 * 255).round()),
            ),
            const SizedBox(height: 16),
            Text(
              'No reminders yet',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep it simple. Start by adding one.',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
