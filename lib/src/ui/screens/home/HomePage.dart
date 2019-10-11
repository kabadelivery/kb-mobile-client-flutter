import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/contracts/home_welcome_contract.dart';
import 'package:kaba_flutter/src/ui/screens/home/restaurant/RestaurantListPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';

import '_home/HomeWelcomePage.dart';
import 'me/MeAccountPage.dart';
import 'orders/DailyOrdersPage.dart';

class HomePage extends StatefulWidget {

  static var routeName = "/HomePage";

  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  static final List<String> popupMenus = ["Settings"];
  var _selectedIndex = 0;

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

  @override
  void initState() {
    // TODO: implement initState
    homeWelcomePage = HomeWelcomePage(key: homeKey);
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
        child:   pages[_selectedIndex],
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
        currentIndex: _selectedIndex,
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
      _selectedIndex = value;
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
