import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchSwitchWidget extends StatefulWidget {
  Function onSwitch;
  int selectedPosition;
  Function filterFunction;

  String type;

  Function scrollToTopFunction;
  Function listContentFilter;

  Map<String, dynamic> filterConfiguration;

  SearchSwitchWidget(
      this.selectedPosition,
      this.onSwitch,
      this.filterFunction,
      this.listContentFilter,
      this.scrollToTopFunction,
      this.type,
      this.filterConfiguration);

  @override
  _SearchSwitchWidgetState createState() {
    return _SearchSwitchWidgetState();
  }
}

class _SearchSwitchWidgetState extends State<SearchSwitchWidget> {
  Color filter_unactive_button_color = Color(0xFFF7F7F7),
      filter_active_button_color = KColors.primaryColor,
      filter_unactive_text_color = KColors.new_black,
      filter_active_text_color = Colors.white;

  var _filterDropdownValue;

  var _searchChoices = null;

  @override
  void initState() {
    super.initState();
  }

  getCategoryTitle(BuildContext context) {
    var tmp = [
      AppLocalizations.of(context)!.translate('service_shop_type_name'),
      AppLocalizations.of(context)!.translate('service_shop_type_product')
    ];

    switch (widget?.type) {
      case "food": // food
        tmp = [
          AppLocalizations.of(context)
              !.translate('service_restaurant_type_name'),
          AppLocalizations.of(context)
              !.translate('service_restaurant_type_product')
        ];
        break;
      case "drink": // drinks
        tmp = [
          AppLocalizations.of(context)!.translate('service_drink_type_name'),
          AppLocalizations.of(context)!.translate('service_drink_type_product')
        ];
        break;
      case "flower": // flowers
        tmp = [
          AppLocalizations.of(context)!.translate('service_flower_type_name'),
          AppLocalizations.of(context)!.translate('service_flower_type_product')
        ];
        break;
      case "book": // flowers
        tmp = [
          AppLocalizations.of(context)!.translate('service_book_type_name'),
          AppLocalizations.of(context)!.translate('service_book_type_product')
        ];
        break;
        /*   case "supermarket": // flowers
        tmp = [
          AppLocalizations.of(context)!.translate('service_flower_type_name'),
          AppLocalizations.of(context)!.translate('service_flower_type_product')
        ];*/
        break;
      //   case 1005: // movies
      //     category_name_code = "service_category_movies";
      //     break;
      //   case 1006: // package delivery
      //     category_name_code = "service_category_package_delivery";
      //     break;
      case "shop": // shopping
        tmp = [
          AppLocalizations.of(context)!.translate('service_shop_type_name'),
          AppLocalizations.of(context)!.translate('service_shop_type_product')
        ];
        break;
      case "ticket": // ticket
        tmp = [
          AppLocalizations.of(context)!.translate('service_ticket_type_name'),
          AppLocalizations.of(context)!.translate('service_ticket_product_name')
        ];
        break;
      case "grocery": // ticket
        tmp = [
          AppLocalizations.of(context)!.translate('service_grocery_type_name'),
          AppLocalizations.of(context)!.translate('service_grocery_product_name')
        ];
        break;
    }
    return tmp;
  }

  @override
  Widget build(BuildContext context) {
    if (_searchChoices == null) _searchChoices = getCategoryTitle(context);

    return widget?.type == "ticket"
        ? Container()
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 5,
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
                                onTap: () => widget.onSwitch(1),
                                child: Container(
                                    height: 36,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Center(
                                      child: Text(Utils.capitalize(
                                              // "${AppLocalizations.of(context)!.translate('search_restaurant')}"),
                                              _searchChoices[0]),
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
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
                                          Utils.capitalize(_searchChoices[1]),
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: widget.selectedPosition ==
                                                      1
                                                  ? this
                                                      .filter_unactive_text_color
                                                  : this
                                                      .filter_active_text_color)),
                                    ),
                                    decoration: BoxDecoration(
                                        color: widget.selectedPosition == 1
                                            ? this.filter_unactive_button_color
                                            : this.filter_active_button_color,
                                        borderRadius:
                                            new BorderRadius.circular(5.0)))),
                          ),
                        ]),
                    duration: Duration(milliseconds: 3000),
                  ),
                ),
                SizedBox(width: 5),
                widget.selectedPosition == 1
                    ? GestureDetector(
                        onTap: (){
                          widget
                              .listContentFilter();
                        }, //widget.scrollToTopFunction,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          width: 70,
                          child: widget.filterConfiguration != null &&
                                  widget.filterConfiguration["opened_filter"] ==
                                      true
                              ? Container(
                                  height: 40,
                                  width: 30,
                                  child: Image.asset(
                                    ImageAssets.opened,
                                    height: 40.0,
                                    width: 40.0,
                                    fit: BoxFit.fitHeight,
                                    alignment: Alignment.center,
                                  ))
                              :
                          // ShakeItem(autoPlay: _autoPlay, shakeList: [ShakeDefaultConstant1(),ShakeDefaultConstant2()]),
                          ShakeWidget(
                            duration: Duration(milliseconds: 1000),
                            shakeConstant: ShakeLittleConstant1(),
                            autoPlay: true,
                            enableWebMouseHover: true,

                          child: Container(
                                    height: 20,
                                    width: 20,
                                    child: Image.asset(
                                      ImageAssets.filter_red,
                                      height: 20.0,
                                      width: 20.0,
                                      alignment: Alignment.center,
                                    )),
                              ),
                          decoration: BoxDecoration(
                              /* color: KColors.primaryColor.withAlpha(30),*/
                              borderRadius: BorderRadius.circular(5)),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            // padding: EdgeInsets.only(left:6, top:6, bottom: 6),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: Center(
                              child: DropdownButton<String>(
                                value: _filterDropdownValue,
                                /*hint: Text(
                        "${AppLocalizations.of(context)!.translate('filter')}"
                            .toUpperCase(),
                        style: TextStyle(
                            fontSize: 14, color: KColors.primaryColor)),
                    */

                                /*Container(decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(5))), padding: EdgeInsets.all(5),
                                  child: Text("${AppLocalizations.of(context)!.translate('filter')}".toUpperCase(), style: TextStyle(fontSize: 14,color:KColors.primaryColor))),
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
                                onChanged: (String? newValue) {
                                  widget.filterFunction(newValue);
                                },
                                items: <String>[
                                  '${AppLocalizations.of(context)!.translate('cheap_to_exp')}',
                                  '${AppLocalizations.of(context)!.translate('exp_to_cheap')}',
                                  '${AppLocalizations.of(context)!.translate('nearest')}',
                                  '${AppLocalizations.of(context)!.translate('farest')}'
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
                      )
              ],
            ),
          );
  }
}
