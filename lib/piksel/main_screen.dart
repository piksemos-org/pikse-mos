import 'package:flutter/material.dart';
import 'package:piksel_mos/piksel/cetak_screen.dart';
import 'package:piksel_mos/piksel/desain_screen.dart';
import 'package:piksel_mos/piksel/home_screen.dart';
import 'package:piksel_mos/piksel/antar_screen.dart';
import 'package:piksel_mos/piksel/kamu_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2; // Default to Home
  static const List<Widget> _widgetOptions = const [
    CetakScreen(),
    DesainScreen(),
    HomeScreen(),
    AntarScreen(),
    KamuScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

@override
Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.print), label: 'Cetak'),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services),
            label: 'Desain',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'Antar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Kamu'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF069494),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
