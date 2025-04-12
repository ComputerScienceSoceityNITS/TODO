// Final HomePage with no swipe-to-delete
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzData;

import '../../theme/theme_provider.dart';
import 'package:test1/prov_counter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _task = [];
  final TextEditingController _taskController = TextEditingController();
  DateTime? _selectedDueDate;
  int _reminderMinutesBefore = 10;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadTasksFromPrefs();
  }

  Future<void> _initNotifications() async {
    tzData.initializeTimeZones();
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );
    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _scheduleNotification(String task, DateTime dueTime) async {
    final scheduledTime = tz.TZDateTime.from(
      dueTime.subtract(Duration(minutes: _reminderMinutesBefore)),
      tz.local,
    );
    await _notificationsPlugin.zonedSchedule(
      dueTime.millisecondsSinceEpoch ~/ 1000,
      'Reminder',
      'Task "$task" is due soon!',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminder',
          'Task Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _saveTasksToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final taskJson = jsonEncode(
      _task
          .map(
            (e) => {
              'task': e['task'],
              'completed': e['completed'],
              'dueDate': e['dueDate']?.toIso8601String(),
            },
          )
          .toList(),
    );
    await prefs.setString('task_list', taskJson);
  }

  Future<void> _loadTasksFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final taskJson = prefs.getString('task_list');
    if (taskJson != null) {
      final List decoded = jsonDecode(taskJson);
      _task.clear();
      int completedCount = 0;
      for (var e in decoded) {
        final taskMap = {
          'task': e['task'],
          'completed': e['completed'],
          'dueDate': e['dueDate'] != null ? DateTime.parse(e['dueDate']) : null,
        };
        if (taskMap['completed'] == true) completedCount++;
        _task.add(taskMap);
      }
      setState(() {});
      Provider.of<CounterProvider>(
        context,
        listen: false,
      ).setCount(completedCount);
    }
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      final newTask = {
        'task': _taskController.text,
        'completed': false,
        'dueDate': _selectedDueDate,
      };
      if (_selectedDueDate != null) {
        _scheduleNotification(_taskController.text, _selectedDueDate!);
      }
      _task.add(newTask);
      _taskController.clear();
      _selectedDueDate = null;
      setState(() {});
      _saveTasksToPrefs();
    }
  }

  void _editTask(int index) async {
    final TextEditingController editController = TextEditingController(
      text: _task[index]['task'],
    );
    DateTime? editedDueDate = _task[index]['dueDate'];

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Edit Task"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: editController,
                  decoration: const InputDecoration(labelText: "Task"),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      editedDueDate != null
                          ? "Due: ${DateFormat.yMd().add_jm().format(editedDueDate!)}"
                          : "No due date",
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_calendar),
                      tooltip: "Edit Due Date",
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: editedDueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (pickedDate != null) {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                              editedDueDate ?? DateTime.now(),
                            ),
                          );
                          if (pickedTime != null) {
                            editedDueDate = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                            setState(() {});
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _task[index]['task'] = editController.text;
                    _task[index]['dueDate'] = editedDueDate;
                  });
                  _saveTasksToPrefs();
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  void _pickDueDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 18, minute: 0),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _toggleTask(int index) {
    setState(() {
      final counterProvider = Provider.of<CounterProvider>(
        context,
        listen: false,
      );
      bool isCompleted = _task[index]['completed'];
      _task[index]['completed'] = !isCompleted;
      if (_task[index]['completed']) {
        counterProvider.increment();
      } else {
        counterProvider.decrement();
      }
      _saveTasksToPrefs();
    });
  }

  void _deleteTask(int index) {
    final wasCompleted = _task[index]['completed'];
    _task.removeAt(index);
    setState(() {});
    if (wasCompleted) {
      Provider.of<CounterProvider>(context, listen: false).decrement();
    }
    _saveTasksToPrefs();
  }

  void _reorderTasks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final task = _task.removeAt(oldIndex);
      _task.insert(newIndex, task);
      _saveTasksToPrefs();
    });
  }

  Widget _buildTaskTile(Map<String, dynamic> task, int index) {
    final dueDate = task['dueDate'] as DateTime?;
    final isOverdue = dueDate != null && dueDate.isBefore(DateTime.now());

    return Card(
      key: ValueKey(task),
      color: isOverdue ? Colors.red[100] : null,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Checkbox(
          value: task['completed'],
          onChanged: (_) => _toggleTask(index),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task['task'],
              style: TextStyle(
                decoration:
                    task['completed'] ? TextDecoration.lineThrough : null,
              ),
            ),
            if (dueDate != null)
              Text(
                'Due: ${DateFormat.yMd().add_jm().format(dueDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isOverdue ? Colors.red : Colors.grey,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editTask(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTask(index),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = context.watch<CounterProvider>().completedTasks;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo Application"),
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: () async {
              final picked = await showDialog<int>(
                context: context,
                builder: (context) {
                  int tempMinutes = _reminderMinutesBefore;
                  return AlertDialog(
                    title: const Text('Reminder before due time'),
                    content: DropdownButton<int>(
                      value: tempMinutes,
                      onChanged: (value) {
                        if (value != null) {
                          Navigator.of(context).pop(value);
                        }
                      },
                      items:
                          [5, 10, 15, 30, 60]
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text('$e minutes'),
                                ),
                              )
                              .toList(),
                    ),
                  );
                },
              );
              if (picked != null) {
                setState(() => _reminderMinutesBefore = picked);
              }
            },
          ),
          Consumer<ThemeProvider>(
            builder:
                (context, themeProvider, _) => Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(value),
                ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child:
                _task.isNotEmpty
                    ? Text(
                      "🎯 Tasks Completed: $completed out of ${_task.length}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : const Text(
                      '📭 No tasks!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: "Enter your task here...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDueDate,
                ),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _task.length,
              onReorder: _reorderTasks,
              itemBuilder:
                  (context, index) => _buildTaskTile(_task[index], index),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          _task.isNotEmpty
              ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        bool toClear = false;
                        await showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Row(
                                  children: [
                                    Icon(Icons.warning, color: Colors.amber),
                                    Expanded(
                                      child: const Text(
                                        'Are you sure you want to delete all tasks?',
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      toClear = true;
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Yes'),
                                  ),
                                ],
                              ),
                        );
                        if (toClear) {
                          setState(() => _task.clear());
                          Provider.of<CounterProvider>(
                            context,
                            listen: false,
                          ).reset();
                          _saveTasksToPrefs();
                        }
                      },
                      child: const Text('Clear All Tasks'),
                    ),
                  ],
                ),
              )
              : const SizedBox(),
    );
  }
}
