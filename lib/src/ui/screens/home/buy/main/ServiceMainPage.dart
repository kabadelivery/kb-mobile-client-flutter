import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/restaurant_list_contract.dart';
import 'package:KABA/src/contracts/restaurant_list_food_proposal_contract.dart';
import 'package:KABA/src/contracts/service_category_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/ServiceMainEntity.dart';
import 'package:KABA/src/ui/customwidgets/BuyCategoryWidget.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/customwidgets/SearchStatelessWidget.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/ShopListPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/utils/plus_code/open_location_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';

class ServiceMainPage extends StatefulWidget {
  static var routeName = "/ServiceMainPage";

  var argument;

  var destination;

  CustomerModel customer;

  ServiceMainPage({
    Key key,
    /*this.destination, this.argument*/
  }) : super(key: key);

  @override
  ServiceMainPageState createState() => ServiceMainPageState();
}

/* we show categories */
class ServiceMainPageState extends State<ServiceMainPage>
    implements ServiceMainView {
  bool isLoading;

  bool hasNetworkError;

  bool hasSystemError;

  List<ServiceMainEntity> available_services;

  List<ServiceMainEntity> coming_soon_services;

  @override
  void initState() {
    super.initState();
    available_services = [
      ServiceMainEntity()..category_id = 1001,
      ServiceMainEntity()..category_id = 1002,
      ServiceMainEntity()..category_id = 1003,
      ServiceMainEntity()..category_id = 1004,
    ];

    coming_soon_services = [
      ServiceMainEntity()..category_id = 1005,
      ServiceMainEntity()..category_id = 1006,
      ServiceMainEntity()..category_id = 1007,
    ];
    hasSystemError = false;
    hasNetworkError = false;
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: KColors.primaryColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  Utils.capitalize(
                      "${AppLocalizations.of(context).translate('buy')}"),
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: SafeArea(
                top: true,
                child: Container(
                  child: Container(
                      child: isLoading
                          ? Center(child: MyLoadingProgressWidget())
                          : (hasNetworkError
                              ? _buildNetworkErrorPage()
                              : hasSystemError
                                  ? _buildSysErrorPage()
                                  : _buildServicePage())),
                ))));
  }

  _buildSysErrorPage() {
    return Center(child: Text("sys error"));
  }

  _buildNetworkErrorPage() {
    return Center(child: Text("network error"));
  }

  _buildServicePage() {
    return Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              StateContainer?.of(context)?.location != null
                  ? Center(
                      child: InkWell(
                        child: Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  child: Icon(Icons.location_on,
                                      color: Colors.white, size: 20),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: KColors.mBlue),
                                  padding: EdgeInsets.all(7)),
                              Container(
                                padding:
                                    EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 10),
                                decoration: BoxDecoration(
                                    color: KColors.mBlue.withAlpha(30),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                child: Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Text(
                                        "${_locationToPlusCode(StateContainer.of(context).location)}",
                                        style: TextStyle(color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14)),
                                    SizedBox(width: 10),
                                    Icon(
                                      FontAwesome.copy,
                                      size: 14,
                                      color: KColors.primaryColor.withAlpha(150),
                                    )
                                  ],
                                ),
                              ),
                              // Text("${StateContainer.of(context).location.latitude}:${StateContainer.of(context).location.longitude}")
                            ],
                          ),
                        ),
                      onTap: ()=> {
                          _pickMyAddress()
                      },
                      ),
                    )
                  : Container(),
              InkWell(
                  child: SearchStatelessWidget(
                      title:
                          "${AppLocalizations.of(context).translate("what_want_buy")}"),
                  onTap: () {
                    _jumpToSearchPage(0);
                  }),
              GridView(
                physics: BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 2,
                  childAspectRatio: 2.7,
                ),
                shrinkWrap: true,
                children: [
                  BuyCategoryWidget(available_services[0]),
                  BuyCategoryWidget(available_services[1]),
                  BuyCategoryWidget(available_services[2]),
                  BuyCategoryWidget(available_services[3]),
                ],
              ),
              SizedBox(height: 30),
              Opacity(
                opacity: 0.5,
                child: Container(
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            padding: EdgeInsets.only(left: 30),
                            child: Text(
                                "${AppLocalizations.of(context).translate('coming_soon')}")),
                      ],
                    ),
                    GridView(
                      physics: BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: 2,
                        childAspectRatio: 2.7,
                      ),
                      shrinkWrap: true,
                      children: [
                        BuyCategoryWidget(coming_soon_services[0],
                            available: false),
                        BuyCategoryWidget(coming_soon_services[1],
                            available: false),
                        BuyCategoryWidget(coming_soon_services[2],
                            available: false),
                      ],
                    ),
                  ]),
                ),
              )
            ],
          ),
        )
        /*Column(
        children: [
          GridView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: available_services.length,
              itemBuilder: (context, index) =>
                  (BuyCategoryWidget(available_services[index])),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 2,
                childAspectRatio: 2,
              )),
        ],
      ),*/
        );
  }

  void _jumpToSearchPage(int i) {
    _jumpToPage(
        context,
        ShopListPage(
            context: context,
            foodProposalPresenter: RestaurantFoodProposalPresenter(),
            restaurantListPresenter: RestaurantListPresenter()));
  }

  void _jumpToPage(BuildContext context, page) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => page,
        ));
  }

  @override
  void inflateServiceCategory(List<ServiceMainEntity> data) {}

  @override
  void networkError() {}

  @override
  void showLoading(bool isLoading) {}

  @override
  void systemError() {}

  _locationToPlusCode(Position location) {
    return encode(location.latitude, location.longitude);
  }

  _pickMyAddress() {
    /* pick my location */
  }

}
