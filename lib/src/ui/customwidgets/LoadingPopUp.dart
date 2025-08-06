import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingPopup extends StatefulWidget {
  final Future<void> Function() asyncFunction;
  const LoadingPopup({
    Key? key,
    required this.asyncFunction,
  }) : super(key: key);

  @override
  _LoadingPopupState createState() => _LoadingPopupState();
}

class _LoadingPopupState extends State<LoadingPopup> {
  @override
  void initState() {
    super.initState();
    _runAsyncTask();
  }

  void _runAsyncTask() async {
    await widget.asyncFunction();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("POPUP");
    return Scaffold(
      backgroundColor: Color(0x3A000000), // Semi-transparent background
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
