import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/app_style.dart';
import 'package:apc_schedular/features/dashboard/home_screen.dart';
import 'package:apc_schedular/features/dashboard/task_screen.dart';
import 'package:apc_schedular/features/dashboard/profile_screen.dart';
import 'package:apc_schedular/features/dashboard/schedules_screen.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ScheduleOverviewScreen(),
    const TaskOverviewScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.blackColor,
        unselectedItemColor: AppColors.textColor,
        onTap: _onItemTapped,
        elevation: 10,
        showUnselectedLabels: true,
        selectedLabelStyle: AppTextStyle().textInter(
          size: 12,
          weight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyle().textInter(
          size: 12,
          weight: FontWeight.w400,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(EvaIcons.homeOutline),
            activeIcon: Icon(EvaIcons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(EvaIcons.calendar),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Schedules',
          ),
          BottomNavigationBarItem(
            icon: Icon(EvaIcons.activity),
            activeIcon: Icon(EvaIcons.activity),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(EvaIcons.person),
            activeIcon: Icon(EvaIcons.personDone),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
