

import 'dart:math';

import 'package:KABA/src/utils/_static_data/MusicData.dart';
import 'package:flare_flutter/base/animation/actor_animation.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';


class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  @override
  Widget build(BuildContext context) {
//    return Scaffold();
    return new Scaffold(
        body: Center(
          child: MaterialButton(
              child: Text("ok"),
              onPressed: () {
_playMusic();
              }
          ),
        )

      //TrackingInput(),
    );
  }


}

 Future<void> _playMusic() async {

    // play music
  /*  AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
    audioPlayer.setVolume(1.0);
    AudioPlayer.logEnabled = true;
    audioPlayer.play(MusicData.command_success_hold_on);*/

   // final player = AudioPlayer();
   // player.setAudioSource(AudioSource.uri(Uri.parse(
   //     "${MusicData.command_success_hold_on}")));
   // var duration = await player.setAsset(MusicData.command_success_hold_on, preload: true);
   //
   // player.setAudioSource(AudioSource.uri(Uri.parse('asset:///${MusicData.c_command_success_hold_on}')),
   //      initialPosition: Duration.zero, preload: true);
   //
   // player.play();
    if (await Vibration.hasVibrator ()
    ) {
      Vibration.vibrate(duration: 500);
    }
  }



// track user input
class TrackingInput extends StatefulWidget {
  @override
  TrackingState createState() => new TrackingState();
}
class TrackingState extends State<TrackingInput> {

  ///these get set when we build the widget
  double screenWidth = 0.0;
  double screenHeight = 0.0;

  ///this is the animation controller for the water and iceBoy
  AnimationControls _flareController;

  ///an example of how to set up individual controllers
  final FlareControls plusWaterControls = FlareControls();
  final FlareControls minusWaterControls = FlareControls();

  ///the current number of glasses drunk
  int currentWaterCount = 0;

  ///this will come from the selectedGlasses times ouncesPerGlass
  /// we'll use this to calculate the transform of the water fill animation
  int maxWaterCount = 0;

  ///we'll default at 8, but this will change based on user input
  int selectedGlasses = 8;

  ///this doesn't change, hence the 'static const', we always count 8 ounces
  ///per glass (it's assuming)
  static const int ouncePerGlass = 8;

