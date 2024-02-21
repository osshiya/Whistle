import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'package:flutter_app/utils/bluetooth_handler.dart';
import 'package:flutter_app/screens/bluetooth_off_screen.dart';
import 'package:flutter_app/utils/services.dart';

class BLEPage extends StatefulWidget {
  static const title = 'Connect to BLE Device';
  static const androidIcon = Icon(Icons.bluetooth);

  const BLEPage({super.key});

  @override
  State<BLEPage> createState() => _BLEPageState();
}

class _BLEPageState extends State<BLEPage> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);

    super.initState();
    _adapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          BLEPage.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.lightBlue,
      ),
      body: _adapterState == BluetoothAdapterState.on
          ? ScanScreen()
          : BluetoothOffScreen(adapterState: _adapterState),
    );
  }
}

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  static const deviceName = "BLE#01";
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  @override
  void initState() {
    super.initState();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      _showBluetoothStatusSnackbar("Scan Error:", e);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  void _showBluetoothStatusSnackbar(message, dynamic e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$message: ${e.toString()}"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future onScanPressed() async {
    try {
      _systemDevices = await FlutterBluePlus.systemDevices;
    } catch (e) {
      _showBluetoothStatusSnackbar("System Devices Error:", e);
    }
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      _showBluetoothStatusSnackbar("Start Scan Error:", e);
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future onStopPressed() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      _showBluetoothStatusSnackbar("Stop Scan Error:", e);
    }
  }

  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connectAndUpdateStream();
      // Connection successful
      _showBluetoothStatusSnackbar("Connected to ${device.platformName}", null);
    } catch (e) {
      _showBluetoothStatusSnackbar(
          "Failed to connect to ${device.platformName}", e);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BLEServicesPage(
                device: device,
              )),
    );
  }

  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    try {
      await device.disconnectAndUpdateStream();
      // Disconnection successful
      _showBluetoothStatusSnackbar(
          "Disconnected from ${device.platformName}", null);
    } catch (e) {
      _showBluetoothStatusSnackbar(
          "Failed to disconnect from ${device.platformName}", e);
    }
  }

  Widget _buildConnectButton(BluetoothDevice device) {
    if (device.isConnected) {
      return ElevatedButton(
        onPressed: () {
          disconnectFromDevice(device);
        },
        child: const Text('Disconnect'),
      );
    } else if (device.connectionState == device.isConnecting) {
      return const ElevatedButton(
        onPressed: null, // Disable button while connecting
        child: Text('Connecting...'),
      );
    } else {
      return ElevatedButton(
        onPressed: () {
          connectToDevice(device);
        },
        child: const Text('Connect'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed:
              FlutterBluePlus.isScanningNow ? onStopPressed : onScanPressed,
          child: Text(FlutterBluePlus.isScanningNow
              ? 'Stop Scanning'
              : 'Start Scanning'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _scanResults.length,
            itemBuilder: (context, index) {
              final scanResult = _scanResults[index];
              if (scanResult.device.platformName.toString() == deviceName) {
                return ListTile(
                  title: Text(
                    scanResult.device.platformName,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    scanResult.device.remoteId.str,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: _buildConnectButton(scanResult.device),
                );
              }
            },
          ),
        ),
      ],
    ));
  }
}
