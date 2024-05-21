// import 'package:dcm/views/bluetooth_connection/connection_view.dart';
// import 'package:dcm/views/errors/error_view.dart';
// import 'package:dcm/views/indicators/indicators_view.dart';
// import 'package:dcm/views/settings/settings_view.dart';
// import 'package:flutter/material.dart';
//
// class MenuNavigator extends StatefulWidget {
//   const MenuNavigator({super.key});
//
//   @override
//   State<MenuNavigator> createState() => _MenuNavigatorState();
// }
//
// class _MenuNavigatorState extends State<MenuNavigator> {
//   int currentPageIndex = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: NavigationBar(
//         destinations: const [
//           NavigationDestination(
//             icon: Icon(Icons.bluetooth),
//             label: "Bluetooth",
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.bar_chart_rounded),
//             label: "Painel",
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.error),
//             label: "Erros",
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.settings),
//             label: "Ajustes",
//           ),
//         ],
//         animationDuration: const Duration(milliseconds: 1000),
//         selectedIndex: currentPageIndex,
//         onDestinationSelected: (int i) {
//           setState(() {
//             currentPageIndex = i;
//           });
//         },
//       ),
//       body: [
//         Connection(),
//         IndicatorsView(),
//         ErrorView(),
//         SettingsView(),
//       ] [currentPageIndex],
//     );
//   }
// }
