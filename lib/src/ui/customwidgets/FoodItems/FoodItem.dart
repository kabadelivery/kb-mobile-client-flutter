import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/resources/restaurant_api_provider.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';

/// ✅ UI model mapped from ShopProductModel
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
      pic : p.pic ?? "",
      rating: (p.stars ?? 0).toDouble(),
      price: int.tryParse(p.price ?? "0") ?? 0,
      restaurantName: p.restaurant_entity?.name ?? "Restaurant inconnu",
      buttonLabel: "Commander",
    );
  }
}

/// ✅ Grid widget displaying food list
class FoodGrid extends StatefulWidget {
  final String foodType; // e.g. "Riz", "Spaghetti"

  const FoodGrid({super.key, required this.foodType});

  @override
  State<FoodGrid> createState() => _FoodGridState();
}

class _FoodGridState extends State<FoodGrid> {
  late Future<List<FoodItem>> futureFoods;
  final RestaurantApiProvider _service = RestaurantApiProvider();

  /// Fetch data from API and map to FoodItem
  Future<List<FoodItem>> fetchFoods(String query) async {
    try {
      final List<ShopProductModel> products =
          await _service.fetchRestaurantFoodProposal2FromTag("food", query);

      return products.map((p) => FoodItem.fromShopProduct(p)).toList();
    } catch (e) {
      throw Exception("Erreur lors du fetch: $e");
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
    return FutureBuilder<List<FoodItem>>(
      future: futureFoods,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: SingleChildScrollView(
              child: Text(
                "${snapshot.error}\n\n${snapshot.stackTrace}",
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          );
        }
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Aucun plat trouvé"));
        }

        final foods = snapshot.data!;
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
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                
              ),
              color: Colors.white,
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Image
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: /* Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(
                                Utils.inflateLink(food.pic))
                       ) ),
                    ) */
                    
                     
                    
                    
                     Image.network(
                      "https://kaba-delivery-pictures-store.s3.eu-west-3.amazonaws.com/"+food.pic,
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
                    ), 
                  ),

                  /// Title
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

                  /// Restaurant name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      food.restaurantName,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),

                  const SizedBox(height: 5),

                  /// Rating + Price
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(food.rating.toStringAsFixed(1)),
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

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.room_outlined, color: Colors.grey, size: 18),
                        const SizedBox(width: 4),
                        Text(food.rating.toStringAsFixed(1)),
                        const Spacer(),
                        Text(
                          "${food.price} FCFA",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  /// Button
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: KColors.primaryColor,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${food.name} ajouté !")),
                          );
                        },
                        child: Text(food.buttonLabel),
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
