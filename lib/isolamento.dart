import 'package:flutter/material.dart';

class Isolamento extends StatefulWidget {
  const Isolamento({super.key});

  @override
  State<Isolamento> createState() => _IsolamentoState();
}

class _IsolamentoState extends State<Isolamento> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
              style: TextStyle(fontSize: 18),
              "I know you're angry, but anger brings you no where. \n\nPlease take a deep breath and consider talking to me to vent you anger. \n\nThen you can talk with your mate to solve the issue in a costructive way. Take you time ;-)"),
        ),
      ),
    );
  }
}
