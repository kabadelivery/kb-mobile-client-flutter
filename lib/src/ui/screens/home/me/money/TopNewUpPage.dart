import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/topup_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/microservices/expedition/data/expedition/remote_data_source.dart';
import 'package:KABA/src/microservices/expedition/domain/expedition/repo.dart';
import 'package:KABA/src/microservices/expedition/usecases/payExpediton.dart';
import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../../../microservices/kaba_chine/data/order/data_remote_source.dart';
import '../../../../../microservices/kaba_chine/domain/order/repository.dart';
import '../../../../../microservices/kaba_chine/presentation/widgets/package_form_info.dart';
import '../../../../../microservices/kaba_chine/usecases/order/payForDelivery.dart';
import '../../../../../resources/client_personal_api_provider.dart';
import '../../../../../resources/kkiapay_provider.dart';
import '../../../../../utils/Enums/type_of_transaction.dart';
import '../../../../../utils/functions/popups.dart';
import '../../../../../utils/functions/topups.dart';
import '../../../webview/paymentWebView.dart';

class TopNewUpPage extends StatefulWidget {
  static var routeName = "/TopNewUpPage";

  TopUpPresenter? presenter;
  TransactionType? transactionType;
  Map<String,dynamic>? additionnal_infos;


  var total = 0;

  var fees = 0;
  String _selectedCountryCode = "+228";
  double? fees_tmoney = 4.0;

  double? fees_flooz = 4.0;

  double? fees_bankcard = 5.0;
  double? fees_momo = 4.0;

  int? selectedPosition = 1;
  int? amount_to_send=0;

  TopNewUpPage({Key? key, this.amount_to_send, this.presenter,this.transactionType,this.additionnal_infos}) : super(key: key);

  CustomerModel? customer;

  @override
  _TopNewUpPageState createState() => _TopNewUpPageState();
}

class _TopNewUpPageState extends State<TopNewUpPage> implements TopUpView {
  TextEditingController? _phoneNumberFieldController;
  TextEditingController? _amountFieldController;
  TextEditingController? _totalAmountFieldController;
  String operator = "---";

  bool isOperatorOk = false;

  var isLaunching = false;

  double euroRatio = 657.60;
  bool textActionSemoaAvailable=false;
  String textActionSemoa="";
  String feesDescription = "";
  bool isGetFeesLoading = false;
  FocusNode? _totalFocusNode, _amountFocusNode;

  // int selectedPaymentMode = 0; // 0 tmoney 1 bank card 2 flooz

  TextEditingController? _feesFieldController;

  int BANK_MIN_AMOUNT = 10000;

  Color filter_unactive_button_color = Color(0xFFF7F7F7),
      filter_active_button_color = KColors.primaryColor,
      filter_unactive_text_color = KColors.new_black,
      filter_active_text_color = Colors.white;

  var _searchChoices = null;
  String _selectedCountryCode = '+228';
  var dropdownValue = "Tmoney";
  List<Map<String, dynamic>> momoPaymentModes = [
    {"name": "Tmoney", "id": "t_money","logo":"assets/images/png/tmoney_logo.png"},
    {"name": "Flooz", "id": "flooz", "logo":"assets/images/png/moov_africa_logo.png"},
  ];
  List<Map<String, dynamic>> bankPaymentModes = [
    {"name":"Visa","id":"visa_card","logo":"assets/images/png/visa_logo.png"},
    {"name":"MasterCard","id":"master_card","logo":"assets/images/png/master_card_logo.png"},
    {"name":"American Express","id":"american_express","logo":"assets/images/png/american_express.png"},
    {"name":"Solimi","id":"solimi","logo":"assets/images/png/solimi_logo.png"},
  ];

