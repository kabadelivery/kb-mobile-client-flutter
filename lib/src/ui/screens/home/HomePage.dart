import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/StateContainer.dart';
import 'package:kaba_flutter/src/contracts/home_welcome_contract.dart';
import 'package:kaba_flutter/src/contracts/login_contract.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/ui/screens/auth/login/LoginPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/restaurant/RestaurantListPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/functions/CustomerUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '_home/HomeWelcomePage.dart';
import 'me/MeAccountPage.dart';
import 'orders/DailyOrdersPage.dart';

class HomePage extends StatefulWidget {

  static var routeName = "/HomePage";

  HomePage({Key key, this.title}) : super(key: key) ;

  final String title;


/*  static set setSelectedIndex(int index) {
    _selectedIndex = index;
  }

  static int get getSelectedIndex {
    return _selectedIndex;
  }*/

  @override
  _HomePageState createState() => _HomePageState();

  static void updateSelectedPage(int index) {
//    _selectedIndex = index;
  }
}

class _HomePageState extends State<HomePage> {

  static final List<String> popupMenus = ["Settings"];

  HomeWelcomePage homeWelcomePage;
  RestaurantListPage restaurantListPage;
  DailyOrdersPage dailyOrdersPage;
  MeAccountPage meAccountPage;

  List<StatefulWidget> pages;

  final PageStorageBucket bucket = PageStorageBucket();

  final PageStorageKey homeKey = PageStorageKey("homeKey"),
      restaurantKey = PageStorageKey("restaurantKey"),
      orderKey = PageStorageKey("orderKey"),
      meKey = PageStorageKey("meKey");

  Future checkLogin() async {

    StatefulWidget launchPage =  LoginPage(presenter: LoginPresenter());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String expDate = prefs.getString("_login_expiration_date");
    if (expDate != null) {
      if (DateTime.now().isAfter(DateTime.parse(expDate))) {
        /* session expired : clean params */
        prefs.remove("_customer");
        prefs.remove("_token");
        prefs.remove("_login_expiration_date");
      } else {
        launchPage = HomePage();
      }
    }
    /* Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (BuildContext context) => launchPagePath));*/
//    Navigator.pushNamedAndRemoveUntil(context, launchPagePath , (r) => false);


//    Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (BuildContext context) => launchPage), (r) => false);
  }

  @override
  void initState() {
    /* check the login status */
    checkLogin();
    homeWelcomePage = HomeWelcomePage(key: homeKey, presenter: HomeWelcomePresenter(),);
    restaurantListPage = RestaurantListPage(key: restaurantKey);
    dailyOrdersPage = DailyOrdersPage(key: orderKey);
    meAccountPage = MeAccountPage(key: meKey);
    pages = [homeWelcomePage, restaurantListPage, dailyOrdersPage, meAccountPage];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        child:   pages[  StateContainer.of(context).tabPosition],
        bucket: bucket,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            title: Text('Restaurant'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            title: Text('Orders'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('Account'),
          ),
        ],
        currentIndex:   StateContainer.of(context).tabPosition,
        selectedItemColor: KColors.primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }

  void menuChoiceAction(String value) {
    /* jump to the other activity */
  }

  void _onItemTapped(int value) {
    /* zwitch */
    setState(() {
//      HomePage._selectedIndex = value;
    StateContainer.of(context).updateTabPosition(tabPosition: value);
    });
  }
}

class AppbarhintFieldWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child:TextField(decoration: InputDecoration(border: OutlineInputBorder(), hintText:"Play basketball with us today", hintMaxLines: 1, hintStyle: TextStyle(color:Colors.white))),
      color: Colors.transparent,
    );
  }
}
