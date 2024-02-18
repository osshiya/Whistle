// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// import 'dart:io';
//
// import 'package:flutter_app/utils/snackbar.dart';
//
// import 'package:flutter_app/pages/bluetooth.dart';
//
// class BluetoothOnScreen extends StatelessWidget {
//   const BluetoothOnScreen({Key? key, this.adapterState}) : super(key: key);
//
//   final BluetoothAdapterState? adapterState;
//
//   Widget buildBluetoothOnIcon(BuildContext context) {
//     return const Icon(
//       Icons.bluetooth,
//       size: 200.0,
//       color: Colors.white54,
//     );
//   }
//
//   Widget buildTitle(BuildContext context) {
//     String? state = adapterState?.toString().split(".").last;
//     return Text(
//       'Bluetooth Adapter is ${state != null ? state : 'not available'}',
//       style: Theme.of(context)
//           .primaryTextTheme
//           .titleSmall
//           ?.copyWith(color: Colors.white),
//     );
//   }
//
//   Widget buildTurnOffButton(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: ElevatedButton(
//         child: const Text('TURN OFF'),
//         onPressed: () async {
//           try {
//             if (Platform.isAndroid) {
//               await FlutterBluePlus.turnOff();
//             }
//           } catch (e) {
//             Snackbar.show(ABC.a, prettyException("Error Turning On:", e),
//                 success: false);
//           }
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ScaffoldMessenger(
//       key: Snackbar.snackBarKeyA,
//       child: Scaffold(
//         backgroundColor: Colors.lightBlue,
//         extendBodyBehindAppBar: true,
//         body: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               buildBluetoothOnIcon(context),
//               buildTitle(context),
//               if (Platform.isAndroid) buildTurnOffButton(context),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
