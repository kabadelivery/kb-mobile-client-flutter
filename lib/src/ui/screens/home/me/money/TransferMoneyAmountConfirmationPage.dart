import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kaba_flutter/src/StateContainer.dart';
import 'package:kaba_flutter/src/contracts/transfer_money_amount_confirmation_contract.dart';
import 'package:kaba_flutter/src/contracts/transfer_money_request_contract.dart';
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/ui/screens/auth/pwd/RetrievePasswordPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/settings/WebViewPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/_static_data/MusicData.dart';
import 'package:kaba_flutter/src/utils/functions/CustomerUtils.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';
import 'package:toast/toast.dart';
import 'package:vibration/vibration.dart';

import 'TransferMoneySuccessPage.dart';


class TransferMoneyAmountConfirmationPage extends StatefulWidget {

  static var routeName = "/TransferMoneyAmountConfirmationPage";

  TransferMoneyAmountConfirmationPresenter presenter;

  CustomerModel mySelf;

  TransferMoneyAmountConfirmationPage({Key key, this.title, this.moneyReceiver, this.presenter}) : super(key: key);

  final String title;

  CustomerModel moneyReceiver;

  @override
  _TransferMoneyAmountConfirmationPageState createState() => _TransferMoneyAmountConfirmationPageState();
}

class _TransferMoneyAmountConfirmationPageState extends State<TransferMoneyAmountConfirmationPage> implements TransferMoneyAmountConfirmationView {


  TextEditingController _amountFieldController;

  var isLaunching = false;
  bool _isAmountOk = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.presenter.transferMoneyAmountConfirmationView = this;
    _amountFieldController = new TextEditingController();
    _amountFieldController.addListener(()=>isAmountOk());

