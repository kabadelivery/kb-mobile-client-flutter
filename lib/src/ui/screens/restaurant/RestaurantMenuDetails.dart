import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:KABA/src/contracts/order_contract.dart';
import 'package:KABA/src/models/RestaurantFoodModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderConfirmationPage.old';
import 'package:KABA/src/ui/screens/home/orders/OrderConfirmationPage2.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:iphone_has_notch/iphone_has_notch.dart';
import 'package:toast/toast.dart';


class RestaurantMenuDetails extends StatefulWidget {

  static var routeName = "/RestaurantMenuDetails";

  Map<RestaurantFoodModel, int> food_selected, adds_on_selected;

  /* 1 - food, 2- addons, 3 - all */
  int type;

  int FOOD_MAX;

  RestaurantModel restaurant;

  RestaurantMenuDetails({Key key, this.FOOD_MAX = 5, this.type, this.food_selected, this.adds_on_selected, this.restaurant}) : super(key: key);

  @override
  _RestaurantMenuDetailsState createState() => _RestaurantMenuDetailsState(type, food_selected, adds_on_selected);
}

class _RestaurantMenuDetailsState extends State<RestaurantMenuDetails> {

  Map<RestaurantFoodModel, int> food_selected, adds_on_selected;

  /* 1 - food, 2- addons, 3 - all */
  int type;

  int _foodCount = 0;

//  , ADD_ON_COUNT = 10;
  int totalPrice = 0;

  _RestaurantMenuDetailsState(this.type, this.food_selected, this.adds_on_selected);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _updateCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar (
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Container(decoration: BoxDecoration(color: KColors.primaryColor, borderRadius: BorderRadius.all(Radius.circular(10))),
            padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
            child: Row(mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("${totalPrice}", overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 20,color: Colors.white)),
                SizedBox(width: 5),
                Text("${AppLocalizations.of(context).translate('currency')}", overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12,color: Colors.white)),
              ],
            )),
        leading: IconButton(icon: Icon(Icons.close, color: Colors.black), onPressed: (){Navigator.pop(context);}),
      ),
      body: Container(color: Colors.white, child: _showMenuBottomSheet(context, type), height: MediaQuery.of(context).size.height),
    );
  }