  void initState() {
    _flareController = AnimationControls();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(93, 93, 93, 1),
      body: Container(
        ///Stack some widgets
        color: const Color.fromRGBO(93, 93, 93, 1),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ///this is our main artboard with iceboy and the water fill
            FlareActor(
              "assets/flare/WaterArtboards.flr",
              controller: _flareController,
              fit: BoxFit.contain,
              animation: "iceboy",
              artboard: "Artboard",
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Spacer(),
                ///Each widget on the main view
                addWaterBtn(),
                subWaterBtn(),
                settingsButton(),
              ],
            )
          ],
        ),
      ),
    );
  }
  ///set up our bottom sheet menu
  void _showMenu() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter updateModal) {
            return Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(93, 93, 93, 1),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    "Set Target",
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                        fontSize: 24.0),
                    textAlign: TextAlign.center,
                  ),
                  // Some vertical padding between text and buttons row
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ///our animated button that increases your goal
                      FlareWaterTrackButton(
                        artboard: "UI arrow left",
                        pressAnimation: "arrow left press",
                        onPressed: () => _incSelectedGlasses(updateModal, -1),
                      ),
                      Expanded(
                        child: Text(
                          selectedGlasses.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                              fontSize: 40.0),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ///our animated button that decreases your goal
                      FlareWaterTrackButton(
                        artboard: "UI arrow right",
                        pressAnimation: "arrow right press",
                        onPressed: () => _incSelectedGlasses(updateModal, 1),
                      ),
                    ],
                  ),
                  // Some vertical padding between text and buttons row
                  const SizedBox(height: 20),
                  Text(
                    "/glasses",
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                        fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                  // Some vertical padding between text and buttons row
                  const SizedBox(height: 20),
                  ///our Flare button that closes our menu
                  ///TODO: Here is your challenge!
                  FlareWaterTrackButton(
                    artboard: "UI refresh",
                    onPressed: () {
                      _resetDay();
                      // close modal
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  ///this is a quick reset for the user, to reset the intake back to zero
  void _resetDay() {
    setState(() {
      currentWaterCount = 0;
      _flareController.resetWater();
    });
  }

  ///we'll use this to increase how much water the user has drunk, hooked
  ///via button
  void _incrementWater() {
   /* setState(() {
      if (currentWaterCount < selectedGlasses) {
        currentWaterCount = currentWaterCount + 1;

        double diff = currentWaterCount / selectedGlasses;

        plusWaterControls.play("plus press");

        _flareController.playAnimation("ripple");

        _flareController.updateWaterPercent(diff);
      }

      if (currentWaterCount == selectedGlasses) {
        _flareController.playAnimation("iceboy_win");
      }
    });
  */}

  ///we'll use this to decrease our user's water intake, hooked to a button
  void _decrementWater() {
    setState(() {
      if (currentWaterCount > 0) {
        currentWaterCount = currentWaterCount - 1;
        double diff = currentWaterCount / selectedGlasses;

        _flareController.updateWaterPercent(diff);

        // _flareController.playAnimation("ripple");
      } else {
        currentWaterCount = 0;
      }
      minusWaterControls.play("minus press");
    });
  }

  void calculateMaxOunces() {
    maxWaterCount = selectedGlasses * ouncePerGlass;
  }

  void _incSelectedGlasses(StateSetter updateModal, int value) {
    updateModal(() {
      selectedGlasses = (selectedGlasses + value).clamp(0, 26).toInt();
      calculateMaxOunces();
    });
  }


  Widget settingsButton() {
    return RawMaterialButton(
      constraints: BoxConstraints.tight(Size(95, 30)),
      onPressed: _showMenu,
      shape: Border(),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      elevation: 0.0,
      child: FlareActor("assets/flare/WaterArtboards.flr",
          fit: BoxFit.contain,
          sizeFromArtboard: true,
          artboard: "UI Ellipse"),
    );
  }

  Widget addWaterBtn() {
    return RawMaterialButton(
      constraints: BoxConstraints.tight(const Size(150, 150)),
      onPressed: _incrementWater,
      shape: Border(),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      elevation: 0.0,
      child: FlareActor("assets/flare/WaterArtboards.flr",
          controller: plusWaterControls,
          fit: BoxFit.contain,
          animation: "plus press",
          sizeFromArtboard: false,
          artboard: "UI plus"),
    );
  }

  Widget subWaterBtn() {
    return RawMaterialButton(
      constraints: BoxConstraints.tight(const Size(150, 150)),
      onPressed: _decrementWater,
      shape: Border(),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      elevation: 0.0,
      child: FlareActor("assets/flare/WaterArtboards.flr",
          controller: minusWaterControls,
          fit: BoxFit.contain,
          animation: "minus press",
          sizeFromArtboard: true,
          artboard: "UI minus"),
    );
  }
}


class AnimationControls extends FlareController {

  ///so we can reference this any where once we declare it
  FlutterActorArtboard _artboard;

  ///our fill animation, so we can animate this each time we add/reduce water intake
  ActorAnimation _fillAnimation;

  ///our ice cube that moves on the Y Axis based on current water intake
  ActorAnimation _iceboyMoveY;

  ///used for mixing animations
  final List<FlareAnimationLayer> _baseAnimations = [];

  ///our overall fill
  double _waterFill = 0.00;

  ///current amount of water consumed
  double _currentWaterFill = 0;

  ///time used to smooth the fill line movement
  double _smoothTime = 5;

  void initialize(FlutterActorArtboard artboard) {
    //get the reference here on start to our animations and artboard
    _artboard = artboard;
    _fillAnimation = artboard.getAnimation("water up");
    _iceboyMoveY = artboard.getAnimation("iceboy_move_up");
  }


  bool advance(FlutterActorArtboard artboard, double elapsed) {
    //we need this separate from our generic mixing animations,
// b/c the animation duration is needed in this calculation
    if (artboard.name.compareTo("Artboard") == 0) {
      _currentWaterFill += (_waterFill - _currentWaterFill) * min(1, elapsed *
          _smoothTime);
      _fillAnimation.apply(
          _currentWaterFill * _fillAnimation.duration, artboard, 1);
      _iceboyMoveY.apply(
          _currentWaterFill * _iceboyMoveY.duration, artboard, 1);
    }
    int len = _baseAnimations.length - 1;
    for (int i = len; i >= 0; i--) {
      FlareAnimationLayer layer = _baseAnimations[i];
      layer.time += elapsed;
      layer.mix = min(1.0, layer.time / 0.01);
      layer.apply(_artboard);
      if (layer.isDone) {
        _baseAnimations.removeAt(i);
      }
    }
    return true;
  }

  void setViewTransform(Mat2D viewTransform) {}


  ///called from the 'tracking_input'
 /* void playAnimation(String animName){
    ActorAnimation animation = _artboard.getAnimation(animName);
    if (animation != null) {
      _baseAnimations.add(FlareAnimationLayer()
        ..name = animName
        ..animation = animation
      );
    }
  }*/
  ///called from the 'tracking_input'
  ///updates the water fill line
  void updateWaterPercent(double amt){
    _waterFill = amt;
  }
  ///called from the 'tracking_input'
  ///resets the water fill line
  void resetWater(){
    _waterFill = 0;
  }
}

/// Button with a Flare widget that automatically plays
/// a Flare animation when pressed. Specify which animation
/// via [pressAnimation] and the [artboard] it's in.
class FlareWaterTrackButton extends StatefulWidget {
  final String pressAnimation;
  final String artboard;
  final VoidCallback onPressed;
  const FlareWaterTrackButton(
      {this.artboard, this.pressAnimation, this.onPressed});

  @override
  _FlareWaterTrackButtonState createState() => _FlareWaterTrackButtonState();
}

class _FlareWaterTrackButtonState extends State<FlareWaterTrackButton> {
  final _controller = FlareControls();

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      constraints: BoxConstraints.tight(const Size(95, 85)),
      onPressed: () {
        _controller.play(widget.pressAnimation);
        widget.onPressed?.call();
      },
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: FlareActor("assets/flare/WaterArtboards.flr",
          controller: _controller,
          fit: BoxFit.contain,
          artboard: widget.artboard),
    );
  }
}