  String momo_picked_id="t_money";
  String bank_picked_id="visa_card";
  @override
  void initState() {
    super.initState();

    widget.presenter!.topUpView = this;
    _phoneNumberFieldController = new TextEditingController();
    _totalAmountFieldController = new TextEditingController(text: "0");
    _amountFieldController = new TextEditingController();
    _feesFieldController = new TextEditingController();

    _phoneNumberFieldController!.addListener(_checkOperator);
    _amountFieldController!.addListener(_updateFromInitialAmountTotal);
    _totalAmountFieldController!.addListener(_updateFromTotal);
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      widget.presenter!.fetchFees(widget.customer!);
//      widget.presenter!.fetchTopUpConfiguration(widget.customer);
    });

    _totalFocusNode = new FocusNode();
    _amountFocusNode = new FocusNode();
    if(widget.transactionType==TransactionType.topup){
      momoPaymentModes.add({"name":"Orange money","id":"orange_money","logo":"assets/images/png/orange_money_logo.png"});
      momoPaymentModes.add({"name":"MTN","id":"mtn","logo":"assets/images/jpg/mtn_logo.jpg"});
      momoPaymentModes.add({"name":"Wave","id":"wave","logo":"assets/images/png/wave_logo.png"});
    }
    if(widget.amount_to_send!=null && widget.amount_to_send!=0){
      _amountFieldController = new TextEditingController(text: widget.amount_to_send.toString());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    feesDescription =
        "${AppLocalizations.of(context)!.translate('why_top_up_fees')}";
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("additionnal_infos ${widget.additionnal_infos}");
    if (_searchChoices == null) {
      _searchChoices = [
        "${AppLocalizations.of(context)?.translate("mobile_money_top_up")}",
        "${AppLocalizations.of(context)?.translate("bank_card_top_up")}"
      ];
    }
    if(widget.transactionType== TransactionType.expedition){
      _totalAmountFieldController!.text =
      "${_getRealTotalAmountFromInitial()}";
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: StateContainer.ANDROID_APP_SIZE,
        backgroundColor: KColors.primaryColor,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 20),
            onPressed: () {
              Navigator.pop(context);
            }),
