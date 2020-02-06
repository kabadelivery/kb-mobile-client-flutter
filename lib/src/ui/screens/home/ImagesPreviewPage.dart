import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/contracts/ads_viewer_contract.dart';
import 'package:kaba_flutter/src/contracts/ads_viewer_contract.dart';
import 'package:kaba_flutter/src/contracts/ads_viewer_contract.dart';
import 'package:kaba_flutter/src/contracts/ads_viewer_contract.dart';
import 'package:kaba_flutter/src/contracts/login_contract.dart';
import 'package:kaba_flutter/src/contracts/menu_contract.dart';
import 'package:kaba_flutter/src/models/AdModel.dart';
import 'package:kaba_flutter/src/models/RestaurantFoodModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/ui/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:kaba_flutter/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:kaba_flutter/src/ui/screens/restaurant/food/RestaurantFoodDetailsPage.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';
import 'package:photo_view/photo_view.dart';
import 'package:toast/toast.dart';
//import 'package:photo_view/photo_view.dart';


class ImagesPreviewPage extends StatefulWidget {

  static var routeName = "/ImagesPreviewPage";

  AdsViewerPresenter presenter;

  /* list of ads */
  List<AdModel> data;

  ImagesPreviewPage({Key key, this.data, this.presenter}) : super(key: key);


  @override
  _ImagesPreviewPageState createState() => _ImagesPreviewPageState();
}

class _ImagesPreviewPageState extends State<ImagesPreviewPage> implements AdsViewerView {

  int _carousselPageIndex = 0;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    widget.presenter.adsViewerView = this;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(icon: SizedBox(
              height: 25,
              width: 25,
              child: IconButton(icon: Icon(Icons.close, color: Colors.white))), onPressed: (){Navigator.pop(context);}),
        ),
        backgroundColor: Colors.black,
        body: Stack(
          children: <Widget>[
            Center(
              child: Container(
                // center a picture thing in the middle
                child:   Stack(
                  children: <Widget>[
                    ClipPath(
                        child:CarouselSlider(
                          onPageChanged: _carousselPageChanged,
                          viewportFraction: 1.0,
//                      autoPlay: widget.data.length > 1 ? true:false,
                          enableInfiniteScroll: widget.data.length > 1 ? true:false,
                          height:  MediaQuery.of(context).size.width,
                          items: widget.data.map((admodel) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
//                                    height: 9*MediaQuery.of(context).size.width/16,
                                    height: MediaQuery.of(context).size.width,
                                    width: MediaQuery.of(context).size.width,
                                    child:CachedNetworkImage(
                                        imageUrl: Utils.inflateLink(admodel.pic),
                                        fit: BoxFit.contain
                                    )
//                                    child: PhotoView(
//                                      imageProvider: NetworkImage(Utils.inflateLink(admodel.pic), scale: 1.0),
//                                    )
                                );
                              },
                            );
                          }).toList(),
                        )),
                    Positioned(
                        bottom: 10,
                        right:0,
                        child:Padding(
                          padding: const EdgeInsets.only(right:9.0),
                          child: Row(
                            children: <Widget>[]
                              ..addAll(
                                  List<Widget>.generate(widget.data.length, (int index) {
                                    return Container(
                                        margin: EdgeInsets.only(right:2.5, top: 2.5),
                                        height: 9,width:9,
                                        decoration: new BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                                            border: new Border.all(color: Colors.white),
                                            color: (index==_carousselPageIndex || index==widget.data.length)?Colors.white : Colors.transparent
                                        ));
                                  })
                                /* add a list of rounded views */
                              ),
                          ),
                        )
                    ),
                  ],
                ),
              ),
            ),
            _getVoirMenuTextFromAd(widget.data[_carousselPageIndex]) != "" ?
             Positioned(top: 0,right: 10,
                child: OutlineButton(onPressed: () => _onAdsButtonPressed(widget.data[_carousselPageIndex]), color: Colors.transparent, borderSide: BorderSide(color: Colors.white, width: 1),
                    child: Row(
                      children: <Widget>[
                        Text(_getVoirMenuTextFromAd(widget.data[_carousselPageIndex]), style: TextStyle(color: Colors.white)),
                        /* circular progress */
                        isLoading ? Row(
                          children: <Widget>[
                            SizedBox(width: 5,),
                            SizedBox(height: 20, width: 20,child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.white)))
                          ],
                        ) : Container(),
                      ],
                    ))) : Container(),
            Positioned(
                bottom: 10,
                left: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.all(4),
                      child: Text(widget.data[_carousselPageIndex]?.description,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 7,
                          style: TextStyle(color: Colors.white))),
                )
            )
          ],
        ));
  }

  _carousselPageChanged(int index) {
    setState(() {
      _carousselPageIndex = index;
    });
  }

  String _getVoirMenuTextFromAd(AdModel data) {
    switch(data.type){
      case AdModel.TYPE_REPAS:
        return "VOIR REPAS";
        break;
      case AdModel.TYPE_ARTICLE:
        return "VOIR ARTICLE";
        break;
      case AdModel.TYPE_ARTICLE_WEB:
        return "VOIR SITE WEB";
        break;
      case AdModel.TYPE_MENU:
        return "VOIR MENU";
        break;
      case AdModel.TYPE_RESTAURANT:
        return "VOIR RESTAURANT";
        break;
      default:
        return "";
    }
  }

  _onAdsButtonPressed(AdModel data) {

    /* jump to supposed activity */
    switch(data.type){
      case AdModel.TYPE_REPAS:
        widget.presenter.loadFoodFromId(data.entity_id);
        break;
//      case AdModel.TYPE_ARTICLE:
//        break;
      case AdModel.TYPE_ARTICLE_WEB:
      // go the article page.
        break;
      case AdModel.TYPE_MENU:
        widget.presenter.loadRestaurantFromId(data.entity_id, /* for menu */1);
        break;
      case AdModel.TYPE_RESTAURANT:
      // use the id and get the restaurant id for here.
        widget.presenter.loadRestaurantFromId(data.entity_id, /* for details */2);
        break;
    }
  }

  @override
  void requestFailure(String message) {
    showLoading(false);
    // toast
    Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }

  @override
  void showLoading(bool isLoading) {
    // show loading into the page
    setState(() {
      this.isLoading = isLoading;
    });
  }


  @override
  void updateFood(RestaurantFoodModel foodModel) {
    showLoading(false);
    // jump to restaurant
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantFoodDetailsPage(food: foodModel),
      ),
    );
  }

  @override
  void updateRestaurantForDetails(RestaurantModel restaurantModel) {
    showLoading(false);
    // jump to restaurant
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailsPage(restaurant: restaurantModel),
      ),
    );
  }

  @override
  void updateRestaurantForMenu(RestaurantModel restaurantModel) {
    showLoading(false);
    // jump to restaurant
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantMenuPage(restaurant: restaurantModel, presenter: MenuPresenter()),
      ),
    );
  }

}
