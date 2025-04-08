import 'package:flutter/material.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  _CounterScreenState createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Counter Tst')),
      body: Center(
        child: CounterDisplay(
          counter: _counter,
          onIncrement: _incrementCounter,
        ),
      ),
    );
  }
}

class CounterDisplay extends StatelessWidget {
  final int counter;
  final VoidCallback onIncrement;

  const CounterDisplay({super.key, required this.counter, required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Counsedvter: $counter', style: TextStyle(fontSize: 24),),
        SizedBox(height: 10,),
        ElevatedButton(onPressed: onIncrement, child: Text('Increment'))
      ],
    );
  }
}