//        actions: <Widget>[ IconButton(tooltip: "Confirm", icon: Icon(Icons.check, color:KColors.primaryColor), onPressed: (){_confirmContent();})],
          centerTitle: true,
          title: Row(mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
               widget.transactionType==null || widget.transactionType == TransactionType.topup? Utils.capitalize(
                    "${AppLocalizations.of(context)!.translate('top_up')}"):
                     Utils.capitalize("${AppLocalizations.of(context)!.translate('proceed_to_transaction')}"),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),
      body: Container(height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(children: <Widget>[
                SizedBox(height: 15),
                /* define mobile money and visa-card */
                widget.transactionType==null || widget.transactionType == TransactionType.topup?
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AnimatedContainer(
                          decoration: BoxDecoration(
                            color: filter_unactive_button_color,
                            borderRadius:
                                BorderRadius.all(const Radius.circular(5.0)),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                      onTap: () => _onSwitch(1),
                                      child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: Center(
                                            child: Text(Utils.capitalize(
                                                    // "${AppLocalizations.of(context)!.translate('search_restaurant')}"),
                                                    _searchChoices[0]),
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: widget
                                                                .selectedPosition ==
                                                            1
                                                        ? this
                                                            .filter_active_text_color
                                                        : this
                                                            .filter_unactive_text_color)),
                                          ),
                                          decoration: BoxDecoration(
                                              color: widget.selectedPosition == 1
                                                  ? this.filter_active_button_color
                                                  : this
                                                      .filter_unactive_button_color,
                                              borderRadius:
                                                  new BorderRadius.circular(5.0)))),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: InkWell(
                                    onTap:(){
                                      showModernPopup(
                                          title: AppLocalizations.of(context)!.translate("t_unavailable"),
                                          context: context,
                                          text:
                                          "${AppLocalizations.of(context)!.translate('top_up_by_card_unavailable')}",
                                          icon: Icon(Icons.credit_card_rounded)
                                      );
                                    },
                                     // onTap: () => _onSwitch(2),
                                      child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: Center(
                                            child: Text(
                                                Utils.capitalize(_searchChoices[1]),
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: widget
                                                                .selectedPosition ==
                                                            1
                                                        ? this
                                                            .filter_unactive_text_color
                                                        : this
                                                            .filter_active_text_color)),
                                          ),
                                          decoration: BoxDecoration(
                                              color: widget.selectedPosition == 1
                                                  ? this
                                                      .filter_unactive_button_color
                                                  : this.filter_active_button_color,
                                              borderRadius:
                                                  new BorderRadius.circular(5.0)))),
                                ),
                              ]),
                          duration: Duration(milliseconds: 3000),
                        ),
                      ),
                    ],
                  ),
                ): Container(),
                SizedBox(height: 5),
                Container(
                  width:MediaQuery.of(context).size.width*0.9,
                  height: 40,
                  decoration: BoxDecoration(
                     border: Border.all(
                        color: Colors.grey.withOpacity(0.3), width: 1),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     Text("${AppLocalizations.of(context)!.translate('choose_your_payment_method')}",style: TextStyle(color: Colors.black87, fontSize: 12),),
                    ],
                  ),
                ),
                widget.selectedPosition == 1
                    ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                             width: MediaQuery.of(context).size.width*0.95,
                              height: (momoPaymentModes.length / 4).ceil() * 65.0,
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: momoPaymentModes.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 1.5,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 5,
                                ),
                                itemBuilder: (context, index) {
                                  final isSelected = momo_picked_id == momoPaymentModes[index]['id'];

                                  return GestureDetector(

                                    onTap: () {
                                     // if(momoPaymentModes[index]['id'] == "orange_money"){
                                      //                                         mDialog("${AppLocalizations.of(context)!.translate('orange_payment_not_available')}");
                                      //                                         return;
                                      //                                       }
                                      //                                       if(momoPaymentModes[index]['id'] == "mtn"){
                                      //                                         mDialog("${AppLocalizations.of(context)!.translate('mtn_payment_not_available')}");
                                      //                                         return;
                                      //                                       }
                                      //                                       if(momoPaymentModes[index]['id'] == "wave"){
                                      //                                         mDialog("${AppLocalizations.of(context)!.translate('wave_payment_not_available')}");
                                      //                                         return;
                                      //                                       }
                                      setState(() {
                                        momo_picked_id = momoPaymentModes[index]['id'];
                                        dropdownValue = momoPaymentModes[index]['name'];
                                      });
                                    },
                                    child: Container(

                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: AssetImage(momoPaymentModes[index]['logo']),
                                          fit: BoxFit.scaleDown, // Adjust to BoxFit.contain if needed
                                        ),
                                        color: KColors.new_gray,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:Colors.transparent,
                                          border: Border.all(
                                            color: isSelected
                                                ? KColors.primaryColor
                                                :KColors.primaryColor,
                                            width: isSelected?4:1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )


                          ),
                        ),
                        /* Container(
                            decoration: BoxDecoration(
                                color: KColors.new_gray,
                                borderRadius: BorderRadius.circular(5)),
                            margin:
                                EdgeInsets.only( right: 10, left: 10),
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                            child:
                                // usage example
                                DropdownButton<String>(
                              isExpanded: true,
                              value: dropdownValue,
                              underline: Container(),
                              icon: const Icon(FontAwesomeIcons.chevronDown,
                                  size: 15, color: KColors.primaryColor),
                              elevation: 16,
                              style: const TextStyle(
                                  color: KColors.primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                              hint: Text(
                                  "${AppLocalizations.of(context)!.translate('choose_mobile_money_service')}",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14)),
                              onChanged: (newValue) {
                                setState(() {
                                  dropdownValue = newValue!;
                                });
                              },
                              items: <String>[
                                'Tmoney',
                                'Flooz',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            )),*/
                      ],
                    )
                    :   Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      width: MediaQuery.of(context).size.width*0.9,
                      height: (bankPaymentModes.length / 4).ceil() * 80.0,
                      alignment: Alignment.center,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: bankPaymentModes.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                        ),
                        itemBuilder: (context, index) {
                          final isSelected = bank_picked_id == bankPaymentModes[index]['id'];

                          return GestureDetector(
                            onTap: () {
                              if(bankPaymentModes[index]['id'] == "solimi"){
                                mDialog("${AppLocalizations.of(context)!.translate('solimi_payment_not_available')}");
                                return;
                              }
                              setState(() {
                                bank_picked_id = bankPaymentModes[index]['id'];
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage(bankPaymentModes[index]['logo']),
                                  fit: BoxFit.contain,
                                ),
                                color: KColors.new_gray,
                              ),
                              child:  Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ?KColors.primaryColor
                                        : KColors.primaryColor,
                                    width: isSelected?4:1,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )


                  ),
                ),
                 Column(children: [

                            /* phone number just in case we are working with moov*/
                            Container(
                              color: Colors.white,
                              padding: EdgeInsets.all(20),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FormTitle(
                                      context: context,
                                      title:  "${AppLocalizations.of(context)!.translate('topup_phone_number')}",
                                      isRequired: true,
                                    ),
                                    SizedBox(height: 5),
                                    FormTextFieldContainerDecoration(
                                      context: context,
                                      child: Row(
                                        children: [
                                          SizedBox(width: 10),
                                          Icon(Icons.phone_outlined, color: Colors.black54),
                                          SizedBox(width: 8),

                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              border: Border(
                                                right: BorderSide(color: Colors.black12, width: 1),
                                              ),
                                            ),
                                            child: CountryCodePicker(
                                              onChanged: (country) {
                                                setState(() {
                                                  _selectedCountryCode = country.dialCode ?? '+228';
                                                  debugPrint(_selectedCountryCode);
                                                });
                                              },
                                              initialSelection: 'TG',
                                              favorite: ['+228', 'TG'],
                                              showCountryOnly: false,
                                              showOnlyCountryWhenClosed: false,
                                              alignLeft: false,
                                              showDropDownButton: true,
                                              padding: EdgeInsets.zero,
                                              textStyle: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),

                                          SizedBox(width: 8),

                                          Expanded(
                                            child: TextField(
                                              controller: _phoneNumberFieldController,
                                              textAlign: TextAlign.right,
                                              style: TextStyle(fontSize: 20),
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintMaxLines: 5,
                                                hintStyle: TextStyle(fontSize: 13),
                                              ),
                                              keyboardType: TextInputType.phone,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ]),
                            ),
                          ]),

                Column(children: [
                  /* amount you wanna get paid */
                widget.transactionType == TransactionType.expedition?Container():
                Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FormTitle(
                            context: context,
                            title:  "${AppLocalizations.of(context)!.translate('amount_to_top_up')}",
                            isRequired: true,
                          ),
                          SizedBox(height: 5),
                    FormTextFieldContainerDecoration(
                        context: context,child:  Row(
                            children: [
                              SizedBox(width: 10),
                              Icon(FontAwesomeIcons.moneyBill1, color: Colors.black54),
                              Expanded(
                                child: TextField(
                                    controller: _amountFieldController,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(fontSize: 20),
                                    decoration: InputDecoration(
                                        fillColor: Colors.yellow,
                                        border: InputBorder.none,
                                        hintMaxLines: 5,
                                        hintStyle: TextStyle(fontSize: 13)),
                                    keyboardType: TextInputType.number),
                              ),
                              Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 20),
                                  child: Text(
                                      "${AppLocalizations.of(context)!.translate('currency')}",
                                      style:
                                          TextStyle(color:Colors.black54)),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(8),
                                          bottomRight: Radius.circular(8)),
                                      color: Colors.transparent))
                            ],
                          ))
                        ]),
                  ),
                ]),
                SizedBox(height: 10),
                widget.selectedPosition!=1 && textActionSemoaAvailable==true?
                Container(
                  width:MediaQuery.of(context).size.width*0.9,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: KColors.primaryColor.withOpacity(0.3), width: 1),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: Text("$textActionSemoa",style: TextStyle(color: KColors.primaryColor, fontSize: 12),)),

                    ],
                  ),
                ):Container(),
                SizedBox(height: 10),
                isGetFeesLoading
                    ? SizedBox(
                        child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(KColors.mGreen)),
                        height: 15,
                        width: 15)
                    : Container(),
                SizedBox(height: 5),

                /* please be patient ... */

                Column(children: [
                  SizedBox(height: 10),
                  /* amount you wanna get paid */
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: Colors.grey.withOpacity(0.3), width: 1),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      children: [
                        Container(
                          width:MediaQuery.of(context).size.width,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(0xa6f1f1f1),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 10),
                              Icon(FontAwesomeIcons.moneyBillTrendUp, color: Colors.black54),
                              SizedBox(width: 10),
                              Text("${AppLocalizations.of(context)!.translate('fee_can_be_changed')}",style: TextStyle(color: Colors.black87, fontSize: 12),),

                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: RichText(
                                    text: TextSpan(
                                        text:
                                            "${AppLocalizations.of(context)!.translate('fees')} ",
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 14),
                                        children: [
                                          isGetFeesLoading
                                              ? TextSpan(
                                                  text: "---",
                                                  style: TextStyle(
                                                      color: KColors.mGreen,
                                                      fontWeight: FontWeight.bold))
                                              : TextSpan(
                                                  text: "(${_getFees()}%)",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: KColors.primaryColor,
                                                      fontWeight: FontWeight.normal))
                                        ]),
                                  )),
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                    padding: EdgeInsets.only(left: 5, right: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "${widget?.fees}",
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              fontSize: 14, color: KColors.new_black),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                            "${AppLocalizations.of(context)!.translate('currency')}",
                                            style: TextStyle(
                                                color: KColors.primaryColor,
                                                fontSize: 14))
                                      ],
                                    ),
                                  ))
                            ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Text(
                                      "${AppLocalizations.of(context)!.translate('total_amount')}",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14))),
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                    padding: EdgeInsets.only(left: 5, right: 5),
                                    child: TextField(
                                        controller: _totalAmountFieldController,
                                        enabled: false,
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: KColors.primaryColor),
                                        decoration: InputDecoration(
                                            fillColor: Colors.yellow,
                                            border: InputBorder.none,
                                            hintMaxLines: 5,
                                            hintStyle: TextStyle(fontSize: 13)),
                                        keyboardType: TextInputType.number),
                                  ))
                            ]),
                      ],
                    ),
                  ),
                ]),

               false ? Center(
                    child: Text(
                  "${AppLocalizations.of(context)!.translate('total_amount')}: ${_getTotalAmountEuro()} €",
                  style: TextStyle(color: KColors.mBlue, fontSize: 14),
                )) : Container(),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () async{
                    if(widget.transactionType==null || widget.transactionType == TransactionType.topup) {
                      if(widget.selectedPosition==1)
                        launchNewMomoTopUp();
                      else
                        launchNewCardTopUp();
                    }
                    else if(widget.transactionType == TransactionType.kaba_chine)
                      kabaChinePay();
                    else if(widget.transactionType == TransactionType.expedition)
                      ExpeditionPay();
                  },
                  child: Container(width: MediaQuery.of(context).size.width * 0.9,
                   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                        color: KColors.primaryColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                      (widget.transactionType== TransactionType.expedition)?"${AppLocalizations.of(context)!.translate('pay')}".toUpperCase():
                      "${AppLocalizations.of(context)!.translate('top_up')}"
                                  .toUpperCase(),
                              style:
                              TextStyle(fontSize: 14, color: Colors.white)),
                          SizedBox(width: 10),

                          isLaunching
                              ? Row(
                            children: <Widget>[
                              SizedBox(width: 10),
                              SizedBox(
                                  child: CircularProgressIndicator(
                                      valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                          Colors.white)),
                                  height: 15,
                                  width: 15),
                            ],
                          )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20)
              ]),
            ),

          ],
        ),
      ),
    );
  }

  @override
  void networkError() {
    showLoading(false);
  }

  @override
  void showLoading(bool isLoading) {
    setState(() {
      this.isLaunching = isLoading;
    });
  }

  @override
  void systemError() {
    showLoading(false);
  }

  @override
  void topUpToWeb(String link) {
    Navigator.of(context).pop({'check_balance': true, 'link': link});
  }

  @override
  void topUpToPush() {
    Navigator.of(context).pop({'check_balance': true});
  }

  bool _checkOperator() {
    String number = "${_phoneNumberFieldController!.text}";

    String mOperator = "---";
    isOperatorOk = true;

    if (Utils.isPhoneNumber_TGO(number)) {
      if (Utils.isPhoneNumber_Moov(number)) {
        mOperator = "MOOV";
        setState(() {
          dropdownValue = "Flooz";
        });
      } else if (Utils.isPhoneNumber_Tgcel(number)) {
        mOperator = "TOGOCEL";
        setState(() {
          dropdownValue = "Tmoney";
        });
      } else {
        mOperator = "---";
      }
      setState(() {
        this.operator = mOperator;
        isOperatorOk = true;
      });
    } else {
      setState(() {
        this.operator = mOperator;
        isOperatorOk = false;
      });
    }

    return isOperatorOk;
  }

  void iLaunchTransaction() {
    if (isGetFeesLoading) {
      mToast(
          "${AppLocalizations.of(context)!.translate('please_wait_fees_percentage')}");
      return;
    }

    if (widget.selectedPosition == 1 &&
        !Utils.isPhoneNumber_TGO(_phoneNumberFieldController!.text)) {
      mToast("${AppLocalizations.of(context)!.translate('phone_number_wrong')}");
    } else {
      if (widget.customer != null) {
        if (widget.selectedPosition == 1) {
          widget.presenter!.launchTopUp(
              widget.customer!,
              "${_phoneNumberFieldController!.text}",
              "${_amountFieldController!.text}",
              _getFees(),
              1
              );
        } else if (widget.selectedPosition == 2) {
          String amount = "${_amountFieldController!.text}";
          int _amount = int.parse(amount);
          if (_amount >= BANK_MIN_AMOUNT)
            widget.presenter!.launchPayDunya(
                widget.customer!, "${_amountFieldController!.text}", _getFees());
          else
            mDialog(
                "${AppLocalizations.of(context)!.translate(
                    'bank_card_top_up_min')} ${BANK_MIN_AMOUNT}");
        } else {
          mToast("${AppLocalizations.of(context)!.translate('system_error')}");
        }
      } else
        mToast("${AppLocalizations.of(context)!.translate('system_error')}");
    }
  }

  void mToast(String message) {
    Fluttertoast.showToast(msg: message,toastLength: Toast.LENGTH_LONG);
  }

  void mDialog(String message) {
    _showDialog(
      icon: Icon(Icons.info_outline, color: Colors.red),
      message: "${message}",
      isYesOrNo: false,
    );
  }

  void _showDialog(
      {String? svgIcons,
      Icon? icon,
      var message,
      bool okBackToHome = false,
      bool isYesOrNo = false,
      Function? actionIfYes}) {
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
                          svgIcons!,
                        )
                      : icon),
              SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: KColors.new_black, fontSize: 13))
            ]),
            actions: isYesOrNo
                ? <Widget>[
                    OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(
                              BorderSide(color: Colors.grey, width: 1))),
                      child: new Text(
                          "${AppLocalizations.of(context)!.translate('refuse')}",
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
                          "${AppLocalizations.of(context)!.translate('accept')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        actionIfYes!();
                      },
                    ),
                  ]
                : <Widget>[
                    OutlinedButton(
                      child: new Text(
                          "${AppLocalizations.of(context)!.translate('ok')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ]);
      },
    );
  }

  void _updateFromTotal() {
    /* check which one has focus before updating */
    setState(() {
      if (!_amountFocusNode!.hasFocus!) {
        // update fees
        xrint("amount field doesnt have focus ");
        _amountFieldController!.removeListener(_updateFromInitialAmountTotal);
        _amountFieldController!.text = "${_getRealInitialAmountFromTotal()}";
        _amountFieldController!.addListener(_updateFromInitialAmountTotal);
        widget.fees = _getFeesFromTotal();
        _feesFieldController!.text = "${widget.fees}";
        // update amount
      } else {
        xrint("amount field has  focus ");
      }
    });
  }

  void _updateFromInitialAmountTotal() {
    /* check which one has focus before updating */
  if(widget.transactionType == TransactionType.expedition){
    widget.fees = _getFeesFromAmount();
    _feesFieldController!.text = "${widget.fees}";
    _totalAmountFieldController!.removeListener(_updateFromTotal);
    _totalAmountFieldController!.text =
    "${_getRealTotalAmountFromInitial()}";
    _totalAmountFieldController!.addListener(_updateFromTotal);
  }else{
    setState(() {
      if (!_totalFocusNode!.hasFocus!) {
        // update fees
        xrint("total field doesnt have  focus ");
        widget.fees = _getFeesFromAmount();
        _feesFieldController!.text = "${widget.fees}";
        _totalAmountFieldController!.removeListener(_updateFromTotal);
        _totalAmountFieldController!.text =
            "${_getRealTotalAmountFromInitial()}";
        _totalAmountFieldController!.addListener(_updateFromTotal);
        // update amount
      } else {
        xrint("total field has  focus ");
      }
    });
  }
  }

  _getFeesFromAmount() {
    String amount = _amountFieldController!.text;
    double amount_;
    if (amount == null || "" == amount.trim())
      amount_ = 0;
    else
      amount_ = double.parse(amount);

    return ((amount_.toDouble() * _getFees()) / 100).round();
  }

  _getFeesFromTotal() {
    String total = _totalAmountFieldController!.text;
    double? total_;
    if (total_ == null || "" == total.trim())
      total_ = 0;
    else {
      total_ = double.parse(total);
    }

    int fees = (total_.toInt() - _getRealInitialAmountFromTotal()).toInt();
    return fees;
  }

  _getRealInitialAmountFromTotal() {
    String _total = _totalAmountFieldController!.text;
    double total;
    if (_total == null || "" == _total.trim())
      total = 0;
    else
      total = double.parse(_total);

    // amount = total / (1+fees)
    return (100 * total / (100.toDouble() + _getFees().toDouble())).toInt();
  }

  _getRealTotalAmountFromInitial() {
    int fees = _getFeesFromAmount();
    String _amount = _amountFieldController!.text;
    int amount;
    if (_amount == null || "" == _amount.trim())
      amount = 0;
    else
      amount = int.parse(_amount);

    return amount + fees;
  }

  @override
  void updateFees(fees_tmoney, fees_flooz, fees_bankcard) {
    setState(() {
      widget.fees_tmoney = fees_tmoney;
      widget.fees_flooz = fees_flooz;
      widget.fees_bankcard = fees_bankcard;
    });
  }

