import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_app/models/bleDB.dart';

class BLEService {
  static final BLEService _instance = BLEService._internal();
  late FirebaseHelper dbHelper = FirebaseHelper();

  factory BLEService() {
    return _instance;
  }

  BLEService._internal();

  Future<void> _uploadReportData(int data) async {
    final newUid = await dbHelper.getStoredUid();
    dbHelper.storeData(newUid, 'report', data);
  }

  Future<void> _uploadEmergencyData(int data) async {
    final newUid = await dbHelper.getStoredUid();
    dbHelper.storeData(newUid, 'emergency', data);
  }

  Future<void> _uploadBuzzData(int data) async {
    final newUid = await dbHelper.getStoredUid();
    dbHelper.storeData(newUid, 'buzz', data);
  }

  Future<void> _subscribeToNotifications(
      BluetoothCharacteristic characteristic, String type) async {
    try {
      await characteristic.setNotifyValue(true);
      characteristic.lastValueStream.listen((List<int>? value) {
        if (value != null && value.isNotEmpty) {
          int level = value[0];
          print('$type Levels: $level');
          switch (type) {
            case 'report':
              _uploadReportData(DateTime.now().millisecondsSinceEpoch.toInt());
              break;
            case 'emergency':
              _uploadEmergencyData(
                  DateTime.now().millisecondsSinceEpoch.toInt());
              break;
            case 'buzz':
              _uploadBuzzData(DateTime.now().millisecondsSinceEpoch.toInt());
              break;
            default:
              break;
          }
        }
      });
    } catch (e) {
      print('Error subscribing to notifications: $e');
    }
  }
}

class BLEServicesPage extends StatefulWidget {
  static const title = 'BLE Services';
  static const androidIcon = Icon(Icons.bluetooth);

  const BLEServicesPage({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<BLEServicesPage> createState() => _BLEServicesPageState();
}

class _BLEServicesPageState extends State<BLEServicesPage> {
  List<BluetoothService>? services;
  Map<String, String> reportLevels = {};
  Map<String, String> emergencyLevels = {};
  Map<String, String> buzzLevels = {};
  Map<String, String> batteryLevels = {};
  Map<String, String> clickLevels = {};

  late FirebaseHelper dbHelper;
  late String uid;

  @override
  void initState() {
    dbHelper = FirebaseHelper();
    super.initState();
    _discoverServices();
  }

  Future<void> _discoverServices() async {
    try {
      List<BluetoothService> discoveredServices =
          await widget.device.discoverServices();
      setState(() {
        services = discoveredServices;
      });
      await _readLevels();
    } catch (e) {
      print('Error discovering services: $e');
    }
  }

  Future<void> _readLevels() async {
    try {
      for (BluetoothService service in services!) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          print("MYSERVICE:  ${service.uuid} | MYCHAR: ${characteristic.uuid}");

          if (characteristic.uuid.toString() ==
              "01234567-0123-4567-89ab-0123456789cd") {
            subscribeToNotifications(characteristic, 'report');
            BLEService()._subscribeToNotifications(characteristic, 'report');
          }
          if (characteristic.uuid.toString() ==
              "01234567-0123-4567-89ab-0123456789de") {
            subscribeToNotifications(characteristic, 'emergency');
            BLEService()._subscribeToNotifications(characteristic, 'emergency');
          }
          if (characteristic.uuid.toString() ==
              "01234567-0123-4567-89ab-0123456789ef") {
            subscribeToNotifications(characteristic, 'buzz');
            BLEService()._subscribeToNotifications(characteristic, 'buzz');
          }
          if (characteristic.uuid.toString() ==
              "01234567-0123-4567-89ab-0123456789f0") {
            subscribeToNotifications(characteristic, 'battery');
            BLEService()._subscribeToNotifications(characteristic, 'battery');
          }
          if (characteristic.uuid.toString() ==
              "01234567-0123-4567-89ab-012345678901") {
            subscribeToNotifications(characteristic, 'click');
            BLEService()._subscribeToNotifications(characteristic, 'click');
          }
        }
      }
    } catch (e) {
      print('Error reading levels: $e');
    }
  }

  Future<void> subscribeToNotifications(
      BluetoothCharacteristic characteristic, String type) async {
    try {
      await characteristic.setNotifyValue(true);
      characteristic.lastValueStream.listen((List<int>? value) {
        if (value != null && value.isNotEmpty) {
          int level = value[0];
          print('$type Levels: $level');
          switch (type) {
            case 'report':
              reportLevels[characteristic.serviceUuid.toString()] =
                  level.toString();
              break;
            case 'emergency':
              emergencyLevels[characteristic.serviceUuid.toString()] =
                  level.toString();
              break;
            case 'buzz':
              buzzLevels[characteristic.serviceUuid.toString()] =
                  level.toString();
              break;
            case 'battery':
              batteryLevels[characteristic.serviceUuid.toString()] =
                  level.toString();
              break;
            case 'click':
              clickLevels[characteristic.serviceUuid.toString()] =
                  level.toString();
              break;
            default:
              break;
          }
        }
      });
    } catch (e) {
      print('Error subscribing to notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          BLEServicesPage.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.lightBlue,
      ),
      body: services != null
          ? ListView.builder(
              itemCount: services!.length,
              itemBuilder: (context, index) {
                BluetoothService service = services![index];
                return ListTile(
                  title: Text('Service ${index + 1}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Report Level: ${reportLevels[service.uuid.toString()] ?? 'N/A'}'),
                      Text(
                          'Emergency Level: ${emergencyLevels[service.uuid.toString()] ?? 'N/A'}'),
                      Text(
                          'Buzz Level: ${buzzLevels[service.uuid.toString()] ?? 'N/A'}'),
                      Text(
                          'Battery Level: ${batteryLevels[service.uuid.toString()] ?? 'N/A'}'),
                      Text(
                          'Click Level: ${clickLevels[service.uuid.toString()] ?? 'N/A'}')
                    ],
                  ),
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class LocationService {
  static Future<String?> getCurrentCountry() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      return placemarks.first.country;
    } catch (e) {
      print('Error getting current country: $e');
      return null;
    }
  }
}
