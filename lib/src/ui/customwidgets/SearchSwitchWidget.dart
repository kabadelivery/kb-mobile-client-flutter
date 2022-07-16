import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tinycolor/tinycolor.dart';

class SearchSwitchWidget extends StatefulWidget {
  Function onSwitch;
  int selected_position;

  Function filterFunction;

  SearchSwitchWidget(this.selected_position, this.onSwitch, this.filterFunction);

  @override
  _SearchSwitchWidgetState createState() {
    return _SearchSwitchWidgetState();
  }
}

class _SearchSwitchWidgetState extends State<SearchSwitchWidget> {
  Color filter_unactive_button_color = Color(0xFFF7F7F7),
      filter_active_button_color = KColors.primaryColor,
      filter_unactive_text_color = Colors.black,
      filter_active_text_color = Colors.white;

  var _filterDropdownValue;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: AnimatedContainer(
              decoration: BoxDecoration(
                color: filter_unactive_button_color,
                borderRadius: BorderRadius.all(const Radius.circular(5.0)),
              ),
              child: Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () => widget.onSwitch(1),
                            child: Container(
                                padding: EdgeInsets.all(10),
                                child: Center(
                                  child: Text(
                                      Utils.capitalize(
                                          "${AppLocalizations.of(context).translate('search_restaurant')}"),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: widget.selected_position == 1
                                              ? this.filter_active_text_color
                                              : this
                                                  .filter_unactive_text_color)),
                                ),
                                decoration: BoxDecoration(
                                    color: widget.selected_position == 1
                                        ? this.filter_active_button_color
                                        : this.filter_unactive_button_color,
                                    borderRadius:
                                        new BorderRadius.circular(5.0)))),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                            onTap: () => widget.onSwitch(2),
                            child: Container(
                                padding: EdgeInsets.all(10),
                                child: Center(
                                  child: Text(
                                      Utils.capitalize(
                                          "${AppLocalizations.of(context).translate('search_food')}"),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: widget.selected_position == 1
                                              ? this.filter_unactive_text_color
                                              : this.filter_active_text_color)),
                                ),
                                decoration: BoxDecoration(
                                    color: widget.selected_position == 1
                                        ? this.filter_unactive_button_color
                                        : this.filter_active_button_color,
                                    borderRadius:
                                        new BorderRadius.circular(5.0)))),
                      ),
                    ]),
              ),
              duration: Duration(milliseconds: 3000),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  // padding: EdgeInsets.only(left:6, top:6, bottom: 6),
                  decoration: BoxDecoration(
                      // color: KColors.primaryColor.withAlpha(60),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: Center(
                    child: DropdownButton<String>(
                      value: _filterDropdownValue,
                      /*hint: Text(
                          "${AppLocalizations.of(context).translate('filter')}"
                              .toUpperCase(),
                          style: TextStyle(
                              fontSize: 14, color: KColors.primaryColor)),
                      */

                      /*Container(decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(5))), padding: EdgeInsets.all(5),
                                    child: Text("${AppLocalizations.of(context).translate('filter')}".toUpperCase(), style: TextStyle(fontSize: 14,color:KColors.primaryColor))),
                                */
                      icon: Icon(
                        FontAwesomeIcons.filter,
                        color: KColors.primaryColor,
                        size: 16,
                      ),
                      iconSize: 16,
                      elevation: 16,
                      style: TextStyle(color: KColors.primaryColor),
                      underline: Container(
//                      height: 2,
//                      color: Colors.deepPurpleAccent,
                          ),
                      onChanged: (String newValue) {
                       widget.filterFunction(newValue);
                      },
                      items: <String>[
                        '${AppLocalizations.of(context).translate('cheap_to_exp')}',
                        '${AppLocalizations.of(context).translate('exp_to_cheap')}',
                        '${AppLocalizations.of(context).translate('nearest')}',
                        '${AppLocalizations.of(context).translate('farest')}'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
