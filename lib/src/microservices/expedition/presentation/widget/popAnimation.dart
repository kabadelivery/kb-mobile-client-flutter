import 'package:flutter/cupertino.dart';
class PopInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  bool visible=true;

   PopInWidget({
    super.key,
    required this.child,
    required this.duration,
    this.visible=true,
  });

  @override
  State<PopInWidget> createState() => _PopInWidgetState();
}

class _PopInWidgetState extends State<PopInWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    if (widget.visible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant PopInWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.visible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
        reverseCurve: Curves.easeInBack,
      ),
    );

    final fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);

    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: widget.child,
      ),
    );
  }
}