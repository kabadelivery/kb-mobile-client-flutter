import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kaba_flutter/src/contracts/customercare_contract.dart';
import 'package:kaba_flutter/src/contracts/feeds_contract.dart';
import 'package:kaba_flutter/src/contracts/personal_page_contract.dart';
import 'package:kaba_flutter/src/contracts/topup_contract.dart';
import 'package:kaba_flutter/src/contracts/transaction_contract.dart';
import 'package:kaba_flutter/src/contracts/transfer_money_request_contract.dart';
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/address/MyAddressesPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/customer/care/CustomerCareChatPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/money/TopUpPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/money/TransactionHistoryPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/personnal/Personal2Page.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/personnal/PersonalPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/settings/SettingsPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/vouchers/MyVouchersPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/orders/LastOrdersPage.dart';
import 'package:kaba_flutter/src/ui/screens/splash/SplashPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/_static_data/Vectors.dart';
import 'package:kaba_flutter/src/utils/functions/CustomerUtils.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../StateContainer.dart';
import 'feeds/FeedsPage.dart';
import 'money/TransferMoneyRequestPage.dart';


class MeAccountPage extends StatefulWidget {

    CustomerModel customerData;

  MeAccountPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MeAccountPageState createState() => _MeAccountPageState();
}

class _MeAccountPageState extends State<MeAccountPage> with TickerProviderStateMixin{

  ScrollController _scrollController = ScrollController();

  StateContainerState container;

  static final List<String> popupMenus = ["Logout","Settings"];

  @override
  void initState() {
    super.initState();
  }

