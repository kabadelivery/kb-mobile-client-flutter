import 'package:flutter/material.dart';

class MRaisedButton extends StatelessWidget {
  Color? color;

  Function? onPressed;

  Widget? child;

  double? elevation;

  EdgeInsets padding;

  BorderRadius borderRadius;

  MRaisedButton(

      {
        Key? key,
      this.color = Colors.white,
      this.elevation,
      this.child,
      this.onPressed,
      this.padding = const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      this.borderRadius = const BorderRadius.all(const Radius.circular(5))})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed!(),
      child: Container(
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: this.color,
            borderRadius: this.borderRadius),
        padding: this.padding,
        child: this.child,
      ),
    );
  }
}
