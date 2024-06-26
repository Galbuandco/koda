import 'package:flutter/material.dart';
import 'package:koda/ListachatGruppo.dart';
import 'package:koda/ListachatPrivate.dart';

class BottomNavigationBarWrapper extends StatefulWidget {
  @override
  _BottomNavigationBarWrapperState createState() => _BottomNavigationBarWrapperState();
}

class _BottomNavigationBarWrapperState extends State<BottomNavigationBarWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    ListaChat(),
    ListaChatGruppi()
    // Add your screens here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Groups',
          ),
          // Add your bottom navigation bar items here
        ],
      ),
    );
  }
}