  static getCustomer () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonCustomer = prefs.getString("_customer");
    String token = prefs.getString("_token");
    CustomerModel cm = CustomerModel.fromJson(json.decode(jsonCustomer));
    cm.token = token;
    return cm;
  }



  void menuChoiceAction(String value) {
    /* jump to the other activity */
    switch(popupMenus.indexOf(value)) {
      case 0:
      /* logout */
        CustomerUtils.clearCustomerInformations().whenComplete((){
          //       get back to the splash page.
//          Navigator.popUntil(context, ModalRoute.withName(SplashPage.routeName));
          Navigator.pushNamedAndRemoveUntil(context, SplashPage.routeName, (r) => false);
        });
        break;
      case 1:
         _jumpToPage(context, SettingsPage());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
        child: widget.customerData != null ? _buildMyPage(widget.customerData) : FutureBuilder(
            future: CustomerUtils.getCustomer(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return _buildMyPage(snapshot.data);
              } else if (snapshot.hasError) {
                /* go back to login page because of error in login or so. */
              }
              return Center(child: CircularProgressIndicator());
            }
        )
      )
    );
  }


  void _jumpToPage (BuildContext context, page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  Widget _buildMyPage(data) {

    widget.customerData = data;

    double expandedHeight = 9*MediaQuery.of(context).size.width/16 + 20;
    var flexibleSpaceWidget = new SliverAppBar(
      actions: <Widget>[
        IconButton(icon: Icon(FontAwesomeIcons.sms,color: Colors.white), onPressed: (){_jumpToPage(context, CustomerCareChatPage(presenter: CustomerCareChatPresenter()));}),
        PopupMenuButton<String>(
          onSelected: menuChoiceAction,
          itemBuilder: (BuildContext context) {
            return popupMenus.map((String menuName){
              return PopupMenuItem<String>(value: menuName, child: Text(menuName));
            }).toList();
          },
        )
      ],
//      leading: IconButton(tooltip: "Scanner", icon: Icon(Icons.center_focus_strong), onPressed: (){_jumpToScanPage();}),
    leading: null,
      expandedHeight: expandedHeight,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.parallax,
          centerTitle: true,
          /*title: Text("",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))*/
          background: Container(
            child:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    height:100, width: 100,
                    decoration: BoxDecoration(
                        border: new Border.all(color: Colors.white, width: 2),
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(Utils.inflateLink(widget.customerData.profile_picture))
                        )
                    )
                ),
                Container(
                    padding: EdgeInsets.only(right:20),
                    child:Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(widget.customerData.nickname, style:TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
                          SizedBox(height:10),
                          Text("XXXX${widget.customerData.username.substring(4)}", style:TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.right,),
                        ])
                )],
            ),
            padding:EdgeInsets.all(10),
            color: KColors.primaryYellowColor,
          )),
    );

    return  new DefaultTabController(
      length: 1,
      child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              flexibleSpaceWidget,
            ];
          },
          body:
          SingleChildScrollView(
            child:   Column(
                children: <Widget>[
                  /* top-up & xof */
                  Container(
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(flex:1,
                            child: InkWell(
                              onTap:()=> _jumpToPage(context, TransactionHistoryPage(presenter: TransactionPresenter())),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    IconButton (icon:Icon(Icons.monetization_on, color: KColors.primaryColor, size: 40)),
                                    SizedBox(height:10),
                                    Text("XOF ${StateContainer.of(context).balance == null ? "" : StateContainer.of(context).balance}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(flex:1,
                            child: InkWell(
                              onTap: () => _jumpToPage(context, TopUpPage(presenter: TopUpPresenter())),
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    IconButton (icon:Icon(Icons.show_chart, color: KColors.primaryColor, size: 40)),
                                    SizedBox(height:5),
                                    Text("Top Up", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(flex:1,
                            child: InkWell(
                              onTap: () => _jumpToPage(context,  TransferMoneyRequestPage(presenter: TransferMoneyRequestPresenter())),
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    IconButton (icon:Icon(Icons.send, color: KColors.primaryColor, size: 40)),
                                    SizedBox(height:5),
                                    Text("Transfer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                  /* do you have  a suggestion ? */
                  Container(
                      padding: EdgeInsets.only(top:20, bottom:20),
                      color: Colors.grey.shade100,
                      child:Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            InkWell(onTap: (){},
                                child:Container(
                                    decoration: BoxDecoration(color:Colors.white, borderRadius: new BorderRadius.only(topRight:  const  Radius.circular(20.0), bottomRight: const  Radius.circular(20.0))),
                                    padding: EdgeInsets.only(left:10),
                                    child:
                                    Row(children:<Widget>[
                                      Text("Do you have any suggestion from us ?", style: TextStyle(color: KColors.primaryYellowColor)),
                                      IconButton(onPressed: null, icon: Icon(Icons.chevron_right, color: KColors.primaryColor))
                                    ]
                                    )))
                          ])),
                  /* menu box */
                  Card(
                      elevation: 8.0,
                      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                      child: Container(
                          decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1), borderRadius: BorderRadius.all(Radius.circular(7)),   boxShadow: [
                            new BoxShadow(
                              color: Colors.grey..withAlpha(50),
                              offset: new Offset(0.0, 2.0),
                            )
                          ]),
                          child: Table(
                            /* menus */
                              children: <TableRow>[
                                TableRow(
                                    children:<TableCell> [
                                      TableCell(
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              IconButton (icon:Icon(Icons.person, color: KColors.primaryYellowColor),iconSize: 50, onPressed: () =>_jumpToPage(context, Personal2Page(customer: widget.customerData, presenter: PersonnalPagePresenter(),))),
                                              SizedBox(height:10),
                                              Text("PERSONNAL", style: TextStyle(color: KColors.primaryYellowColor, fontSize: 16),)
                                            ],
                                          ),
                                        ),
                                      ),
                                  /*    TableCell(
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              IconButton(icon: SizedBox(
                                                  height: 60,
                                                  width: 60,
                                                  child: SvgPicture.asset(
                                                    VectorsData.ic_voucher,
                                                    color: KColors.primaryColor,
                                                  )),iconSize: 50, onPressed: () =>_jumpToPage(context, MyVouchersPage())),
                                              SizedBox(height:10),
                                              Text("VOUCHERS", style: TextStyle(color: KColors.primaryColor, fontSize: 16),)
                                            ],
                                          ),
                                        ),
                                      ),*/
                                      TableCell(
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              IconButton (icon:Icon(Icons.location_on, color: KColors.primaryYellowColor, size: 60),iconSize: 50,  onPressed: () =>_jumpToPage(context, MyAddressesPage())),
                                              SizedBox(height:10),
                                              Text("ADRESSES", style: TextStyle(color: KColors.primaryYellowColor, fontSize: 16),)
                                            ],
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              IconButton (icon:Icon(Icons.fastfood, color: KColors.primaryYellowColor, size: 60),iconSize: 50, onPressed: () =>_jumpToPage(context, LastOrdersPage())),
                                              SizedBox(height:10),
                                              Text("COMMAND", style: TextStyle(color: KColors.primaryYellowColor, fontSize: 16),)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]
                                ),
                                TableRow(
                                    children:<TableCell> [
                                      TableCell(
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              IconButton (icon:Icon(Icons.notifications, color: KColors.primaryColor, size: 60),iconSize: 50, onPressed: () =>_jumpToPage(context, FeedsPage(presenter: FeedPresenter()))),
                                              SizedBox(height:10),
                                              Text("FEEDS", style: TextStyle(color: KColors.primaryColor, fontSize: 16),)
                                            ],
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              IconButton (icon:Icon(Icons.settings, color: KColors.primaryYellowColor, size: 60),iconSize: 50, onPressed: () =>_jumpToPage(context, SettingsPage())),
                                              SizedBox(height:10),
                                              Text("SETTINGS", style: TextStyle(color: KColors.primaryYellowColor, fontSize: 16),)
                                            ],
                                          ),
                                        ),
                                      ),
                                      TableCell(child: Container())
                                    ]
                                )
                              ]
                          )
                      ))
                ]),
          )),
    );
  }

  void _jumpToTransactionHistory() {
    _jumpToPage(context, TransactionHistoryPage(presenter: TransactionPresenter()));
  }


}
