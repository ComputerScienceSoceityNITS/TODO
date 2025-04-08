import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CounterProvider extends ChangeNotifier {
  int _counter = 0;
  int get counter => _counter;

  void increment() {
    _counter++;
    notifyListeners();
  }
}

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test counter'),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Counter: ${context.watch<CounterProvider>().counter}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () => context.read<CounterProvider>().increment(),
              child: Text('INcrement'),
            ),
          ],
        ),
      ),
    );
  }
}
