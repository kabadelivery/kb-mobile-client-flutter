import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/address_contract.dart';
import 'package:KABA/src/contracts/restaurant_list_contract.dart';
import 'package:KABA/src/contracts/restaurant_list_food_proposal_contract.dart';
import 'package:KABA/src/contracts/service_category_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/ServiceMainEntity.dart';
import 'package:KABA/src/ui/customwidgets/BuyCategoryWidget.dart';
import 'package:KABA/src/ui/customwidgets/CurrentLocationTile.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/customwidgets/SearchStatelessWidget.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/ShopListPage.dart';
import 'package:KABA/src/ui/screens/home/me/address/MyAddressesPage.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/utils/plus_code/open_location_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';

class ServiceMainPage extends StatefulWidget {
  static var routeName = "/ServiceMainPage";

  var argument;

  var destination;

  ServiceMainPresenter presenter;

  CustomerModel customer;

  List<ServiceMainEntity> available_services = [];

  List<ServiceMainEntity> coming_soon_services = [];

  ServiceMainPage({Key key, this.presenter
      /*this.destination, this.argument*/
      })
      : super(key: key);

  @override
  ServiceMainPageState createState() => ServiceMainPageState();
}

/* we show categories */
class ServiceMainPageState extends State<ServiceMainPage>
    implements ServiceMainView {
  bool isLoading;

  bool hasNetworkError;

  bool hasSystemError;

  DeliveryAddressModel _selectedAddress;

  @override
  void initState() {
    super.initState();

    widget.presenter.serviceMainView = this;

    if (widget.available_services == null) widget.available_services = [];

    if (widget.coming_soon_services == null) widget.coming_soon_services = [];

    hasSystemError = false;
    hasNetworkError = false;
    isLoading = false;

    // launch service
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.available_services?.length == 0 &&
        widget.coming_soon_services?.length == 0)
      widget.presenter.fetchServiceCategoryFromLocation(
          StateContainer.of(context).location);
    // fetch billing and update locally
    widget.presenter.fetchBilling();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: StateContainer.ANDROID_APP_SIZE,
          brightness: Brightness.light,
          backgroundColor: KColors.primaryColor,
          actions: [Container(width: 40)],
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  Utils.capitalize(
                      "${AppLocalizations.of(context).translate('buy')}"),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
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
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('system_error')}",
        onClickAction: () {
          widget.presenter.fetchServiceCategoryFromLocation(
              StateContainer.of(context).location);
        });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('network_error')}",
        onClickAction: () {
          widget.presenter.fetchServiceCategoryFromLocation(
              StateContainer.of(context).location);
        });
  }

  _buildServicePage() {
    return Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              CurrentLocationTile(),
              InkWell(
                  child: SearchStatelessWidget(
                      title:
                          "${AppLocalizations.of(context).translate("what_want_buy")}"),
                  onTap: () {
                    _jumpToSearchPage("all");
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
                children: []..addAll(widget.available_services
                    .map((e) =>
                        BuyCategoryWidget(e, available: true, mDialog: mDialog))
                    .toList()),
              ),
              SizedBox(height: 30),
              widget.coming_soon_services?.length > 0
                  ? Opacity(
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
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              crossAxisCount: 2,
                              childAspectRatio: 2.7,
                            ),
                            shrinkWrap: true,
                            children: []..addAll(widget.coming_soon_services
                                .map((e) => BuyCategoryWidget(e,
                                    available: false, mDialog: mDialog))
                                .toList()),
                          ),
                        ]),
                      ),
                    )
                  : Container()
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

  void _jumpToSearchPage(String type) {
    _jumpToPage(
        context,
        ShopListPage(
            context: context,
            type: type,
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
  void inflateServiceCategory(List<ServiceMainEntity> data) {
    setState(() {
      widget.available_services = [];
      widget.coming_soon_services = [];
      for (int i = 0; i < data?.length; i++) {
        if (data[i].is_active == 1) {
          widget.available_services.add(data[i]);
        }
        if (data[i].is_coming_soon == 1) {
          widget.coming_soon_services.add(data[i]);
        }
      }
    });
  }

  @override
  void networkError() {
    if (widget?.available_services?.length == 0 &&
        widget?.coming_soon_services?.length == 0)
      setState(() {
        hasNetworkError = true;
      });
  }

  @override
  void showLoading(bool isLoading) {
    setState(() {
      this.isLoading = isLoading;
      hasNetworkError = false;
      hasSystemError = false;
    });
  }

  @override
  void systemError() {
    if (widget?.available_services?.length == 0 &&
        widget?.coming_soon_services?.length == 0)
      setState(() {
        hasSystemError = true;
      });
  }

  void mDialog(String message) {
    _showDialog(
      icon: Icon(Icons.info_outline, color: Colors.red),
      message: "${message}",
      isYesOrNo: false,
    );
  }

  void _showDialog(
      {String svgIcons,
      Icon icon,
      var message,
      bool okBackToHome = false,
      bool isYesOrNo = false,
      Function actionIfYes}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              SizedBox(
                  height: 80,
                  width: 80,
                  child: icon == null
                      ? SvgPicture.asset(
                          svgIcons,
                        )
                      : icon),
              SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: KColors.new_black, fontSize: 12))
            ]),
            actions: isYesOrNo
                ? <Widget>[
                    OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(
                              BorderSide(color: Colors.grey, width: 1))),
                      child: new Text(
                          "${AppLocalizations.of(context).translate('refuse')}",
                          style: TextStyle(color: Colors.grey)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(BorderSide(
                              color: KColors.primaryColor, width: 1))),
                      child: new Text(
                          "${AppLocalizations.of(context).translate('accept')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        actionIfYes();
                      },
                    ),
                  ]
                : <Widget>[
                    OutlinedButton(
                      child: new Text(
                          "${AppLocalizations.of(context).translate('ok')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ]);
      },
    );
  }
}
