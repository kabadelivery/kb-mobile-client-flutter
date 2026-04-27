import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
Widget foodListShimmer(BuildContext context) {
  return Shimmer(
    enabled: true,
    color: Colors.white,
    colorOpacity: 0.5,
    duration: const Duration(milliseconds: 1200),
    interval: const Duration(milliseconds: 300),
    direction: ShimmerDirection.fromLTRB(),
    child: Container(
      width: MediaQuery.of(context).size.width - 20,
      margin: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LEFT CONTENT
          Expanded(
            child: Container(
              height: 115,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(247, 247, 247, 1.0),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE + DESCRIPTION
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  [
                      _shimmerBox(width: 140, height: 14),
                      SizedBox(height: 6),
                      _shimmerBox(width: 180, height: 12),
                    ],
                  ),

                  /// RATING
                  Row(
                    children:  [
                      _shimmerCircle(size: 18),
                      SizedBox(width: 6),
                      _shimmerBox(width: 30, height: 12),
                    ],
                  ),

                  /// PRICE + BUTTON
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children:  [
                          _shimmerBox(width: 40, height: 12),
                          SizedBox(width: 6),
                          _shimmerBox(width: 30, height: 12),
                        ],
                      ),
                      _shimmerBox(width: 90, height: 30, radius: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// RIGHT IMAGE
          Container(
            height: 115,
            width: 115,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(247, 247, 247, 1.0),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child:  Center(
              child: _shimmerBox(width: 80, height: 80, radius: 8),
            ),
          ),
        ],
      ),
    ),
  );
}
Widget shopListShimmer(BuildContext context) {
  return Shimmer(
    enabled: true,
    color: Colors.white,
    colorOpacity: 0.5,
    duration: const Duration(milliseconds: 1200),
    interval: const Duration(milliseconds: 300),
    direction: ShimmerDirection.fromLTRB(),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromRGBO(247, 247, 247, 1.0),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Row(
                children: [
                  Container(
                    height: 80,
                    width: 60,
                    padding: const EdgeInsets.all(5),
                    child: Center(
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _shimmerBox(width: 120, height: 14),
                            const SizedBox(width: 10),
                            _shimmerCircle(size: 20),
                            const SizedBox(width: 10),
                            _shimmerBox(width: 35, height: 18),
                          ],
                        ),

                        const SizedBox(height: 8),

                        _shimmerBox(
                          width: MediaQuery.of(context).size.width * 0.55,
                          height: 13,
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            _shimmerBox(width: 65, height: 24, radius: 10),
                            const SizedBox(width: 5),
                            _shimmerBox(width: 85, height: 24, radius: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 0,
            right: 0,
            child: _shimmerCircle(size: 40),
          ),
        ],
      ),
    ),
  );
}

Widget _shimmerBox({
  required double width,
  required double height,
  double radius = 6,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

Widget _shimmerCircle({required double size}) {
  return Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
  );
}

Widget chipListShimmer(BuildContext context) {
  return Shimmer(
    enabled: true,
    color: Colors.grey,
    colorOpacity: 0.5,
    duration: const Duration(milliseconds: 1200),
    interval: const Duration(milliseconds: 300),
    direction: ShimmerDirection.fromLTRB(),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
      child: _ChipShimmer(width: 70)
    ),
  );
}

class _ChipShimmer extends StatelessWidget {
  final double width;

  const _ChipShimmer({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 10,
      margin: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}

