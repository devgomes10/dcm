import 'package:dcm/views/failures.dart';
import 'package:dcm/views/settings.dart';
import 'package:dcm/views/signals.dart';
import 'package:flutter/material.dart';

class MenuNavigator extends StatefulWidget {
  const MenuNavigator({super.key});

  @override
  State<MenuNavigator> createState() => _MenuNavigatorState();
}

class _MenuNavigatorState extends State<MenuNavigator> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.signal_cellular_alt_outlined),
            label: "Sinais",
          ),
          NavigationDestination(
            icon: Icon(Icons.sms_failed_outlined),
            label: "Falhas",
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: "Ajustes",
          ),
        ],
        animationDuration: const Duration(milliseconds: 1000),
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int i) {
          setState(() {
            currentPageIndex = i;
          });
        },
      ),
      body: [
        Signals(),
        Failures(),
        Settings(),
      ][currentPageIndex],
    );
  }
}
