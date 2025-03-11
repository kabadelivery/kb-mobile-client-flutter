import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:out_of_app_order/state_management/out_of_app_order/out_of_app_order_screen_state.dart';
import 'package:out_of_app_order/ui/customwidgets/out_of_app_product_form_widget.dart';

class FetchingPackageScreen extends StatefulWidget {
  @override
  _FetchingPackageScreenState createState() => _FetchingPackageScreenState();
}

class _FetchingPackageScreenState extends State<FetchingPackageScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PhoneNumberForm(context),
        SizedBox(height: 10),
        PackageAmountForm(context),
      ],
    );
  }
} 