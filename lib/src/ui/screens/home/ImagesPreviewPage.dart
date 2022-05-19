import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:KABA/src/xrint.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/contracts/ads_viewer_contract.dart';
import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/restaurant_details_contract.dart';
import 'package:KABA/src/models/AdModel.dart';
import 'package:KABA/src/models/RestaurantFoodModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:KABA/src/ui/screens/restaurant/food/RestaurantFoodDetailsPage.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';


class AdsPreviewPage extends StatefulWidget {

  static var routeName = "/AdsPreviewPage";

  AdsViewerPresenter presenter;

  /* list of ads */
  List<AdModel> data;

  int position;

  AdsPreviewPage({Key key, this.data, this.presenter, this.position = 0}) : super(key: key);


  @override
  _AdsPreviewPageState createState() => _AdsPreviewPageState();
}

class _AdsPreviewPageState extends State<AdsPreviewPage> implements AdsViewerView {

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
          brightness: Brightness.dark,
          backgroundColor: Colors.transparent,
          leading: IconButton(icon: SizedBox(
              height: 25,
              width: 25,
              child: IconButton(icon: Icon(Icons.close, color: Colors.white))), onPressed: (){Navigator.pop(context);}),
        ),
        backgroundColor: Colors.black,
        body: Stack(
          children: <Widget>[
            Container(
              // color: Colors.red,
              // center a picture thing in the middle
              child:   Center(
                child: Container(
                  height:  MediaQuery.of(context).size.width,
                  child: Stack(
                    children: <Widget>[
                      ClipPath(
                          child:CarouselSlider(
                            options: CarouselOptions(
                              onPageChanged: _carousselPageChanged,
                              viewportFraction: 1.0,
                              initialPage: widget.position,
//                      autoPlay: widget.data.length > 1 ? true:false,
                              enableInfiniteScroll: widget.data.length > 1 ? true:false,
                            height:  MediaQuery.of(context).size.width,
                            ),
                            items: widget.data.map((admodel) {
                              return Builder(
                                builder: (BuildContext context) {
//                                PinchZoom(
//                                    image: Image.network('http://placerabbit.com/200/333'),
//                                    zoomedBackgroundColor: Colors.black.withOpacity(0.5),
//                                    resetDuration: const Duration(milliseconds: 100),
//                                    maxScale: 2.5,
                                  return PinchZoom(
                                  child: Container(
                                    // color: Colors.blueAccent,
//                                    height: 9*MediaQuery.of(context).size.width/16,
//                                       height: MediaQuery.of(context).size.width,
                                        child:CachedNetworkImage(
                                            imageUrl: Utils.inflateLink(admodel.pic),
                                            fit: BoxFit.fitWidth,
                                          progressIndicatorBuilder: (context, url, downloadProgress) =>
                                              CircularProgressIndicator(value: downloadProgress.progress),
                                        )
//                                    child: PhotoView(
//                                      imageProvider: NetworkImage(Utils.inflateLink(admodel.pic), scale: 1.0),
//                                    )
                                    ),
                                    // zoomedBackgroundColor: Colors.black,
                                      resetDuration: const Duration(milliseconds: 100),
                                      maxScale: 2.5,
                                    onZoomStart: (){},
                                    onZoomEnd: () {},
                                  );
                                },
                              );
                            }).toList(),
                          )),
                    widget?.data?.length > 1 ?  Positioned(
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
                                              color: (index==widget.position || index==widget.data.length)?Colors.white : Colors.transparent
                                          ));
                                    })
                                  /* add a list of rounded views */
                                ),
                            ),
                          )
                      ) : Container(),
                    ],
                  ),
                ),
              ),
            ),
            _getVoirMenuTextFromAd(widget.data[widget.position]) != "" ?
            Positioned(top: 0,right: 10,
                child:  OutlinedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent),side: MaterialStateProperty.all(BorderSide(color: Colors.white, width: 1))),
                    onPressed: () => _onAdsButtonPressed(widget.data[widget.position]),
                   
                    child: Row(
                      children: <Widget>[
                        /* circular progress */
                        isLoading ? Row(
                          children: <Widget>[
                            SizedBox(height: 12, width: 12,child: MyLoadingProgressWidget(color: Colors.white)),
                            SizedBox(width: 5),
                          ],
                        ) : Container(),
                        Text(_getVoirMenuTextFromAd(widget.data[widget.position]), style: TextStyle(color: Colors.white)),
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
                      child: Text("${widget.data[widget.position]?.description == null ? "" : widget.data[widget.position]?.description}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 7,
                          style: TextStyle(color: Colors.white))),
                )
            )
          ],
        ));
  }

  _carousselPageChanged(int index, CarouselPageChangedReason changedReason) {
    setState(() {
      widget.position = index;
    });
  }

  String _getVoirMenuTextFromAd(AdModel data) {
    switch(data.type){
      case AdModel.TYPE_REPAS:
        return "${AppLocalizations.of(context).translate('ad_check_food')}";
        break;
      case AdModel.TYPE_ARTICLE:
        return "${AppLocalizations.of(context).translate('ad_check_article')}";
        break;
      case AdModel.TYPE_ARTICLE_WEB:
        return "${AppLocalizations.of(context).translate('ad_check_website')}";
        break;
      case AdModel.TYPE_MENU:
        return "${AppLocalizations.of(context).translate('ad_check_menu')}";
        break;
      case AdModel.TYPE_RESTAURANT:
        return "${AppLocalizations.of(context).translate('ad_check_restaurant')}";
        break;
      default:
        return "";
    }
  }

  Future<dynamic> _launchURL(String url) async {
    if (await canLaunch(url)) {
      return await launch(url);
    } else {
      try {
        throw 'Could not launch $url';
      } catch (_) {
       xrint(_);
      }
    }
    return -1;
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
      // go the article page //
     xrint("Go to link -> ${ServerConfig.SERVER_ADDRESS+"/api/link/${data.link}"}");
        _launchURL(ServerConfig.SERVER_ADDRESS+"/api/link/${data.link}");
        break;
      case AdModel.TYPE_RESTAURANT:
        widget.presenter.loadRestaurantFromId(data.entity_id, /* for menu 1*/);
        break;
      case AdModel.TYPE_MENU:
      // use the id and get the restaurant id for here.
        _jumpToRestaurantMenuPage(data.entity_id);
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
        builder: (context) => RestaurantDetailsPage(restaurant: restaurantModel, presenter: RestaurantDetailsPresenter()),
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

  void _jumpToRestaurantMenuPage(int entity_id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantMenuPage(menuId: entity_id, presenter: MenuPresenter()),
      ),
    );
  }

}
