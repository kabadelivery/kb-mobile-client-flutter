import 'package:KABA/src/microservices/expedition/presentation/widget/popAnimation.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:flutter/material.dart';

class FloatingCartButton extends StatefulWidget {
  final int itemCount;
  final VoidCallback onPressed;

  const FloatingCartButton({
    super.key,
    required this.itemCount,
    required this.onPressed,
  });

  @override
  State<FloatingCartButton> createState() => _FloatingCartButtonState();
}

class _FloatingCartButtonState extends State<FloatingCartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant FloatingCartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemCount != oldWidget.itemCount) {
      // 🔹 Restart animation when count changes
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 🔹 FAB wrapped with a container border
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: FloatingActionButton(
              backgroundColor: KColors.primaryColor,
              shape: const CircleBorder(),
              onPressed: widget.onPressed,
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
              ),
            ),
          ),

          // 🔹 Badge
          if (widget.itemCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: KColors.primaryColor, width: 2),
                ),
                child: Text(
                  "${widget.itemCount}",
                  style: const TextStyle(
                    color: KColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
