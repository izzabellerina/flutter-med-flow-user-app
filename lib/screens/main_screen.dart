import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'patient_list_screen.dart';
import 'appointment_list_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    PatientListScreen(),
    AppointmentListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'คนไข้',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'นัดหมาย',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'ผู้ใช้งาน',
          ),
        ],
      ),
    );
  }
}
