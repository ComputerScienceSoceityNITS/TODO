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

  void setCount(int count) {
    _completedTasks = count;
    notifyListeners();
  }

  void reset() {
    _completedTasks = 0;
    notifyListeners();
  }
}
