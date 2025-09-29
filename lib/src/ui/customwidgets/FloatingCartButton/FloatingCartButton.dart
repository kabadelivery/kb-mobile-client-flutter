import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:flutter/material.dart';

class FloatingCartButton extends StatelessWidget {
  final int itemCount;
  final VoidCallback onPressed;

  const FloatingCartButton({
    super.key,
    required this.itemCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 🔹 FAB wrapped with a container border
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color.fromRGBO(255, 255, 255, 1), // White border
              width: 2,            // Border thickness
            ),
          ),
          child: FloatingActionButton(
            backgroundColor: KColors.primaryColor,
            shape: const CircleBorder(),
            onPressed: onPressed,
            child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
          ),
        ),

        // 🔹 Badge
        if (itemCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: KColors.primaryColor, width: 2),
              ),
              child: Text(
                "$itemCount",
                style: const TextStyle(
                  color: KColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
