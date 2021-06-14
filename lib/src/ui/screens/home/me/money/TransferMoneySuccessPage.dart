import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/MusicData.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
//import 'package:audioplayers/audio_cache.dart';
//import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';


class TransferMoneySuccessPage extends StatefulWidget {

  static var routeName = "/TransferMoneySuccessPage";

  TransferMoneySuccessPage({Key key, this.amount, this.moneyReceiver}) : super(key: key);

  final String amount;

  CustomerModel moneyReceiver;

  @override
  _TransferMoneySuccessPageState createState() => _TransferMoneySuccessPageState();
}

class _TransferMoneySuccessPageState extends State<TransferMoneySuccessPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _playMusicForSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Stack(
              children: <Widget>[
//              SizedBox(height:50),
                Positioned(
                  top: 50,
                  child:   Container(
                    width: MediaQuery.of(context).size.width,
//                  color: Colors.lightBlueAccent,
                    child: Column(
                      children: <Widget>[
                        Container(
                            height:100, width: 100,
                            decoration: BoxDecoration(
//                      border: new Border.all(color: Colors.white, width: 2),
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                  fit: BoxFit.cover,
                                  image: new AssetImage(ImageAssets.ic_transaction_success),
                                )
                            )
                        ),
                        Container(child:Text("${AppLocalizations.of(context).translate('success')}", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey))),
                        SizedBox(height: 30),
                        Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                          Text("${widget.amount}", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                          SizedBox(width: 5),
                          Text("${AppLocalizations.of(context).translate('currency')}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
                        ]),
                        SizedBox(height: 30),
                        Container(child:Text("${AppLocalizations.of(context).translate('payee')}", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey))),
                        SizedBox(height: 30),
                        Center(
                          child: Column(children: <Widget>[
                            Container(
                                height:70, width: 70,
                                decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    image: new DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(Utils.inflateLink(widget?.moneyReceiver?.profile_picture))
                                    )
                                )
                            ),
                            SizedBox(height: 10),

                            Text("${widget?.moneyReceiver?.username}", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.bold),),
                            SizedBox(height:5),
                            Text("${Utils.hidePhoneNumber(widget?.moneyReceiver?.phone_number)}", textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.normal),),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
//                left:30,
                    bottom:30,
                    child: Container(
                        width: MediaQuery.of(context).size.width,
//                      width:  80,
//                      height: 35,
                        child:Column(
                          children: <Widget>[
                            SizedBox(
                              child: OutlineButton(borderSide: BorderSide(color: KColors.primaryYellowColor),
                                child: new Text("${AppLocalizations.of(context).translate('ok')}", style: TextStyle(color: KColors.primaryYellowColor)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ],
                        )
                    )
                  /*Row(mainAxisAlignment: MainAxisAlignment.center,mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SizedBox(width: 100, height:40,
                          child: OutlineButton(borderSide: BorderSide(color: Colors.lightBlueAccent),
                            child: new Text("OK", style: TextStyle(color:KColors.primaryColor)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ))
                    ],
                  ),*/
                )
              ]
          ),
        )
    );
  }


  Future<void> _playMusicForSuccess() async {
    // play music
    // AudioPlayer audioPlayer = AudioPlayer();
    // audioPlayer.play(MusicData.money_transfer_successfull);
    if (await Vibration.hasVibrator ()
    ) {
      Vibration.vibrate(duration: 500);
    }
  }
}
