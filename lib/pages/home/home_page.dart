import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test1/prov_counter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _task = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _taskController = TextEditingController();

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      final newTask = {'task': _taskController.text, 'completed': false};
      _task.insert(0, newTask);
      _listKey.currentState?.insertItem(
        0,
        duration: const Duration(milliseconds: 300),
      );
      _taskController.clear();
      setState(() {});
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
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: ListTile(
          leading: Checkbox(
            value: task['completed'],
            onChanged: (value) => _toggleTask(index),
          ),
          title: Text(
            task['task'],
            style: TextStyle(
              decoration: task['completed'] ? TextDecoration.lineThrough : null,
              color: Colors.black,
            ),
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
        centerTitle: true,
        backgroundColor: const Color(0xFF0077B6), // Ocean Blue
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFCAF0F8), // Light Ocean Blue

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
                    : Text('📭 No tasks!'),
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
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077B6),
                    foregroundColor: Colors.white,
                  ),
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
    );
  }
}
