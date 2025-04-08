import 'package:flutter/material.dart';

class CounterProvider extends ChangeNotifier {
  int _completedTasks = 0;
  int get completedTasks => _completedTasks;

  void increment() {
    _completedTasks++;
    notifyListeners();
  }

  void decrement() {
    if (_completedTasks > 0) {
      _completedTasks--;
      notifyListeners();
    }
  }
}
