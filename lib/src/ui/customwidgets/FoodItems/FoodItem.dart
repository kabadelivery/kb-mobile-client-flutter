import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/resources/restaurant_api_provider.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';

import '../../screens/home/buy/shop/flower/ShopFlowerDetailsPage.dart';

/// UI model mapped from ShopProductModel
class FoodItem {
  final int id;
  final String name;
  final String pic;
  final double rating;
  final int price;
  final String restaurantName;
  final String buttonLabel;

  FoodItem({
    required this.id,
    required this.name,
    required this.pic,
    required this.rating,
    required this.price,
    required this.restaurantName,
    required this.buttonLabel,
  });

  /// Factory to convert ShopProductModel → FoodItem
  factory FoodItem.fromShopProduct(ShopProductModel p) {
    return FoodItem(
      id: p.id ?? 0,
      name: p.name ?? "Plat inconnu",
      pic: p.pic ?? "",
      rating: (p.stars ?? 0).toDouble(),
      price: int.tryParse(p.price ?? "0") ?? 0,
      restaurantName: p.restaurant_entity?.name ?? "Restaurant inconnu",
      buttonLabel: "Commander",
    );
  }
}

/// Grid widget displaying food list
class FoodGrid extends StatefulWidget {
  final String foodType; // e.g. "Riz", "Spaghetti"

  const FoodGrid({super.key, required this.foodType});

  @override
  State<FoodGrid> createState() => _FoodGridState();
}

class _FoodGridState extends State<FoodGrid> {
  late Future<Map<String,dynamic>> futureFoods;
  final RestaurantApiProvider _service = RestaurantApiProvider();

  /// Fetch data from API and map to FoodItem
  Future<Map<String,dynamic>> fetchFoods(String query) async {
    try {
      final List<ShopProductModel> products =
      await _service.fetchRestaurantFoodProposal2FromTag("food", query);
      Map<String,dynamic> food_and_products = {
        'products':[],
        'food':[]
      };
      food_and_products['products'] = products.map((p) => FoodItem.fromShopProduct(p)).toList();
      food_and_products['foods'] =products
      ;
      return food_and_products;
    } catch (e, stack) {
      debugPrint("=== ERROR in fetchRestaurantFoodProposal2FromTag ===");
      debugPrint("Error type: ${e.runtimeType}");
      debugPrint("Error: $e");
      debugPrint("Stack trace:\n$stack");
      throw Exception("Erreur lors du fetch: $e\nStack trace: $stack");
    }
  }

  @override
  void initState() {
    super.initState();
    futureFoods = fetchFoods(widget.foodType);
  }

  @override
  void didUpdateWidget(covariant FoodGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.foodType != widget.foodType) {
      setState(() {
        futureFoods = fetchFoods(widget.foodType);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String,dynamic>>(
      future: futureFoods,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    "Oops! Une erreur s'est produite.",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Aucun plat trouvé"));
        }
        final real_foods= snapshot.data!["foods"];
        final foods = snapshot.data!["products"];
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 280,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: foods.length,
          itemBuilder: (context, index) {
            final food = foods[index];
            ShopProductModel real_food = real_foods.firstWhere((f) => f.id == food.id);
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image (uses Utils.inflateLink if available)
                  ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Builder(builder: (context) {
                      final imageUrl = Utils.inflateLink(food.pic);
                      return Image.network(
                        imageUrl,
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 130,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported,
                                color: Colors.grey),
                          );
                        },
                      );
                    }),
                  ),

                  // Title
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      food.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Restaurant name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      food.restaurantName,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Rating + Price
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(real_food.rating!.toStringAsFixed(0)),
                        const Spacer(),
                        Text(
                          "${food.price} FCFA",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Button -> open ShopFlowerDetailsPage safely
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: KColors.primaryColor,
                        ),
                        onPressed: () {
                          // --- BUILD A SAFE ShopProductModel ---
                          final safePrice = (food.price != 0)
                              ? food.price.toString()
                              : '0';

                          final safeFood = ShopProductModel(
                            id: food.id,
                            name: food.name,
                            price: safePrice, // guaranteed numeric string
                            pic: food.pic,
                            stars: 0, // keep 0 as placeholder (ShopFlowerDetailsPage expects a number)
                            restaurant_entity: null, // keep null to avoid mismatch
                          );

                          debugPrint(
                              "NAV -> ShopFlowerDetailsPage: id=${safeFood.id} price=${safeFood.price}");

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShopFlowerDetailsPage(
                                food: real_food,
                                foodId: food.id,
                              ),
                            ),
                          );
                        },
                        child: Text("${AppLocalizations.of(context)!.translate("pay")}"),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
