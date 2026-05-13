import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PromoBadge extends StatefulWidget {
  final String text;

  const PromoBadge({
    super.key,
    this.text = "PROMO",
  });

  @override
  State<PromoBadge> createState() => _PromoBadgeState();
}

class _PromoBadgeState extends State<PromoBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.10,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 + (_controller.value * 2), 0),
                end: Alignment(0 + (_controller.value * 2), 0),
                colors: const [
                  Color(0xFFFFE66D),
                  Color(0xFFFFF4A3),
                  Color(0xFFFFE66D),
                ],
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              widget.text,
              style: const TextStyle(
                color: Color(0xFFD7194A),
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
          );
        },
      ),
    );
  }
}
class PromoBanner extends StatelessWidget {
  final String merchantName;
  final VoidCallback? onTap;

  const PromoBanner({
    super.key,
    required this.merchantName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(

      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 210,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE91E4D),
                  Color(0xFFC9153F),
                ],
              ),

            ),
            child: Stack(
              children: [
                Positioned(
                  right: -35,
                  top: -35,
                  child: _CircleDecor(size: 120),
                ),
                Positioned(
                  left: -45,
                  bottom: -45,
                  child: _CircleDecor(size: 130),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const PromoBadge(text: "OFFRES DU MOMENT"),

                            const SizedBox(height: 16),

                            const Text(
                              "Le bon moment\npour commander",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                height: 1.05,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Des promotions sont disponibles chez $merchantName",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.92),
                                fontSize: 13.5,
                                height: 1.25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const Spacer(),

                            GestureDetector(
                              onTap: onTap,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  "Voir les offres",
                                  style: TextStyle(
                                    color: Color(0xFFD7194A),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      SizedBox(
                        width: 105,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.16),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Image.asset("assets/images/png/coupon.png",width:90),
                            Positioned(
                              top: 14,
                              right: 6,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFE66D),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.star_rounded,
                                  size: 17,
                                  color: Color(0xFFD7194A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 18,
            bottom: 0,
            child: Container(
              width: 105,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "KABA",
                  style: TextStyle(
                    color: Color(0xFFD7194A),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleDecor extends StatelessWidget {
  final double size;

  const _CircleDecor({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.08),
      ),
    );
  }
}

class DeliveryPromoBanner extends StatelessWidget {
  final String merchantName;
  final Map<String, dynamic> promo;
  final VoidCallback? onTap;
  final AnimationController badgeController;

  const DeliveryPromoBanner({
    super.key,
    required this.merchantName,
    required this.promo,
    required this.badgeController,
    this.onTap,
  });

  String get discountText => promo["type_reduction"] ?? "";

  String? get minimumText {
    final value = promo["montant_minimum"];
    if (value == null || value.toString().isEmpty) return null;
    return "Dès $value d’achat";
  }

  List<Map<String, dynamic>> get chips {
    final items = <Map<String, dynamic>>[];
    int rayon = int.parse(
      promo["rayon_km"]
          .toString()
          .replaceAll("km", "")
          .replaceAll(" ", ""),
    );
    final heureDebut = promo["heure_debut"];
    final heureFin = promo["heure_fin"];
    final dateFin = promo["date_fin"];

    if (rayon == null) {
      items.add({
        "icon": Icons.location_on_rounded,
        "text": "Zone éligible",
      });
    } else if (rayon >= 15) {
      items.add({
        "icon": Icons.location_on_rounded,
        "text": "Partout à Lomé",
      });
    } else {
      items.add({
        "icon": Icons.location_on_rounded,
        "text": "$rayon km autour",
      });
    }

    if (heureDebut == null || heureFin == null) {
      items.add({
        "icon": Icons.access_time_rounded,
        "text": "À tout moment",
      });
    } else {
      items.add({
        "icon": Icons.access_time_rounded,
        "text": "$heureDebut - $heureFin",
      });
    }

    if (dateFin != null && dateFin.toString().isNotEmpty) {
      items.add({
        "icon": Icons.calendar_month_rounded,
        "text": "Jusqu’au $dateFin",
      });
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final promoChips = chips;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 210,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFD84D),
                    Color(0xFFFFB800),
                  ],
                ),

              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -35,
                    top: -35,
                    child: _CircleDecor(size: 120),
                  ),
                  Positioned(
                    left: -45,
                    bottom: -45,
                    child: _CircleDecor(size: 130),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const PromoBadge(text: "PROMO LIVRAISON"),

                              const SizedBox(height: 12),

                              Text(
                                "-$discountText sur la livraison",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF7A3E00),
                                  fontSize: 30,
                                  height: .95,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),

                              const SizedBox(height: 7),

                              Text(
                                minimumText ??
                                    "Profite d’une livraison réduite chez $merchantName",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                  const Color(0xFF7A3E00).withOpacity(.82),
                                  fontSize: 13.5,
                                  height: 1.2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const Spacer(),

                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: promoChips.take(3).map((chip) {
                                  return _PromoInfoChip(
                                    icon: chip["icon"],
                                    text: chip["text"],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        SizedBox(
                          width: 95,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 92,
                                height: 92,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.22),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Image.asset(
                                "assets/images/png/scooter.png",
                                width: 88,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              right: -12,
              bottom: -12,
              child: RotationTransition(
                turns: badgeController,
                child: _DiscountBurst(value: discountText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PromoInfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.32),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: const Color(0xFF7A3E00),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF7A3E00),
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
class DiscountSticker extends StatelessWidget {
  final String text;

  const DiscountSticker({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.13,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFF7A3E00).withOpacity(0.12),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7A3E00).withOpacity(0.22),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "OFFRE",
              style: TextStyle(
                color: Color(0xFFFFB800),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFF7A3E00),
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: .9,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              "sur livraison",
              style: TextStyle(
                color: Color(0xFF7A3E00),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PromotionCarousel extends StatefulWidget {
  final String merchantName;
  final Map<String, dynamic>? foodPromotion;
  final List<Map<String, dynamic>> deliveryPromotions;
  final VoidCallback? onTap;

  const PromotionCarousel({
    super.key,
    required this.merchantName,
    this.foodPromotion,
    this.deliveryPromotions = const [],
    this.onTap,
  });

  @override
  State<PromotionCarousel> createState() => _PromotionCarouselState();
}

class _PromotionCarouselState extends State<PromotionCarousel>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _badgeController;

  int _currentPage = 0;
  late final List<Map<String, dynamic>> _items;

  @override
  void initState() {
    debugPrint("deliveryPromotions ${widget.deliveryPromotions}");
    super.initState();

    _items = [];

    if (widget.foodPromotion != null) {
      _items.add(widget.foodPromotion!);
    }

    _items.addAll(widget.deliveryPromotions);

    _pageController = PageController(viewportFraction: 0.92);

    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _introCarouselMove();
    });
  }

  Future<void> _introCarouselMove() async {
    if (_items.length < 2 || !_pageController.hasClients) return;

    await Future.delayed(const Duration(seconds: 2));

    await _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
    );

    await Future.delayed(const Duration(seconds: 2));

    await _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox();

    return Column(
      children: [
        SizedBox(
          height: 215,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _items.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return AnimatedScale(
                scale: _currentPage == index ? 1 : 0.96,
                duration: const Duration(seconds: 250),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: _PromotionSlide(
                    item: _items[index],
                    merchantName: widget.merchantName,
                    badgeController: _badgeController,
                    onTap: widget.onTap,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        if (_items.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _items.length,
                  (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage == index ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? const Color(0xFF7A3E00)
                      : const Color(0xFF7A3E00).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
class _PromotionSlide extends StatelessWidget {
  final Map<String, dynamic> item;
  final String merchantName;
  final AnimationController badgeController;
  final VoidCallback? onTap;

  const _PromotionSlide({
    required this.item,
    required this.merchantName,
    required this.badgeController,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = item["type"] ?? "food";

    final isDelivery = type == "delivery";

    if (isDelivery) {
      return DeliveryPromoBanner(
        badgeController: badgeController,
        merchantName: merchantName,
        promo: item,
        onTap: onTap,
      );
    }

    return PromoBanner(
      merchantName: merchantName,
    );
  }
}
class _DiscountBurst extends StatelessWidget {
  final String value;

  const _DiscountBurst({
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _BurstClipper(),
      child: Container(
        width: 92,
        height: 92,
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "JUSQU’À",
              style: TextStyle(
                color: Color(0xFFFF9F1C),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: .7,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF7A3E00),
                fontSize: 23,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const Text(
              "OFFERT",
              style: TextStyle(
                color: Color(0xFF7A3E00),
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _BurstClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);

    const points = 24;
    final outerRadius = size.width / 2;
    final innerRadius = size.width / 2.28;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * 3.1415926535) / points;

      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}