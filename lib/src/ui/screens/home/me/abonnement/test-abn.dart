import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/order_details_contract.dart';
import 'package:KABA/src/contracts/transaction_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/MoneyTransactionModel.dart';
import 'package:KABA/src/models/PointObjModel.dart';
import 'package:KABA/src/ui/customwidgets/abonnememts/SubscriptionCard.dart';

import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../resources/client_personal_api_provider.dart';

class Kaba_abonnement extends StatefulWidget {
  static var routeName = "/Kaba_abonnement";

  TransactionPresenter? presenter;

  CustomerModel? customer;

  var selectedPosition = 1;

  Kaba_abonnement({Key? key, this.title, this.presenter})
      : super(key: key);

  final String? title;

  @override
  _Kaba_abonnementState createState() => _Kaba_abonnementState();
}

class _Kaba_abonnementState extends State<Kaba_abonnement>
    with SingleTickerProviderStateMixin {
  late final TransactionView transactionView;

  _Kaba_abonnementState() {
    transactionView = TransactionView();
  }

  List<MoneyTransactionModel>? moneyData;
  PointObjModel? pointData = null;

  String? balance, kaba_points;

  TabController? _tabController;

  var TABS_LENGTH = 2;

  String currentMonth = "";

  Color filter_unactive_button_color = Color(0xFFF7F7F7),
      filter_active_button_color = KColors.primaryColor,
      filter_unactive_text_color = KColors.new_black,
      filter_active_text_color = Colors.white;

  var _searchChoices = null;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.presenter!.transactionView = TransactionView();
    _tabController = TabController(vsync: this, length: TABS_LENGTH);
    /*  _tabController!.addListener(() {
      _handleTabSelection();
    });*/

    CustomerUtils.getCustomer().then((customer) async{
      widget.customer = customer;

      // fetch transaction as the first page
      widget.presenter!.fetchMoneyTransaction(customer);
      // only fetch point when we press on the other button
      ClientPersonalApiProvider provider = new ClientPersonalApiProvider();
      balance = await provider.checkBalance(customer);
      pointData = await provider.fetchPointTransactionsHistory(customer);
      setState(() {
        isMoneyBalanceLoading = false;
        isMoneyLoading = false;
      });
    });
    _tabController!.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController!.indexIsChanging) {
      switch (_tabController!.index) {
        case 0:
          /* we know that we have to init / load data from specific page */
          break;
        case 1:
          if (pointData == null) {
            widget.presenter!.fetchPointTransaction(widget.customer!);
          }
          /* we know that we have to init / load data from specific page */
          break;
      }
    }
  }

  bool isMoneyLoading = true;
  bool isMoneyBalanceLoading = false;
  bool hasMoneySystemError = false;
  bool hasMoneyNetworkError = false;

  bool isPointTopLoading = false;
  bool isPointPageLoading =
      true; // to make sure when the tab is switched, the page is loading already
  bool hasPointSystemError = false;
  bool hasPointNetworkError = false;

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_searchChoices == null) {
      _searchChoices = [
        "${AppLocalizations.of(context)?.translate("balance")}",
        "${AppLocalizations.of(context)?.translate("points")}"
      ];
    }

    if (currentMonth == "") {
      try {
        xrint("current month ${DateTime.now().month}");
        xrint("mois_${DateTime.now().month}");

        currentMonth =
            "${AppLocalizations.of(context)?.translate("mois_${DateTime.now().month}")}";
      } catch (_) {
        xrint(_.toString());
        currentMonth = "This month";
      }
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(preferredSize: Size.fromHeight(80),
        child: AppBar(
          toolbarHeight: StateContainer.ANDROID_APP_SIZE,
          backgroundColor: KColors.primaryColor,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () {
                Navigator.pop(context);
              }),
          centerTitle: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // align to left
             mainAxisAlignment: MainAxisAlignment.center,  // center vertically
            children: [
              SizedBox(height: 25),
              Text(
                  Utils.capitalize(
                      "${AppLocalizations.of(context)?.translate('T_suscription')}"),
                  style: TextStyle(color: Colors.white, fontSize: 15)),
                      Text(
                "Choissiez la formule qui vous convient",
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
            ],
          ),
        ),
        ), 
       body: Container(
    width: double.infinity,
    height: double.infinity,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/images/background/Patternfond.png"), // your image
        fit: BoxFit.cover, // makes it cover full width + height
      ),
    ),
    child: SingleChildScrollView(
      child: Column(
        children: [
        Row(
  children: [
   Padding(
  padding: const EdgeInsets.only(left: 55 , top: 35 , right: 25 ), // top spacing
  child: Center(
    child: RichText(
      textAlign: TextAlign.center, // center the text
      text: TextSpan(
        children: [
          TextSpan(
            text: "Profitez des ", // line break before "Gratuite"
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
           TextSpan(
            text: "livraisons \n", // line break before "Gratuite"
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: KColors.primaryColor,
            ),
          ),
          TextSpan(
            text: "GRATUITES", // "Gratuite" in red
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: KColors.primaryColor, // red color
            ),
          ),
        ],
      ),
    ),
  ),
)

  ],
),
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // left & right padding
  child: Card(
    color: Colors.white,
    elevation: 0.75, // shadow depth
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(1.5), // rounded corners
    ),
    child: Column(
      children: [
    Padding(
  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 30.0, bottom: 10.0), // padding around the row),
  child: Row(
    children: [
      // Icon from assets
     
      Image.asset(
        "assets/images/png/abonnement-icons/Package.png",
        width: 30,
        height: 30,
      ),
      SizedBox(width: 12), // spacing between icon & text

      // First text
      Text(
        "Mon abonnement",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),

      Spacer(), // pushes "Inactif" to the far right

      // Status text with background, padding, and rounded edges
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.grey[700], // background color
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "Inactif",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ],
  ),
  

),
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // internal padding
    decoration: BoxDecoration(
      color: Color(0xFFF3F3F5), // grey background
      borderRadius: BorderRadius.circular(8), // small border radius
    ),
    child: Row(
      children: [
       Container(
  width: 40, // small square container
  height: 40,
  decoration: BoxDecoration(
    color: Color(0xFFFFC8D4), // background color
    borderRadius: BorderRadius.circular(8), // rounded corners
  ),
  child: Padding(
    padding: const EdgeInsets.all(8.0), // inner padding for the image
    child: Image.asset(
      "assets/images/png/abonnement-icons/Package.png", // your image
      fit: BoxFit.contain,
    ),
  ),
 ), SizedBox(width: 15,) , Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Livraisons",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4), // spacing between texts
          Text(
            "0/0",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),  
      ],
    ),
  ),
),
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // internal padding
    decoration: BoxDecoration(
      color: Color(0xFFF3F3F5), // grey background
      borderRadius: BorderRadius.circular(8), // small border radius
    ),
    child: Row(
      children: [
       Container(
  width: 40, // small square container
  height: 40,
  decoration: BoxDecoration(
    color: Color(0xFFFFC8D4), // background color
    borderRadius: BorderRadius.circular(8), // rounded corners
  ),
  child: Padding(
    padding: const EdgeInsets.all(8.0), // inner padding for the image
    child:  SvgPicture.asset(
      "assets/images/png/abonnement-icons/Clock.svg", // your SVG file
      fit: BoxFit.contain,
      color: Color(0xFFCD1F45), // optional: change stroke color
    ),
  ),
 ), SizedBox(width: 15,) , Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Expire dans",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4), // spacing between texts
          Text(
            "********",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),  
      ],
    ),
  ),
),
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // internal padding
    decoration: BoxDecoration(
      color: Color(0xFFF3F3F5), // grey background
      borderRadius: BorderRadius.circular(8), // small border radius
    ),
    child: Row(
      children: [
       Container(
  width: 40, // small square container
  height: 40,
  decoration: BoxDecoration(
    color: Color(0xFFFFC8D4), // background color
    borderRadius: BorderRadius.circular(8), // rounded corners
  ),
  child: Padding(
    padding: const EdgeInsets.all(8.0), // inner padding for the image
    child: Icon(  Icons.code, color: Color(0xFFCD1F45)),
 ), ),
 SizedBox(width: 15) ,
  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Code",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4), // spacing between texts
          Text(
            "*********",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),  
      ],
    ),
  ),
),

      Padding(padding: EdgeInsets.only(top: 20, bottom: 20 , left: 25.0, right: 16.0),
        child: Text(
          "Choisissez une formule ci-dessous pour commencer !",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ),
      ],
    ),
  ),
),  Row(
          
          children: [
            SizedBox(width: 10),
            SubscriptionCard(
              title: "BASIC",
              price: "2.500",
              borderColor: Color(0xFF155DFC),
              accentColor: Color(0xFF155DFC),
              features: [
                "10 livraisons",
                "Rayon de 3Kms",
                "Min. 1.000 F",
                "Valide 25 jours",
                "Partageable",
              ],
            ),
            SubscriptionCard(
              title: "BASIC +",
              price: "5.000",
              borderColor: Colors.green,
              accentColor: Colors.green,
              features: [
                "20 livraisons",
                "Rayon de 6Kms",
                "Min. 1.000 F",
                "Valide 25 jours",
                "Partageable",
              ],
            ),
          
            
          ],
        ),Row(
          
          children: [
             SizedBox(width: 10),
            SubscriptionCard(
              title: "BASIC",
              price: "2.500",
              borderColor: Color(0xFFD99507),
              accentColor: Color(0xFFD99507),
              features: [
                "10 livraisons",
                "Rayon de 3Kms",
                "Min. 1.000 F",
                "Valide 25 jours",
                "Partageable",
              ],
            ),
            SubscriptionCard(
              title: "BASIC +",
              price: "5.000",
              borderColor: Color(0xFFC57AFB),
              accentColor: Color(0xFFC57AFB),
              features: [
                "20 livraisons",
                "Rayon de 6Kms",
                "Min. 1.000 F",
                "Valide 25 jours",
                "Partageable",
              ],
            ),
          
            
          ],
        ),SubscriptionCard(
              title: "VIC",
              width: 300,
              price: "100000",
              borderColor: Color(0xFFCD1F45),
              accentColor: Color(0xFFCD1F45),
              features: [
                "20 livraisons",
                "Rayon de 6Kms",
                "Min. 1.000 F",
                "Valide 25 jours",
                "Partageable",
              ],
            ),
          
        ],
      ),
    ),
  )
    
    
    
    
    
    );
  }



/* @override
  void updateKabaPoints(String kabaPoints) {
    setState(() {
      StateContainer.of(context).updateKabaPoints(kabaPoints: kabaPoints);
    });
  }*/

}
