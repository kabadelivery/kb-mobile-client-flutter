import 'package:KABA/src/contracts/add_vouchers_contract.dart';
import 'package:KABA/src/contracts/address_contract.dart';
import 'package:KABA/src/contracts/ads_viewer_contract.dart';
import 'package:KABA/src/contracts/customercare_contract.dart';
import 'package:KABA/src/contracts/feeds_contract.dart';
import 'package:KABA/src/contracts/personal_page_contract.dart';
import 'package:KABA/src/contracts/topup_contract.dart';
import 'package:KABA/src/contracts/transaction_contract.dart';
import 'package:KABA/src/contracts/transfer_money_request_contract.dart';
import 'package:KABA/src/contracts/vouchers_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/AdModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/ui/screens/home/ImagesPreviewPage.dart';
import 'package:KABA/src/ui/screens/home/_home/InfoPage.dart';
import 'package:KABA/src/ui/screens/home/me/address/MyAddressesPage.dart';
import 'package:KABA/src/ui/screens/home/me/customer/care/CustomerCareChatPage.dart';
import 'package:KABA/src/ui/screens/home/me/money/TopUpPage.dart';
import 'package:KABA/src/ui/screens/home/me/money/TransactionHistoryPage.dart';
import 'package:KABA/src/ui/screens/home/me/personnal/Personal2Page.dart';
import 'package:KABA/src/ui/screens/home/me/settings/SettingsPage.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/AddVouchersPage.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/KabaScanPage.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/MyVouchersPage.dart';
import 'package:KABA/src/ui/screens/home/orders/LastOrdersPage.dart';
import 'package:KABA/src/ui/screens/splash/SplashPage.dart';
import 'package:KABA/src/utils/_static_data/FlareData.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/Vectors.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../StateContainer.dart';
import 'feeds/FeedsPage.dart';
import 'money/TransferMoneyRequestPage.dart';


class MeAccountPage extends StatefulWidget {

  CustomerModel customerData;

  CustomerModel customer;

  MeAccountPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MeAccountPageState createState() => _MeAccountPageState();

}

class _MeAccountPageState extends State<MeAccountPage> with TickerProviderStateMixin{

  ScrollController _scrollController = ScrollController();

  StateContainerState container;

  static List<String> popupMenus;

  @override
  void initState() {
    super.initState();
    popupMenus = ["Add Voucher", "Scan QR","Settings","Logout"];
    CustomerUtils.getCustomer().then((customer) async {
      widget.customer = customer;
      popupMenus = ["${AppLocalizations.of(context).translate('add_voucher')}",
        "${AppLocalizations.of(context).translate('scan')}",
        "${AppLocalizations.of(context).translate('settings')}",
        "${AppLocalizations.of(context).translate('logout')}",];
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      popupMenus = ["${AppLocalizations.of(context).translate('add_voucher')}",
        "${AppLocalizations.of(context).translate('scan')}",
        "${AppLocalizations.of(context).translate('settings')}",
        "${AppLocalizations.of(context).translate('logout')}",];
    });
  }

  /*static getCustomer () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonCustomer = prefs.getString("_customer");
    String token = prefs.getString("_token");
    CustomerModel cm = CustomerModel.fromJson(json.decode(jsonCustomer));
    cm.token = token;
    return cm;
  }*/

