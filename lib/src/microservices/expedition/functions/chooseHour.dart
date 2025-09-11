import 'package:flutter/material.dart';

Future<DateTime?> chooseDate({required BuildContext context}) async {
  final DateTime now = DateTime.now();
  final DateTime firstDate = DateTime(now.year - 100);
  final DateTime lastDate = DateTime(now.year + 100);
  return await showDatePicker(
    context: context,
    initialDate: now,
    firstDate: firstDate,
    lastDate: lastDate,
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.blue, // header background color
            onPrimary: Colors.white, // header text color
            onSurface: Colors.black, // body text color
          ),
        ),
        child: child!,
      );
    },
  );
}
