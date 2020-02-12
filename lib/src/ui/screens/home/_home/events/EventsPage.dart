import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/contracts/ads_viewer_contract.dart';
import 'package:kaba_flutter/src/contracts/bestseller_contract.dart';
import 'package:kaba_flutter/src/models/AdModel.dart';
import 'package:kaba_flutter/src/models/BestSellerModel.dart';
import 'package:kaba_flutter/src/models/EvenementModel.dart';
import 'package:kaba_flutter/src/models/RestaurantFoodModel.dart';
import 'package:kaba_flutter/src/ui/screens/home/ImagesPreviewPage.dart';
import 'package:kaba_flutter/src/ui/screens/message/ErrorPage.dart';
import 'package:kaba_flutter/src/ui/screens/restaurant/food/RestaurantFoodDetailsPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';


class EvenementPage extends StatefulWidget {

  static var routeName = "/EvenementPage";

  BestSellerPresenter presenter;

  EvenementPage({Key key, this.title, this.presenter}) : super(key: key);

  final String title;

  @override
  _EvenementPageState createState() => _EvenementPageState();
}

class _EvenementPageState extends State<EvenementPage> implements BestSellerView {


  List<EvenementModel> data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.presenter.bestSellerView = this;
    widget.presenter.fetchBestSeller();
  }

  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("EVENTS", style:TextStyle(color:KColors.primaryColor)),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
      ),
      body: Container(
          child: isLoading ? Center(child:CircularProgressIndicator()) : (hasNetworkError ? _buildNetworkErrorPage() : hasSystemError ? _buildSysErrorPage():
          _buildBSellerList())
      ),
    );
  }

  @override
  void inflateBestSeller(List<EvenementModel> bSellers) {

    showLoading(false);
    setState(() {
      this.data = bSellers;
    });
  }

  @override
  void networkError() {
    showLoading(false);
    /* show a page of network error. */
    setState(() {
      this.hasNetworkError = true;
    });
  }

  @override
  void showLoading(bool isLoading) {
    setState(() {
      this.isLoading = isLoading;
      if (isLoading == true) {
        this.hasNetworkError = false;
        this.hasSystemError = false;
      }
    });
  }

  @override
  void systemError() {
    showLoading(false);
    /* show a page of network error. */
    setState(() {
      this.hasSystemError = true;
    });
  }

  _buildSysErrorPage() {
    return ErrorPage(message: "System error.",onClickAction: (){ widget.presenter.fetchBestSeller(); });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(message: "Network error.",onClickAction: (){ widget.presenter.fetchBestSeller(); });
  }

  _buildBSellerList() {
    if (data == null) {
      /* just show empty page. */
      return _buildSysErrorPage();
    }
    return Container(
        margin: EdgeInsets.only(bottom:10, right:10, left:10),
        child: ListView.builder(itemCount: data?.length,
            itemBuilder: (BuildContext context, int position) {
              return Card(
                  child: InkWell(
                    onTap: ()=>_jumpToAdsList([]),
                    child: Container(
                      /*  */
                      child: Column(
                        /* text and image on top + plus category. */
                      ),
                    ),
                  )
              );
            }));
  }

  _jumpToFoodDetails(RestaurantFoodModel food_entity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantFoodDetailsPage (food: food_entity),
      ),
    );
  }

  _jumpToAdsList(List<AdModel> slider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdsPreviewPage(data: slider, presenter: AdsViewerPresenter()),
      ),
    );
  }

}
