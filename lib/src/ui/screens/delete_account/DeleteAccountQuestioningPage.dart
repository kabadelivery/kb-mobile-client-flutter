import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/delete_account_questionning_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/ui/screens/delete_account/DeleteAccountFixPropositionPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/LottieAssets.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class DeleteAccountQuestioningPage extends StatefulWidget {
  static var routeName = "/DeleteAccountQuestioningPage";

  DeleteAccountQuestioningPresenter presenter;

  CustomerModel customer;

  DeleteAccountQuestioningPage({this.presenter});

  @override
  State<StatefulWidget> createState() {
    return DeleteAccountQuestioningPageState();
  }
}

class DeleteAccountQuestioningPageState
    extends State<DeleteAccountQuestioningPage>
    implements DeleteAccountQuestioningView {
  var considered_questiosn = [
    "delivery_too_long",
    "expensive_items",
    "damaged_item",
    "shipping_fees_expensive",
    "cant_find_product",
    "item_different_at_delivery",
    "none_of_the_above",
  ];

  TextEditingController _messageFieldController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    widget.presenter.addDeleteAccountQuestioningView = this;

    CustomerUtils.getCustomer().then((customer) {
      setState(() {
        widget.customer = customer;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: StateContainer.ANDROID_APP_SIZE,
          brightness: Brightness.light,
          backgroundColor: KColors.primaryColor,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () {
                Navigator.pop(context);
              }),
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  Utils.capitalize(
                      "${AppLocalizations.of(context).translate('delete_account')}"),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 30,
              ),
              Container(
                width: 100,
                height: 100,
                child: Lottie.asset(LottieAssets.sad_face),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                "${AppLocalizations.of(context).translate('delete_account')}",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${AppLocalizations.of(context).translate('why_delete_account')}",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(considered_questiosn.length, (index) {
                  return InformationCheckBox(
                    tag: "${considered_questiosn[index]}",
                    onChanged: _onCheckBoxChanged,
                  );
                }).toList(),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                  "${AppLocalizations.of(context).translate("anything_else_to_say")}",
                  style: TextStyle(
                      color: KColors.new_black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                      color: KColors.new_gray,
                      borderRadius: BorderRadius.circular(5)),
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageFieldController,
                          minLines: 4,
                          maxLines: 5,
                          decoration: InputDecoration.collapsed(
                              hintText: "...",
                              hintStyle: TextStyle(color: Colors.grey)),
                          textAlign: TextAlign.start,
                          style: TextStyle(color: KColors.new_black),
                        ),
                      ),
                    ],
                  )),
              SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  _confirm();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                      color: KColors.primaryColor,
                      borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      isLoading
                          ? SizedBox(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                              height: 20,
                              width: 20,
                            )
                          : Container(
                              width: 20,
                            ),
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            /* loading something eventually */
                            Text(
                                "${AppLocalizations.of(context).translate('confirm')}"
                                    .toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ));
  }

  Map<String, bool> accountQuestioning = Map();

  _onCheckBoxChanged(bool value, String tag) {
    // keep a map and put the informations into that
    accountQuestioning[tag] = value;
  }

  @override
  void networkError() {}

  @override
  void showLoading(bool isLoading) {
    // show loading
    setState(() {
      this.isLoading = isLoading;
    });
  }

  @override
  void systemError() {
    SnackBar snackBar = SnackBar(
      content:
          Text("${AppLocalizations.of(context).translate('system_error')}"),
      action: SnackBarAction(
        label: "${AppLocalizations.of(context).translate('ok')}".toUpperCase(),
        onPressed: () {
          // Some code to undo the change.
          ScaffoldMessenger.of(context).clearSnackBars();
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void showProposedReparation(VoucherModel mVoucher, int fixId, int balance) {
    // move to the next activity for that
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeleteAccountFixPropositionPage(fixId: fixId, balance: balance,
            voucher: mVoucher),
      ),
    );
  }

  void _confirm() {
    /* get message and all the selected box content and send it,
    * then wait for the voucher proposition and move*/
    List<String> reasons = [];
    for (int i = 0; i < accountQuestioning.keys.length; i++) {
      if (accountQuestioning[accountQuestioning.keys.elementAt(i)] == true) {
        reasons.add(accountQuestioning.keys.elementAt(i));
      }
    }
    widget.presenter.postQuestioningResult(
        widget.customer, reasons, _messageFieldController.text);
  }
}

class InformationCheckBox extends StatefulWidget {
  String question;

  String tag;

  Function onChanged;

  InformationCheckBox({Key key, this.tag, this.onChanged}) : super(key: key);

  @override
  State<InformationCheckBox> createState() => _InformationCheckBoxState();
}

class _InformationCheckBoxState extends State<InformationCheckBox> {
  bool is_checked = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(value: is_checked, onChanged: _onChanged),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                    "${AppLocalizations.of(context).translate(widget.tag)}",
                    style: TextStyle(fontSize: 14, color: KColors.new_black)),
              )
            ]),
        SizedBox(height: 5)
      ],
    );
  }

  void _onChanged(bool value) {
    setState(() {
      this.is_checked = !this.is_checked;
    });
    widget.onChanged(this.is_checked, widget.tag);
  }
}
