import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/ui/customwidgets/MyVoucherMiniWidget.dart';
import 'package:KABA/src/utils/_static_data/FlareData.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/MusicData.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';


class VoucherSubscribeSuccessPage extends StatefulWidget {

  static var routeName = "/VoucherSubscribeSuccessPage";

  VoucherSubscribeSuccessPage({Key key, this.voucher}) : super(key: key);

  VoucherModel voucher;

  @override
  _VoucherSubscribeSuccessPageState createState() => _VoucherSubscribeSuccessPageState();
}

class _VoucherSubscribeSuccessPageState extends State<VoucherSubscribeSuccessPage> {

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
                Positioned(
                  top: 50,
                  left:0,
                  child:  Column(mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                      Container(width: 200,height:200,
                        child: FlareActor(
                            FlareData.success_check,
                            alignment: Alignment.center,
                            animation: "verified",
                            fit: BoxFit.contain,
                            isPaused : false
                        ),
                      ),

                      SizedBox(height: 10),
                      Text("${AppLocalizations.of(context).translate('congrats_subscribe')}", textAlign: TextAlign.center, style: KStyles.hintTextStyle_gray),

                      SizedBox(height: 20),

                      Container(margin: EdgeInsets.all(8), width: MediaQuery.of(context).size.width*.95,
                          child: MyVoucherMiniWidget(voucher: widget.voucher)),
                    ]
                  )
                ),
                Positioned(
                    bottom:30,
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        child:Column(
                          children: <Widget>[
                            SizedBox(
                              child: OutlineButton(borderSide: BorderSide(color: KColors.primaryColor),
                                child: new Text("${AppLocalizations.of(context).translate('ok')}".toUpperCase(), style: TextStyle(color: KColors.primaryColor)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ],
                        )
                    )
                )
              ]
          ),
        )
    );
  }


  Future<void> _playMusicForSuccess() async {
    
    return;
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
}
