import 'package:KABA/src/microservices/kaba_chine/Enums/TarifType.dart';
import 'package:KABA/src/microservices/kaba_chine/domain/tarif/tarif_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/utils.dart';
import '../../domain/tarif/shipping_entity.dart';
import '../bloc/order/order_bloc.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
Widget OfficesWidget(
    {required BuildContext context,
    required,
    required List<ShippingEntity> shipping_offices}) {
  Size size = MediaQuery.of(context).size;
  return Padding(
    padding: const EdgeInsets.all(15.0),
    child: Container(
        width: size.width,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5.0,
            spreadRadius: 1.0,
            offset: Offset(0, 2),
          ),
        ], borderRadius: BorderRadius.circular(10), color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Container(
                  width: size.width,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xa6f1f1f1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        FontAwesomeIcons.building,
                        color: Colors.black87,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "${AppLocalizations.of(context)!.translate('our_offices')}",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )),
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: shipping_offices.length,
                  itemBuilder: (context, index) {
                    ShippingEntity office = shipping_offices[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 180,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 1, color: KabaChineColors.border),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${AppLocalizations.of(context)!.translate('collection_office')}"),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.black87,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(office.departure.toString()),
                                ],
                              )
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                height: 1,
                                width: 20,
                                color: Colors.grey),
                            Transform.rotate(
                              angle: 110,
                              child: Icon(
                                Icons.airplanemode_active_outlined,
                                color: Colors.black54,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 180,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 1, color: KabaChineColors.border),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${AppLocalizations.of(context)!.translate('destination_office')}"),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.black87,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(office.destination.toString()),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  })
            ],
          ),
        )),
  );
}

class ExpeditionModes extends StatefulWidget {
  const ExpeditionModes({super.key});

  @override
  State<ExpeditionModes> createState() => _ExpeditionModesState();
}

class _ExpeditionModesState extends State<ExpeditionModes> {

int selectedMode = Tariftype.boat.value;
  @override
  Widget build(BuildContext context) {
Size size = MediaQuery.of(context).size;
return BlocSelector<OrderBloc, OrderState, OrderState>(
selector: (state) {
return state;
},
builder: (context, state) {

if (state is chooseExpeditionModeState) {
selectedMode = state.expeditionMode.value;
}
return Padding(
padding: const EdgeInsets.all(10.0),
child: AnimatedContainer(
duration: Duration(milliseconds: 300),
width: size.width,
decoration: BoxDecoration(boxShadow: [
BoxShadow(
color: Colors.black12,
blurRadius: 5.0,
spreadRadius: 1.0,
offset: Offset(0, 2),
),
], borderRadius: BorderRadius.circular(10), color: Colors.white),
child: Padding(
padding: const EdgeInsets.all(15.0),
child: Column(
children: [
Container(
width: size.width,
height: 40,
decoration: BoxDecoration(
color: Color(0xa6f1f1f1),
borderRadius: BorderRadius.only(
topLeft: Radius.circular(10),
topRight: Radius.circular(10),
),
),
child: Row(
children: [
SizedBox(
width: 10,
),
Icon(
FontAwesomeIcons.building,
color: Colors.black87,
),
SizedBox(
width: 10,
),
Text(
"${AppLocalizations.of(context)!.translate('shipping_method')}",
style: TextStyle(
color: Colors.black87,
fontSize: 14,
fontWeight: FontWeight.bold,
),
),
],
)),
SizedBox(
height: 20,
),
Row(
mainAxisAlignment: MainAxisAlignment.spaceAround,
children: [
GestureDetector(
onTap: () {
context.read<OrderBloc>().add(
chooseExpeditionModeEvent(
expeditionMode: Tariftype.boat));
},
child: Container(
width: 180,
height: 70,
decoration: BoxDecoration(
border: Border.all(
width: 1, color: KabaChineColors.border),
borderRadius: BorderRadius.circular(10),
color: selectedMode == Tariftype.boat.value
? KabaChineColors.info
    : Colors.white,
),
child: Stack(
alignment: Alignment.center,
children: [
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.directions_boat,
color: selectedMode == Tariftype.boat.value
? Colors.white
    : Colors.black87,
),
SizedBox(
width: 5,
),
Text(
"${AppLocalizations.of(context)!.translate('boat')}",
style: TextStyle(
color:
selectedMode == Tariftype.boat.value
? Colors.white
    : Colors.black87,
),
),
],
),
Positioned(
right: 10,
bottom: 5,
child: selectedMode == Tariftype.boat.value
? Row(
mainAxisAlignment:
MainAxisAlignment.end,
children: [
Container(
padding: EdgeInsets.all(2),
decoration: BoxDecoration(
color: KabaChineColors.success,
borderRadius:
BorderRadius.circular(5),
),
child: Text(
"${AppLocalizations.of(context)!.translate('economy')}",
style: TextStyle(
color: Colors.white,
fontSize: 10),
),
)
],
)
    : Container())
],
),
),
),
GestureDetector(
onTap:  () {
context.read<OrderBloc>().add(
chooseExpeditionModeEvent(
expeditionMode: Tariftype.plane));
},
child: Container(
width: 180,
height: 70,
decoration: BoxDecoration(
border: Border.all(
width: 1, color: KabaChineColors.border),
borderRadius: BorderRadius.circular(10),
color: selectedMode == Tariftype.plane.value
? KabaChineColors.info
    : Colors.white,
),
child: Stack(
alignment: Alignment.center,
children: [
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Transform.rotate(
angle: -55,
child: Icon(
Icons.airplanemode_active,
color: selectedMode == Tariftype.plane.value
? Colors.white
    : Colors.black87,
),
),
SizedBox(
width: 5,
),
Text("${AppLocalizations.of(context)!.translate('plane')}",
style: TextStyle(
fontSize: 16,
color:
selectedMode == Tariftype.plane.value
? Colors.white
    : Colors.black87,
)),
],
),
Positioned(
right: 10,
bottom: 5,
child: selectedMode == Tariftype.plane.value
? Row(
mainAxisAlignment:
MainAxisAlignment.end,
children: [
Container(
padding: EdgeInsets.all(4),
decoration: BoxDecoration(
color: KabaChineColors.success,
borderRadius:
BorderRadius.circular(5),
),
child: Text(
"${AppLocalizations.of(context)!.translate('express')}",
style: TextStyle(
color: Colors.white,
fontSize: 10),
),
)
],
)
    : Container())
],
),
),
),
],
)
],
),
)),
);
},
);

  }
}
