import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../utils/_static_data/ImageAssets.dart';

class AnimatedLogoSplash extends StatefulWidget {
  @override
  _AnimatedLogoSplashState createState() => _AnimatedLogoSplashState();
}

class _AnimatedLogoSplashState extends State<AnimatedLogoSplash> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _scaleAnimation;
  Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();

    // Preload the logo image
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(AssetImage(ImageAssets.splash_logo), context);
    });

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    // Define the scaling animation (bounce effect)
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.2)
        .chain(CurveTween(curve: Curves.elasticOut)) // Bounce effect
        .animate(_controller);

    // Define the position animation (moving the logo up)
    _positionAnimation = Tween<Offset>(begin: Offset(0, 0), end: Offset(0, -0.3))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start the animations after a delay
    Future.delayed(Duration(seconds: 1), () async {
      for (int i = 0; i < 3; i++) {
        await _controller.forward();
        await _controller.reverse();
      }
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SlideTransition(
        position: _positionAnimation, // Move the logo up
        child: ScaleTransition(
          scale: _scaleAnimation, // Apply scaling/bounce effect
          child: Image.asset(
            ImageAssets.splash_logo,
            width: 70,
            height: 70,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
