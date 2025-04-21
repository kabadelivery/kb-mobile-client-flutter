import 'package:KABA/src/models/PreOrderConfiguration.dart';
import 'package:KABA/src/ui/customwidgets/MRaisedButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class CustomSwitchPage extends StatefulWidget {

  String? button_1_name, button_2_name;
  Color? active_text_color, unactive_text_color;
  Color? active_button_color, unactive_button_color;

  CustomSwitchPage({required Key key,
    this.button_1_name,
    this.button_2_name,
    this.active_text_color,
    this.unactive_text_color,
    this.active_button_color,
    this.unactive_button_color,
  }): super(key:key);


  @override
  State<StatefulWidget> createState() {
    return _CustomSwitchPageState(this.button_1_name!,
        this.button_2_name!,
        this.active_text_color!,
        this.unactive_text_color!,
        this.active_button_color!,
        this.unactive_button_color!);
  }

}

class _CustomSwitchPageState extends State<CustomSwitchPage> {

  String? button_1_name, button_2_name;
  Color? active_text_color, unactive_text_color;
  Color active_button_color, unactive_button_color;

  int? position = 1;

  PreOrderConfiguration? preOrderConfiguration; // 1 is active; 2 is unactive

  _CustomSwitchPageState( this.button_1_name,
      this.button_2_name,
      this.active_text_color,
      this.unactive_text_color,
      this.active_button_color,
      this.unactive_button_color,);

  @override
  Widget build(BuildContext context) {

    return AnimatedContainer(
      decoration: BoxDecoration(color: position == 1 ? this.unactive_button_color : this.unactive_button_color, borderRadius: BorderRadius.all(const  Radius.circular(40.0)),
        border: new Border.all(color: position == 2 ? this.unactive_button_color : this.unactive_button_color, width: 1),
      ),
      padding: EdgeInsets.all(5),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            MRaisedButton(elevation: 0.0, onPressed: () => _choice(1), child: Text(this.button_1_name!, style: TextStyle(color: position == 1 ? this.active_text_color:this.unactive_text_color)), color: position == 1 ? this.active_button_color :  this.unactive_button_color, borderRadius: new BorderRadius.circular(30.0)),
            SizedBox(width: 10),
            MRaisedButton(elevation: 0.0,onPressed: () => _choice(2), child: Text(this.button_2_name!, style: TextStyle(color: position == 1 ? this.unactive_text_color : this.active_text_color)),  color: position == 1 ? this.unactive_button_color : this.active_button_color, borderRadius: new BorderRadius.circular(30.0)),
          ]), duration: Duration(milliseconds: 700),
    );
  }

  _choice(int selected) {
    setState(() {
      this.position = selected;
    });
  }

}