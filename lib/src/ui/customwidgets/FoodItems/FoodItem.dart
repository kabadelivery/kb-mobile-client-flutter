import 'dart:convert';

import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/resources/restaurant_api_provider.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';

import '../../../StateContainer.dart';
import '../../../models/CustomerModel.dart';
import '../../../xrint.dart';
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
  List<Map>? food_review_array = [];
  int?review_count;
  ShopModel? restaurant_entity;


  FoodItem({
    required this.id,
    required this.name,
    required this.pic,
    required this.rating,
    required this.price,
    required this.restaurantName,
    required this.buttonLabel,
    this.food_review_array,
    this.review_count,
    this.restaurant_entity
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
      food_review_array: p.food_review_array,
      review_count: p.review_count,
      restaurant_entity: p.restaurant_entity,
    );
  }
}

class FoodGrid extends StatefulWidget {
  final String foodType; // e.g. "Riz", "Spaghetti"
  final String typeOfSearch;
  const FoodGrid({super.key, required this.foodType, required this.typeOfSearch});

  @override
  State<FoodGrid> createState() => _FoodGridState();
}

class _FoodGridState extends State<FoodGrid> {
  late Future<Map<String,dynamic>> futureFoods;
  final RestaurantApiProvider _service = RestaurantApiProvider();
  final int _perPage = 10;
  List<dynamic> _allProducts = [];
  List<dynamic> _displayedProducts = [];
  List<dynamic> _allRealFoods = [];
  final Map<int, dynamic> _realById = {};
  bool _hasMore = false;
  bool _isLoadingMore = false;
  late final ScrollController _scrollController;
  /// Fetch data from API and map to FoodItem
  Future<Map<String,dynamic>> fetchFoods(String query) async {
    try {
      CustomerModel user = await CustomerUtils.getCustomer();
      debugPrint("Fetching foods for query: $query and typeOfSearch: ${widget.typeOfSearch}");
      final List<ShopProductModel> products =
      await _service.searchForFood(widget.typeOfSearch, query,user.token ?? "");
      Map<String,dynamic> food_and_products = {
        'products':[],
        'food':[]
      };
      String? myBillingArray =await CustomerUtils.getLastStoredBilling();
      Map<String, String> billingMap = {};
      if (myBillingArray != null) {
        var billingData = json.decode(myBillingArray);
        var billingData2 = billingData[user.email != null ? "email" : "phoneNumber"];

        for (var entry in billingData2) {
          int from = int.parse(entry["from"]);
          int to = int.parse(entry["to"]);
          String value = entry["value"].toString();

          for (int i = from; i < to; i++) {
            billingMap["$i"] = value;
          }
        }

        debugPrint('myBillingArray $billingMap');
      }

      for(var product in products){
        if(product.restaurant_entity!=null){
          final double dist = Utils.locationDistance(StateContainer.of(context).location,product.restaurant_entity!);
          product.restaurant_entity!.distanceBetweenMeandRestaurant = double.parse(dist > 100 ? "100" : dist.toStringAsFixed(2));
          product.restaurant_entity!.delivery_pricing =_getShippingPrice((dist).toString(),billingMap);
        }
      }
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
  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || !_hasMore) return;
    const threshold = 200.0; // pixels before reaching bottom
    if (_scrollController.position.maxScrollExtent - _scrollController.position.pixels <= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    // small delay so the spinner is visible
    await Future.delayed(const Duration(milliseconds: 200));

    final current = _displayedProducts.length;
    final next = current + _perPage;
    final takeTo = next > _allProducts.length ? _allProducts.length : next;
    final toAdd = _allProducts.sublist(current, takeTo);

    if (!mounted) return;
    setState(() {
      _displayedProducts.addAll(toAdd);
      _hasMore = _displayedProducts.length < _allProducts.length;
      _isLoadingMore = false;
    });
  }

  @override
  void initState() {
    super.initState();
    futureFoods = fetchFoods(widget.foodType);
    _scrollController = ScrollController()..addListener(_onScroll);
  }
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
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
                ],
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Aucun plat trouvé"));
        }

        // --- snapshot has data ---
        final real_foods = snapshot.data!["foods"] ?? [];
        final foods = snapshot.data!["products"] ?? [];

        // Initialize the in-state lists if needed (first time or when data changed)
        if (_allProducts.isEmpty || _allProducts.length != (foods as List).length) {
          // store all products and real foods in state so pagination can work
          _allProducts = List<dynamic>.from(foods);
          _allRealFoods = List<dynamic>.from(real_foods);
          _realById.clear();
          for (var r in _allRealFoods) {
            try {
              if (r != null && r.id != null) _realById[r.id] = r;
            } catch (_) {}
          }

          // prepare initial slice
          final initialCount = _allProducts.length < _perPage ? _allProducts.length : _perPage;
          _displayedProducts = _allProducts.take(initialCount).toList();
          _hasMore = _displayedProducts.length < _allProducts.length;
        }

        // GridView with scroll controller that triggers loading more
        return LayoutBuilder(builder: (context, constraints) {
          final bool hasFiniteHeight = constraints.maxHeight != double.infinity && constraints.maxHeight > 0;

          if (hasFiniteHeight) {
            // GRID CAN SCROLL: use controller + auto load more on scroll
            return GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 300,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _displayedProducts.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _displayedProducts.length) {
                  return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()));
                }
                final food = _displayedProducts[index];
                final ShopProductModel? real_food = (_realById.containsKey(food.id)) ? _realById[food.id] as ShopProductModel : null;

                final String ratingText = (real_food?.rating != null)
                    ? real_food!.rating!.toStringAsFixed(0)
                    : (food.rating != null ? food.rating.toStringAsFixed(0) : '0');
                final int reviewCount = real_food?.review_count ?? (food.review_count ?? 0);
                final String distanceText = (real_food?.restaurant_entity?.distanceBetweenMeandRestaurant != null)
                    ? "${real_food!.restaurant_entity!.distanceBetweenMeandRestaurant}Km"
                    : (food.restaurant_entity?.distanceBetweenMeandRestaurant != null
                    ? "${food.restaurant_entity!.distanceBetweenMeandRestaurant}Km"
                    : "-Km");
                final String deliveryPriceText = real_food?.restaurant_entity?.delivery_pricing?.toString() ??
                    food.restaurant_entity?.delivery_pricing?.toString() ??
                    "~";

                return _buildFoodCard(context, food, ratingText, reviewCount, distanceText, deliveryPriceText, real_food);
              },
            );
          } else {
            // GRID IS NESTED IN AN UNBOUNDED PARENT (e.g. SingleChildScrollView)
            // Show the grid (only the already displayed items) and place the "Load more" button
            // *outside* the grid so it spans full width and looks nicer.
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 300,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  // only show the already loaded items (no load-more cell inside the grid)
                  itemCount: _displayedProducts.length,
                  itemBuilder: (context, index) {
                    final food = _displayedProducts[index];
                    final ShopProductModel? real_food =
                    (_realById.containsKey(food.id)) ? _realById[food.id] as ShopProductModel : null;

                    final String ratingText = (real_food?.rating != null)
                        ? real_food!.rating!.toStringAsFixed(0)
                        : (food.rating != null ? food.rating.toStringAsFixed(0) : '0');
                    final int reviewCount = real_food?.review_count ?? (food.review_count ?? 0);
                    final String distanceText = (real_food?.restaurant_entity?.distanceBetweenMeandRestaurant != null)
                        ? "${real_food!.restaurant_entity!.distanceBetweenMeandRestaurant}Km"
                        : (food.restaurant_entity?.distanceBetweenMeandRestaurant != null
                        ? "${food.restaurant_entity!.distanceBetweenMeandRestaurant}Km"
                        : "-Km");
                    final String deliveryPriceText = real_food?.restaurant_entity?.delivery_pricing?.toString() ??
                        food.restaurant_entity?.delivery_pricing?.toString() ??
                        "~";

                    return _buildFoodCard(context, food, ratingText, reviewCount, distanceText, deliveryPriceText, real_food);
                  },
                ),

                // Load more button / spinner (full width, outside grid)
                if (_hasMore)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: _isLoadingMore
                          ? const SizedBox(height: 44, child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator())))
                          : ElevatedButton(
                        onPressed: _loadMore,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: KColors.primaryColor,
                        ),
                        child: Text("${AppLocalizations.of(context)!.translate("load_more")}", ),
                      ),
                    ),
                  ),
              ],
            );
          }
        });
      },
    );

  }
  Widget _buildFoodCard(
      BuildContext context,
      dynamic food,
      String ratingText,
      int reviewCount,
      String distanceText,
      String deliveryPriceText,
      ShopProductModel? real_food,
      ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(width: .5, color: KColors.primaryColor),
      ),
      color: Colors.white,
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Builder(builder: (context) {
              final imageUrl = Utils.inflateLink(food.pic);
              return Image.network(
                imageUrl,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: Container(
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  );
                },

              );
            }),
          ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              food.restaurantName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(ratingText),
                        const SizedBox(width: 5),
                        reviewCount != 0 ? Text("($reviewCount)") : Container(),
                      ],
                    ),
                    Text(
                      "${food.price} FCFA",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined),
                        Text(distanceText),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text("$deliveryPriceText FCFA", style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold))
                  ],
                )
              ],
            ),
          ),
          const Spacer(),
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
                  final safePrice = (food.price != 0) ? food.price.toString() : '0';
                  final safeFood = ShopProductModel(id: food.id, name: food.name, price: safePrice, pic: food.pic, stars: 0, restaurant_entity: null);
                  final navFood = real_food ?? safeFood;
                  debugPrint("NAV -> ShopFlowerDetailsPage: id=${navFood.id} price=${navFood.price}");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ShopFlowerDetailsPage(food: navFood, foodId: food.id)),
                  );
                },
                child: Text("${AppLocalizations.of(context)!.translate("buy")}"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _getShippingPrice(String distance, Map<String, String> myBillingArray) {
    try {
      int distanceInt = double.parse(distance).round();
      return myBillingArray["$distanceInt"] ?? "~";
    } catch (e) {
      debugPrint("Error: $e");
      return "~";
    }
  }
}
