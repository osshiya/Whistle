import 'package:intl/intl.dart';

String formatTimestamp(int timestamp) {
  if (timestamp != null) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM dd, hh:mm a').format(dateTime);
  } else {
    return '';
  }
}