// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

// class BluetoothPermissionPage extends StatefulWidget {
//   @override
//   _BluetoothPermissionPageState createState() =>
//       _BluetoothPermissionPageState();
// }

// class _BluetoothPermissionPageState extends State<BluetoothPermissionPage> {
//   @override
//   void initState() {
//     super.initState();
//     requestPermissions();
//   }

//   Future<void> requestPermissions() async {
//     var status = await Permission.bluetooth.status;
//     if (!status.isGranted) {
//       status = await Permission.bluetooth.request();
//     }
//     if (status.isGranted) {
//       // Bluetooth permissions granted, proceed with Bluetooth operations
//     } else {
//       // Bluetooth permissions denied, handle accordingly
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth Permission'),
//       ),
//       body: Center(
//         child: Text('Requesting Bluetooth Permissions...'),
//       ),
//     );
//   }
// }