  void _jumpToAddVoucherPage() {
    Navigator.of(context).push(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
            AddVouchersPage(presenter: AddVoucherPresenter(), customer: widget.customer),
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

  void menuChoiceAction(String value) {
    /* jump to the other activity */
    switch(popupMenus.indexOf(value)) {
      case 0:
      // scan
        _jumpToAddVoucherPage();
        break;
      case 1:
      // scan
        _jumpToScanPage();
        break;
      case 2:
        _jumpToPage(context, SettingsPage());
        break;
      case 3:
      /* logout */
        CustomerUtils.clearCustomerInformations().whenComplete((){

          StateContainer.of(context).updateBalance(balance: 0);
          StateContainer.of(context).updateKabaPoints(kabaPoints: "");
          StateContainer.of(context).updateUnreadMessage(hasUnreadMessage: false);
          StateContainer.of(context).updateTabPosition(tabPosition: 0);

          Navigator.pushNamedAndRemoveUntil(context, SplashPage.routeName, (r) => false);
        });
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
    /*  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );*/

    Navigator.of(context).push(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
        page,
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

  Widget _buildMyPage(data) {

    widget.customerData = data;

    double expandedHeight = 9*MediaQuery.of(context).size.width/16 + 20;
    var flexibleSpaceWidget = new SliverAppBar(
      actions: <Widget>[
        InkWell(onTap: ()=>_jumpToPage(context, CustomerCareChatPage(presenter: CustomerCareChatPresenter())),
          child: Container(width: 60,height:60,
            child: FlareActor(
                FlareData.new_message,
                alignment: Alignment.center,
                animation: "normal",
                fit: BoxFit.contain,
                isPaused : StateContainer.of(context).hasUnreadMessage != true
            ),
          ),
        ),
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
      leading: IconButton(icon: SizedBox(
          height: 25,
          width: 25,
          child: SvgPicture.asset(
            VectorsData.kaba_icon_svg,
            color: Colors.white,
          )), onPressed: (){_jumpToInfoPage();}),
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
            Column(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                        child: Container(
                            height:100, width: 100,
                            decoration: BoxDecoration(
                                border: new Border.all(color: Colors.white, width: 2),
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(Utils.inflateLink(widget.customerData.profile_picture))
                                )
                            )
                        ), onTap: ()=>
                        _seeProfilePicture()
//                    _jumpToPage(context, Personal2Page(customer: widget.customerData, presenter: PersonnalPagePresenter())),
                    ),
                    Container(
                        padding: EdgeInsets.only(right:20),
//                    decoration: BoxDecoration(border: Border),
                        child:Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(widget.customerData.nickname, style:TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.left,),
                              SizedBox(height:10),
                              Text( Utils.isPhoneNumber_TGO(widget.customerData.username)? "XXXX${widget.customerData.username.substring(4)}" : "${widget.customerData.username.substring(0,4)}****${widget.customerData.username.substring(widget.customerData.username.lastIndexOf("@")-1)}", style:TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.right,),
                              SizedBox(height:10),
                            ])
                    )],
                ),
                SizedBox(height: 20),
                Center(
                  child: Row(mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        child: Container(
                            decoration: BoxDecoration(
                              border: new Border.all(
                                  color: KColors.primaryColor,
                                  width: 2.0,
                                  style: BorderStyle.solid
                              ),
                            ),
                            padding: EdgeInsets.all(10), child: Row(children: [
                          Text("${AppLocalizations.of(context).translate('your_kaba_points')}"),
                          SizedBox(width:20),
                          Text("${StateContainer.of(context).kabaPoints == null ? "???" : StateContainer.of(context).kabaPoints}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
                        ])),
                        onTap:()=> _jumpToPage(context, TransactionHistoryPage(presenter: TransactionPresenter())),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            padding:EdgeInsets.all(10),
//            color: KColors.primaryYellowColor,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [KColors.primaryYellowColor, Colors.yellow]
              ),
            ),
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
//                                    IconButton (icon:Icon(Icons.monetization_on, color: KColors.primaryColor, size: 40)),
                                    SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: SvgPicture.asset(
                                          VectorsData.balance,
                                        )),
                                    SizedBox(height:10),
                                    Center(
                                      child: Center(
                                        child: Row(mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("${AppLocalizations.of(context).translate('currency')}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),
                                            SizedBox(width:5),
                                            Text("${StateContainer.of(context).balance == null ? "0" : StateContainer.of(context).balance}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                                          /*  SizedBox(width:10),
                                            StateContainer.of(context).isBalanceLoading ?
                                            SizedBox(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green), strokeWidth: 3), height: 12, width: 12) : Container(),
                                          */],
                                        ),
                                      ),
                                    )

                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(flex:1,
                            child: InkWell(
                              onTap: () => _jumpToTopUpPage(),
                              child: Container(
                                child: Column(
                                  children: <Widget>[
//                                    IconButton (icon:Icon(Icons.show_chart, color: KColors.primaryColor, size: 40)),
                                    SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: SvgPicture.asset(
                                          VectorsData.topup,
                                        )),
                                    SizedBox(height:5),
                                    Text("${AppLocalizations.of(context).translate('top_up')}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)
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
//                                    IconButton (icon:Icon(Icons.send, color: KColors.primaryColor, size: 40)),
                                    SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: SvgPicture.asset(
                                          VectorsData.transfer_money,
                                        )),
                                    SizedBox(height:5),
                                    Text("${AppLocalizations.of(context).translate('transfer')}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)
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
                            InkWell(onTap: () => _jumpToPage(context, CustomerCareChatPage(presenter: CustomerCareChatPresenter())),
                                child:Container(
                                    decoration: BoxDecoration(color:Colors.white, borderRadius: new BorderRadius.only(topRight:  const  Radius.circular(20.0), bottomRight: const  Radius.circular(20.0))),
                                    padding: EdgeInsets.only(left:10),
                                    child: Row(mainAxisSize: MainAxisSize.min,  mainAxisAlignment: MainAxisAlignment.start,children:<Widget>[
                                      Text("${AppLocalizations.of(context).translate('suggestions')}", style: TextStyle(color: KColors.primaryYellowColor)),
                                      IconButton(onPressed: null, icon: Icon(Icons.chevron_right, color: KColors.primaryColor))
                                    ])))
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
                                              IconButton (icon:Icon(Icons.person, color: KColors.primaryYellowColor),iconSize: 50, onPressed: () =>_jumpToPage(context, Personal2Page(customer: widget.customerData, presenter: PersonnalPagePresenter()))),
                                              SizedBox(height:10),
                                              Center(child: Text("${AppLocalizations.of(context).translate('profile')}".toUpperCase(), textAlign: TextAlign.center, style: TextStyle(color: KColors.primaryYellowColor, fontSize: 16),))
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
                                              IconButton (icon:Icon(Icons.location_on, color: KColors.primaryYellowColor, size: 60),iconSize: 50,  onPressed: () =>_jumpToPage(context, MyAddressesPage(presenter: AddressPresenter()))),
                                              SizedBox(height:10),
                                              Center(child: Text("${AppLocalizations.of(context).translate('addresses')}".toUpperCase(), textAlign: TextAlign.center, style: TextStyle(color: KColors.primaryYellowColor, fontSize: 16),))
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
                                              Center(child: Text("${AppLocalizations.of(context).translate('orders')}".toUpperCase(), textAlign: TextAlign.center, style: TextStyle(color: KColors.primaryYellowColor, fontSize: 15),))
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
                                              Center(child: Text("${AppLocalizations.of(context).translate('feeds')}".toUpperCase(), textAlign: TextAlign.center, style: TextStyle(color: KColors.primaryColor, fontSize: 16),))
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
                                              IconButton (icon:Icon(Icons.card_giftcard, color: KColors.primaryYellowColor, size: 60),iconSize: 50, onPressed: () =>_jumpToPage(context, MyVouchersPage(presenter: VoucherPresenter()))),
                                              SizedBox(height:10),
                                              Center(child: Text("${AppLocalizations.of(context).translate('coupon')}".toUpperCase(), textAlign: TextAlign.center, style: TextStyle(color: KColors.primaryYellowColor, fontSize: 16),))
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
                                              Center(child: Text("${AppLocalizations.of(context).translate('settings')}".toUpperCase(), textAlign: TextAlign.center, style: TextStyle(color: KColors.primaryYellowColor, fontSize: 16),))
                                            ],
                                          ),
                                        ),
                                      ),
//                                      TableCell(child:Container())
                                    ]
                                )
                              ]
                          )
                      )),
                ]..add(
                    Container(
                      margin: EdgeInsets.only(top: 15, bottom: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
//                                Icon(Icons.te, size: 20, color: KColors.primaryColor),
                          Text("${AppLocalizations.of(context).translate('powered_by_kaba_tech')}", style: TextStyle(fontSize: 12,color: Colors.grey),)
                        ],
                      ),
                    ))
            ),
          )),
    );
  }

  void _jumpToTransactionHistory() {
    _jumpToPage(context, TransactionHistoryPage(presenter: TransactionPresenter()));
  }

  _jumpToTopUpPage() async {

    Map results = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopUpPage(presenter: TopUpPresenter()),
      ),
    );

    if (results != null && results.containsKey('check_balance')) {

//      bool check_balance =  results['check_balance'];
      String link = results['link'];
      if (results['check_balance'] == true) {
        // show a dialog that tells the user to check his balance after he has topup up.
        link = Uri.encodeFull(link);
        _launchURL(link);
        _showDialog(message: "${AppLocalizations.of(context).translate('please_check_balance')}", svgIcon: VectorsData.account_balance);
      }
    }
  }

  Future<void> _jumpToScanPage() async {

    /* before we get here, we should ask some permission, the camera permission */
    if (!(await Permission.camera.request().isGranted)) {
      return;
    }

    Map results = await Navigator.of(context).push(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
            KabaScanPage(customer: widget.customer),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween = Tween(begin:begin, end:end);
              var curvedAnimation = CurvedAnimation(parent:animation, curve:curve);
              return SlideTransition(position: tween.animate(curvedAnimation), child: child);
            }
        ));

    if (results.containsKey("qrcode")) {
      String qrCode = results["qrcode"];
      /* continue transaction with this*/
      Navigator.of(context).push(
          PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
              AddVouchersPage(presenter: AddVoucherPresenter(), customer: widget.customer, qrCode: "$qrCode".toUpperCase()),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                var begin = Offset(1.0, 0.0);
                var end = Offset.zero;
                var curve = Curves.ease;
                var tween = Tween(begin:begin, end:end);
                var curvedAnimation = CurvedAnimation(parent:animation, curve:curve);
                return SlideTransition(position: tween.animate(curvedAnimation), child: child);
              }
          ));
    } else
      mDialog("${AppLocalizations.of(context).translate('qr_code_wrong')}");
  }


  void mDialog(String message) {
    _showDialog2(
      icon: Icon(Icons.info_outline, color: Colors.red),
      message: "${message}",
      isYesOrNo: false,
    );
  }

  void _showDialog2(
      {String svgIcons, Icon icon, var message, bool okBackToHome = false, bool isYesOrNo = false, Function actionIfYes}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: icon == null ? SvgPicture.asset(
                        svgIcons,
                      ) : icon),
                  SizedBox(height: 10),
                  Text(message, textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 13))
                ]
            ),
            actions:
            isYesOrNo ? <Widget>[
              OutlineButton(
                borderSide: BorderSide(width: 1.0, color: Colors.grey),
                child: new Text("${AppLocalizations.of(context).translate('refuse')}", style: TextStyle(color: Colors.grey)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              OutlineButton(
                borderSide: BorderSide(width: 1.0, color: KColors.primaryColor),
                child: new Text(
                    "${AppLocalizations.of(context).translate('accept')}", style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                  actionIfYes();
                },
              ),
            ] : <Widget>[
              OutlineButton(
                child: new Text(
                    "${AppLocalizations.of(context).translate('ok')}", style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ]
        );
      },
    );
  }


  Future<dynamic> _launchURL(String url) async {
    if (await canLaunch(url)) {
      return await launch(url);
    } else {
      try {
        throw 'Could not launch $url';
      } catch (_) {
        print(_);
      }
    }
    return -1;
  }

  Future<dynamic> _showDialog(
      {String svgIcon, var message,}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: SvgPicture.asset(
                          svgIcon
                      )),
                  SizedBox(height: 10),
                  Text(message, textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 13))
                ]
            ),
            actions: <Widget>[
              OutlineButton(
                borderSide: BorderSide(width: 1.0, color: Colors.grey),
                child: new Text("${AppLocalizations.of(context).translate('refuse')}", style: TextStyle(color: Colors.grey)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              OutlineButton(
                borderSide: BorderSide(width: 1.0, color: KColors.primaryColor),
                child: new Text(
                    "${AppLocalizations.of(context).translate('accept')}", style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                  _jumpToPage(context, TransactionHistoryPage(presenter: TransactionPresenter()));
                },
              ),
            ]
        );
      },
    );
  }

  _seeProfilePicture() {

    List<AdModel> slider = [AdModel(pic:"${widget?.customerData?.profile_picture}")];

    Navigator.of(context).push(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
            AdsPreviewPage(data: slider, position:0, presenter: AdsViewerPresenter()),
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


  void _jumpToInfoPage() {
    Navigator.of(context).push(
        PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                InfoPage(),
            transitionsBuilder: (context, animation, secondaryAnimation,
                child) {
              var begin = Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween = Tween(begin: begin, end: end);
              var curvedAnimation = CurvedAnimation(
                  parent: animation, curve: curve);
              return SlideTransition(
                  position: tween.animate(curvedAnimation), child: child);
            }
        ));
  }


}
