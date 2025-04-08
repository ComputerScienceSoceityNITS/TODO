import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _task = [];
  final TextEditingController _taskController = TextEditingController();

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _task.add({'task': _taskController.text, 'completed': false});
        _taskController.clear();
      });
    }
  }

  void _toggleTask(int index) {
    setState(() {
      _task[index]['completed'] = !_task[index]['completed'];
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _task.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo Apploication"),
        centerTitle: true,
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(color: Colors.white),
      ),

      backgroundColor: const Color.fromARGB(255, 114, 22, 22),

      body: Column(
        children: [





          Padding(
            padding: const EdgeInsets.only(left: 50.0),
            child: Row(


              children: [


                Expanded(
                  child: TextField(
                    controller: _taskController,
                    
                  ),
                ),
                
                
                IconButton(
                  icon: Icon(Icons.add, color: Colors.white),
                  onPressed: _addTask,
                ),
              
              
              ],
            ),
          ),




          Expanded(
            child: ListView.builder(
              itemCount: _task.length,
              itemBuilder: (context, index) {
                return Card(
                  color: const Color.fromARGB(255, 71, 206, 37),
                  child: ListTile(



                    leading: Checkbox(
                      value: _task[index]['completed'],
                      onChanged: (value) => _toggleTask(index),
                    ),

                    
                    
                    title: Center(
                      child: Text(
                        _task[index]['task'],
                        style: TextStyle(
                          color: Colors.white,
                          decoration:
                              _task[index]['completed']
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                      ),
                    ),

                    
                    
                    
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTask(index),
                    ),

                    
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
