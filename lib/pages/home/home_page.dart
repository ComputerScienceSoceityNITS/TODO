import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:test1/prov_counter.dart';
import '../../theme/theme_provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzData;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _task = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _taskController = TextEditingController();
  DateTime? _selectedDueDate;
  int _reminderMinutesBefore = 10;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    tzData.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
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

      _task.insert(0, newTask);
      _listKey.currentState?.insertItem(
        0,
        duration: const Duration(milliseconds: 300),
      );
      _taskController.clear();
      _selectedDueDate = null;
      setState(() {});
    }
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
    });
  }

  void _deleteTask(int index) {
    final removedTask = _task[index];
    final wasCompleted = removedTask['completed'];
    _task.removeAt(index);
    setState(() {});
    if (wasCompleted) {
      Provider.of<CounterProvider>(context, listen: false).decrement();
    }

    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildAnimatedItem(removedTask, index, animation),
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildAnimatedItem(
    Map<String, dynamic> task,
    int index,
    Animation<double> animation,
  ) {
    final dueDate = task['dueDate'] as DateTime?;
    final isOverdue = dueDate != null && dueDate.isBefore(DateTime.now());

    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        color: isOverdue ? Colors.red[100] : null,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: ListTile(
          leading: Checkbox(
            value: task['completed'],
            onChanged: (value) => _toggleTask(index),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task['task'],
                style: TextStyle(
                  decoration:
                      task['completed'] ? TextDecoration.lineThrough : null,
                  decorationColor:
                      Theme.of(context).textTheme.labelSmall!.color,
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
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteTask(index),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo Application"),
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule),
            tooltip: "Set default reminder time",
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
                          tempMinutes = value;
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
                setState(() {
                  _reminderMinutesBefore = picked;
                });
              }
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(value),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child:
                (_task.isNotEmpty)
                    ? Text(
                      "🎯 Tasks Completed: ${context.watch<CounterProvider>().completedTasks} out of ${_task.length}",
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
                  tooltip: "Pick Due Date",
                ),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedList(
              key: _listKey,
              initialItemCount: _task.length,
              itemBuilder: (context, index, animation) {
                return _buildAnimatedItem(_task[index], index, animation);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          (_task.isNotEmpty
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
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Are you sure you want to clear all tasks?',
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: Color(0xFF0077B6),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      toClear = true;
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Yes',
                                      style: TextStyle(
                                        color: Color(0xFF0077B6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        );
                        if (toClear) {
                          for (int i = _task.length - 1; i >= 0; i--) {
                            _listKey.currentState?.removeItem(
                              i,
                              (context, animation) =>
                                  _buildAnimatedItem(_task[i], i, animation),
                              duration: const Duration(milliseconds: 1),
                            );
                          }
                          Future.delayed(const Duration(milliseconds: 1), () {
                            setState(() {
                              _task.clear();
                            });
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: Duration(seconds: 2),
                              content: Text('All tasks cleared!'),
                            ),
                          );
                        }
                      },
                      child: Text('Clear All Tasks'),
                    ),
                  ],
                ),
              )
              : SizedBox()),
    );
  }
}