    CustomerUtils.getCustomer().then((customer) {
      widget.mySelf = customer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: KColors.primaryColor),
            onPressed: () {
              Navigator.pop(context);
            }),
        backgroundColor: Colors.white,
        title: Text("TO KABA ACCOUNT", style:TextStyle(color:KColors.primaryColor)),
      ),
      body: SingleChildScrollView(
        child: Column(
            children: <Widget>[
              SizedBox(height:20),

              Center(
                child: Column(children: <Widget>[
                  Container(
                      height:100, width: 100,
                      decoration: BoxDecoration(
                          border: new Border.all(color: Colors.white, width: 2),
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(Utils.inflateLink(widget?.moneyReceiver?.profile_picture))
                          )
                      )
                  ),
                  Text(widget?.moneyReceiver?.nickname, textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.bold),),
                  SizedBox(height:5),
                  Text(Utils.hidePhoneNumber(widget?.moneyReceiver?.phone_number), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.normal),),
                ]),
              ),

              SizedBox(height: 30),

              Container(child:Text("Please enter the amount you want to transfer", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey))),

              SizedBox(height: 30),

              Container(
                color: Colors.white,
                padding: EdgeInsets.only(top:10,bottom:10, left:20, right: 20),
                child: Column(
                  children: <Widget>[
                    Text("Amount", textAlign: TextAlign.left, style: TextStyle(color: Colors.black)),
                    SizedBox(height:10),
                    Row(children: <Widget>[
                      Text("XOF", style: TextStyle(fontSize: 20, color: Colors.black)),
                      SizedBox(width:20),
                      Expanded(flex: 7, child:
                      TextField(controller: _amountFieldController, keyboardType: TextInputType.number, enabled: !isLaunching, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                          decoration: InputDecoration( /* if  already sat, we cant put nothing else */
//                        border: InputBorder.none,
                              enabledBorder:OutlineInputBorder(
                                borderSide: BorderSide(color: KColors.primaryColor, width: 5.0),
                              )
                          ))
                      ),
                    ]),
                  ],
                ),
              ),

              SizedBox(height: 20),

              Container(margin: EdgeInsets.only(top:15, bottom:15, left:20, right:20),
                child: SizedBox(
                  width: double.infinity,
                  child: MaterialButton(color: _isAmountOk ? KColors.primaryColor : KColors.primaryColor.withAlpha(150),  padding: EdgeInsets.only(top:5, bottom:5),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("PAY", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white)),
                          isLaunching ?  Row(
                            children: <Widget>[
                              SizedBox(width: 10),
                              SizedBox(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)), height: 20, width: 20) ,
                            ],
                          )  : Container(),
                        ],
                      ), onPressed: () {
                        iLaunchTransaction();
                      }),
                ),
              ),
            ]
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


  Future<void> iLaunchTransaction() async {

    if (isLaunching)
      return;

    if (!_isAmountOk) {
      _showDialog(
          message:"Sorry, balance must be > 0 and valuable",
          icon: Icon(FontAwesomeIcons.exclamationTriangle, color: Colors.black)
      );
      return;
    }

    // pick password
    var results =  await Navigator.of(context).push(new MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          return RetrievePasswordPage(type: 2);
        }
    ));
    // retrieve password then do it,
    if (results != null && results.containsKey('code') && results.containsKey('type')) {
      if (results == null || results['code'] == null ||
          !Utils.isCode(results['code'])) {
        mToast("my code is not ok");
      } else {
        String _mCode = results['code'];
        if (Utils.isCode(_mCode)) {
          String amount = _amountFieldController.text;
          if (widget.moneyReceiver != null && widget.mySelf != null)
            widget.presenter.launchTransferMoneyAction(widget.mySelf, widget.moneyReceiver.id, _mCode, amount);
        } else {
          mToast("my code is not ok");
        }
      }
    }
  }

  void mToast(String message) {
    Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }


  @override
  void balanceInsufficient() {
    _showDialog(
        message:"Sorry, Balance not enough. Please top up your account by T-money and Flooz and try again.",
        icon: Icon(FontAwesomeIcons.exclamationTriangle, color: Colors.black)
    );
  }

  @override
  void passwordWrong() {
    _showDialog(
        message:"Sorry, Password wrong. Check your password and try again",
        icon: Icon(FontAwesomeIcons.exclamationTriangle, color: Colors.black)
    );
  }

  @override
  void transactionError(CustomerModel customer) {
    _showDialog(
        message:"Sorry, Transaction error.\nPlease contact system administrator.",
        icon: Icon(FontAwesomeIcons.exclamationTriangle, color: Colors.black)
    );
  }

  @override
  void transactionSuccessful(CustomerModel moneyReceiver, String amount, String balance) {

    // jump to success page
    StateContainer.of(context).updateBalance(balance: int.parse(balance));
    // give money
    Navigator.pop(context);
    Navigator.of(context).push(new MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          return TransferMoneySuccessPage(amount: amount, moneyReceiver: moneyReceiver);
        }
    ));

  }

  void _showDialog({var icon, var message, bool isSuccess = false}) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
//          title: new Text("Alert Dialog title"),
            content: Column(mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  /* icon */
                  SizedBox(
                    height: 120,
                    width: 120,
                    child:
                    icon,
                  ),
                  SizedBox(height: 10),
                  Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 13))
                ]
            ),actions: <Widget>[
          //
          OutlineButton(
            child: new Text("OK", style: TextStyle(color:KColors.primaryColor)),
            onPressed: () {
              if (isSuccess)
                Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ]
        );
      },
    );
  }

  Future<void> _playMusicForSuccess() async {
    // play music
    AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
    audioPlayer.setVolume(1.0);
    AudioPlayer.logEnabled = true;
    var audioCache = new AudioCache(fixedPlayer: audioPlayer);
    audioCache.play(MusicData.money_transfer_successfull);
    if (await Vibration.hasVibrator ()
    ) {
      Vibration.vibrate(duration: 500);
    }
  }

  isAmountOk () {

    // only ints
    String amount = _amountFieldController.text;
    final regex = RegExp(r'^[0-9]{2,5}$');
    bool res = regex.hasMatch(amount) && int.parse(amount) > 0;
    setState(() {
      _isAmountOk = res;
    });
  }

}
