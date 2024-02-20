import 'dart:ui';

import 'package:intl/intl.dart';
import 'dart:math';

String formatTimestamp(int timestamp) {
  if (timestamp != null) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM dd, hh:mm a').format(dateTime);
  } else {
    return '';
  }
}

String getInitials(String name) {
  List<String> words = name.split(' ');
  String initials = '';
  for (String word in words) {
    if (word.isNotEmpty) {
      initials += word[0];
    }
  }
  return initials.toUpperCase();
}

String pascalCase(String name) {
  List<String> words = name.split(' ');
  String camelCaseString = '';
  for (int i = 0; i < words.length; i++) {
    camelCaseString +=
    '${words[i][0].toUpperCase()}${words[i].substring(1)} ';
  }
  return camelCaseString;
}

Color randomColor() {
  Random random = Random();
  return Color.fromARGB(
    255,
    random.nextInt(123 - 0 + 1) + 0,
    random.nextInt(123 - 0 + 1) + 0,
    random.nextInt(123 - 0 + 1) + 0,
  );
}