/* build bottom_sheet_items_widget */
  Widget _buildBottomSheetFoodListWidget({RestaurantFoodModel food}) {
    return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("${food?.name.toUpperCase()}", overflow: TextOverflow.ellipsis,maxLines: 3, textAlign: TextAlign.left, style: TextStyle(color:Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
            SizedBox(height: 5),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  /*prix*/
                  Row(children: <Widget>[
                    Text("${food?.price}", overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryYellowColor, fontSize: 20, fontWeight: FontWeight.normal)),
                    (food.promotion!=0 ? Text("${food?.promotion_price}",  overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryColor, fontSize: 20, fontWeight: FontWeight.normal, decoration: TextDecoration.lineThrough))
                        : Container()),
                    Text("${AppLocalizations.of(context).translate('currency')}", overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryYellowColor, fontSize: 10, fontWeight: FontWeight.normal)),
                  ]),
                  /* add buttons */
                  Row(
                      children: <Widget>[
                        IconButton(icon: Icon(Icons.remove_circle, color: Colors.black), onPressed: () => _decreaseQuantity(food)),
                        SizedBox(width: 2),
                        Container(margin: EdgeInsets.only(top:0),child: Text("${food.is_addon ? adds_on_selected[food].toInt() : food_selected[food].toInt()}", style: TextStyle(color: Colors.black, fontSize: 18))),
                        SizedBox(width: 2),
                        IconButton(icon: Icon(Icons.add_circle, color: Colors.black), onPressed: () => _increaseQuantity(food)),
                        SizedBox(width: 10),
                        IconButton(icon:Icon(Icons.delete_forever, color: KColors.primaryColor,), onPressed: () {_removeFood(food);}),
                      ]
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }


  /* we have different types: food, supplement, all */
  _showMenuBottomSheet(context, int type) {

    List<Widget> bottomSheetView = <Widget>[
      SizedBox(height: 10),
      Center(child: Container(decoration: BoxDecoration(color: KColors.primaryYellowColor, borderRadius: BorderRadius.all(Radius.circular(10))), margin: EdgeInsets.only(top:10), padding: EdgeInsets.only(left:10, right: 10, top:5, bottom: 5),
          child: Text("${AppLocalizations.of(context).translate('all')}".toUpperCase(), style: TextStyle(color:Colors.white),textAlign: TextAlign.center))),
      SizedBox(height: 10),
    ];

    if (type == 1 || type == 3) {
      /* generate the food views */
      if (food_selected != null && food_selected.length > 0)
        bottomSheetView..addAll(
            food_selected.keys.map((mfood) => _buildBottomSheetFoodListWidget(food: mfood)).toList()
        );
      bottomSheetView.add(SizedBox(height: 10));
    }

    if (type == 2 || type == 3) {
      /* generate the food views */
      if (adds_on_selected != null && adds_on_selected.length > 0)
        bottomSheetView..addAll(
            adds_on_selected.keys.map((mfood) => _buildBottomSheetFoodListWidget(food: mfood)).toList()
        );
      bottomSheetView.add(SizedBox(height: 10));
    }

    bottomSheetView.add(SizedBox(height:140));

    return Stack(
      children: <Widget>[
        Container(
          color: Colors.white,
          child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 0),
              child: Wrap(children: bottomSheetView)
          ),
        ),
        totalPrice > 0 ? Positioned(bottom: 0,child: Container(height: 50,width: MediaQuery.of(context).size.width,child:
        RaisedButton(
            child: Container(child:  Text("${AppLocalizations.of(context).translate('buy')}", style: TextStyle(color:Colors.white)),
            padding: EdgeInsets.only(bottom: IphoneHasNotch.hasNotch ? 20 : 0),),
            color: Colors.black, onPressed: () {_continuePurchase();}))) : Container(),
      ],
    );
  }

  _decreaseQuantity(RestaurantFoodModel food) {

    if (!food.is_addon) {
      if (food_selected.containsKey(food)) {
        if (food_selected[food].toInt() > 1)
          food_selected.update(food, (int val) => food_selected[food].toInt()-1);
        else {
          showToast("${AppLocalizations.of(context).translate('min_reached')}");
        }
      } else {
        food_selected.putIfAbsent(food, ()=>1);
      }
    } else {
      if (!food.is_addon) {
        if (adds_on_selected.containsKey(food)) {
          if (adds_on_selected[food].toInt() > 1)
            adds_on_selected.update(food, (int val) => adds_on_selected[food].toInt()-1);
          else{
            showToast("${AppLocalizations.of(context).translate('min_reached')}");
          }
        } else {
          adds_on_selected.putIfAbsent(food, ()=>1);
        }
      }
    }
    _updateCounts();
  }

  _increaseQuantity(RestaurantFoodModel food) {
    if (_foodCount >= widget.FOOD_MAX) {
      showToast("${AppLocalizations.of(context).translate('max_reached')}");
      return;
    } else {
      /* if max is reached, we dont increase */
      if (!food.is_addon) {
        if (food_selected.containsKey(food)) {
          food_selected.update(
              food, (int val) => 1 + food_selected[food].toInt());
        } else {
          food_selected.putIfAbsent(food, () => 1);
        }
      } else {
        if (!food.is_addon) {
          if (adds_on_selected.containsKey(food)) {
            adds_on_selected.update(
                food, (int val) => 1 + adds_on_selected[food].toInt());
          } else {
            adds_on_selected.putIfAbsent(food, () => 1);
          }
        }
      }
      _updateCounts();
    }
  }

  void _updateCounts() {

    int tp = 0;
    int fc = 0; food_selected.forEach((RestaurantFoodModel food, int quantity) {fc+=quantity;tp+=(int.parse(food.promotion==0?food.price:food.promotion_price)*quantity);});
    int adc = 0; adds_on_selected.forEach((RestaurantFoodModel food, int quantity) {adc+=quantity;tp+=(int.parse(food.promotion==0?food.price:food.promotion_price)*quantity);});
    setState(() {
      _foodCount = fc;
//      _addOnCount = adc;
      totalPrice = tp;
    });
  }

  void showToast(String message) {
    Toast.show(message, context, duration: Toast.LENGTH_LONG, gravity:  Toast.CENTER);
  }

  void _removeFood(RestaurantFoodModel food) {
    if (!food.is_addon) {
      if (food_selected.containsKey(food)) {
        food_selected.removeWhere((RestaurantFoodModel mFood, int value){return (mFood==food);});
      }
    } else {
      if (!food.is_addon) {
        if (adds_on_selected.containsKey(food)) {
          adds_on_selected.removeWhere((RestaurantFoodModel mFood, int value){return (mFood==food);});
        }
      }
    }
    _updateCounts();
  }

  void _continuePurchase() {

    /* data */
    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationPage2(restaurant: widget.restaurant,presenter: OrderConfirmationPresenter(), foods: food_selected, addons: adds_on_selected),
      ),
    );*/

    Navigator.of(context).push(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
            OrderConfirmationPage2(restaurant: widget.restaurant,presenter: OrderConfirmationPresenter(), foods: food_selected, addons: adds_on_selected),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween = Tween(begin:begin, end:end);
              var curvedAnimation = CurvedAnimation(parent:animation, curve:curve);
              return SlideTransition(position: tween.animate(curvedAnimation), child: child);
            }
        ));
  }

}