/*
  @override
  void updateFees(int feesPercentage) {
    setState(() {
      widget.feesPercentage = feesPercentage;
    });
  }*/

  @override
  void showGetFeesLoading(bool isGetFeesLoading) {
    setState(() {
      this.isGetFeesLoading = isGetFeesLoading;
    });
  }

  double _getFees() {
    switch (widget.selectedPosition) {
      case 2:
        return widget.fees_bankcard!;
        break;
      case 1:
        if (dropdownValue == "Tmoney")
          return widget.fees_tmoney!;
        else if (dropdownValue == "Flooz") return widget.fees_flooz!;

    }
    return widget.fees_flooz!.toDouble();
  }

  _getTotalAmountEuro() {
    return double.parse(
        ((_getRealTotalAmountFromInitial() / euroRatio)).toStringAsFixed(2));
  }
  void kabaChinePay()async{
    setState(() {
      showLoading(true);

    });
    PayForDelivery payForDelivery = PayForDelivery(
        DeliveryRepositoryImpl(
            DeliveryRemoteDataSourceImpl(http.Client())));
           CustomerModel customer = await CustomerUtils.getCustomer();
            Map data=await payForDelivery.call(
                 customer,
                _phoneNumberFieldController!.text,
                _amountFieldController!.text,
                 widget.additionnal_infos!['delivery_id'].toString(),
                dropdownValue=="Flooz"?"FLOOZ":"TMONEY"
            );

    setState(() {
      if(data!=null){
        Navigator.of(context).pop({"success": data['success'],"code":data['code']});
      }else{
        Navigator.of(context).pop({"success": false});
      }
      showLoading(false);
    });
  }
  void ExpeditionPay()async{
    setState(() {
      showLoading(true);

    });
    PayExpedition payExpedition = PayExpedition(
        ExpeditionRepositoryImpl(
            ExpeditionRemoteDataSourceImpl()));
    CustomerModel customer = await CustomerUtils.getCustomer();
    Map data=await payExpedition.call(
        customer,
        _phoneNumberFieldController!.text,
        widget.amount_to_send.toString(),
        widget.additionnal_infos!['delivery_id'].toString(),
        dropdownValue=="Flooz"?"FLOOZ":"TMONEY"
    );

    setState(() {
      if(data!=null){
        Navigator.of(context).pop({"success": data['success'],"code":data['code']});
      }else{
        Navigator.of(context).pop({"success": false});
      }
      showLoading(false);
    });
  }
  void launchNewMomoTopUp()async{
    setState(() {
      showLoading(true);
    });
    ClientPersonalApiProvider provider = new ClientPersonalApiProvider();
    CustomerModel customer = await CustomerUtils.getCustomer();
    bool launch_other_payment = false;
    int transaction_motif_id = 1 ;
    if(momo_picked_id!="flooz" && momo_picked_id!="t_money"){
      launch_other_payment=true;
    }
    bool isMomoFromTogo   =await detectTogoMomoOperator(_phoneNumberFieldController!.text);
    if(!isMomoFromTogo){
      launch_other_payment=true;
    }
    if(!launch_other_payment){
      try{
        Map result = await provider.launchTopUp(customer,
            _phoneNumberFieldController!.text,
            _amountFieldController!.text,
            _getFees(),
            transaction_motif_id ,
            );
        debugPrint('result $result');
        if(result!=null && result['error']==0){
          Navigator.of(context).pop({"success": true,"code":result['code']});
        }
      }catch(_){
        setState(() {
          showLoading(false);
        });
        CherryToast.error(
          title: Text("${AppLocalizations.of(context)!.translate('error')}"),
          description: Text("${AppLocalizations.of(context)!.translate('system_error')}"),
          autoDismiss: true,
        ).show(context);
        launch_other_payment=true;
      }
    }
    if(momo_picked_id=="tmoney") {
      Navigator.of(context).pop();
      return;
    }
       if(launch_other_payment){
      KkiapayProvider kkiapayProvider = new KkiapayProvider();
      kkiapayProvider.launchKkiapayPayment(
        context,
        amount:int.parse(_amountFieldController!.text),
        customer: customer,
        phone_number: _phoneNumberFieldController!.text,
        feesAmount: _getFees(), typeOfTransaction: 'momo',
        );
    }
  }
  void launchNewCardTopUp()async{
    setState(() {
      showLoading(true);
    });
    bool launch_other_payment = false;
    ClientPersonalApiProvider provider = new ClientPersonalApiProvider();
    CustomerModel customer = await CustomerUtils.getCustomer();
    Map<String, dynamic> semoaResult = {};
    try{
      debugPrint("_getRealInitialAmountFromTotal ${_getRealTotalAmountFromInitial()}");
      Map<String, dynamic> paymentData = {
        "amount": (_getRealTotalAmountFromInitial()),
        "description": "Paiement par carte",
        "client": {
          "lastname": "${customer.nickname}",
          "firstname": "",
          "phone": "${_selectedCountryCode}${_phoneNumberFieldController!.text}",
        },
        "type_notif": ["SMS", "MAIL"],
      };
      semoaResult = await provider.launchSemoa(customer, paymentData);
    }catch(_){
      launch_other_payment=true;
    }
    if(semoaResult!=null && semoaResult.isNotEmpty){
      debugPrint('semoaResult $semoaResult');
      if(semoaResult['order_reference']!=null){
        Map<String, dynamic> semoaData = semoaResult;
        List<dynamic> paymentsMethods = semoaData['payments_method'] ?? [];
        String orderReference = semoaData['order_reference'] ?? '';
        Map<String, dynamic> semoaStoreData = {
          'transaction_id': orderReference,
          'amount': int.parse(_amountFieldController!.text),
          'user_id': customer?.id,
          'fees': _getFees(),
          'details': 'Rechargement de carte',
          'transaction_motif_id':1
        };
        Map result = await provider.launchStoreSemoaTransaction(customer,semoaStoreData);
        debugPrint('paymentsMethods: $paymentsMethods');
        if( result!=null && result['data']['success']&& paymentsMethods.isNotEmpty) {
          Map<String, dynamic>? firstPaymentMethod;
          if (paymentsMethods.isNotEmpty && paymentsMethods[0] is List) {
            List<dynamic> firstGroup = paymentsMethods[0];
            if (firstGroup.isNotEmpty) {
              firstPaymentMethod = firstGroup[0];
            }
          }

          if (firstPaymentMethod != null) {
            String actionUrl = firstPaymentMethod['action'] ?? '';
            String gatewayName = firstPaymentMethod['gateway'] ?? 'Unknown';
            String description = firstPaymentMethod['description'] ?? '';
            if(firstPaymentMethod['gateway'].toString().contains("Ecobank-Semoa")){
              setState(() {
                textActionSemoaAvailable=true;
                textActionSemoa = firstPaymentMethod!['action'];
                showLoading(false);
                return;
              });
            }
            if (actionUrl.isNotEmpty && actionUrl.contains('https')) {
              final uri = Uri.parse(actionUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                Navigator.of(context).pop();
              } else {
                launch_other_payment=true;
              }
            }
          }
        }
    }else{
        CherryToast.error(
          title: Text("${AppLocalizations.of(context)!.translate('error')}"),
          description: Text("${AppLocalizations.of(context)!.translate('system_error')}"),
          autoDismiss: true,
        ).show(context);
        setState(() {
          showLoading(false);
        });
      launch_other_payment=true;
      }
    }

    if(launch_other_payment){
      KkiapayProvider kkiapayProvider = new KkiapayProvider();
      String picked_card = bankPaymentModes.where((element) => element["id"]==bank_picked_id).first['name'];;
      kkiapayProvider.launchKkiapayPayment(
        context,
        amount:int.parse(_amountFieldController!.text),
        customer: customer,
        selectedCard: picked_card,
        feesAmount: _getFees(),
        typeOfTransaction: 'card',
      );
      setState(() {
        showLoading(true);
      });
    }
    }
  _onSwitch(int i) {
    setState(() {
      showLoading(false);
      widget.selectedPosition = i;
    });
  }
}
