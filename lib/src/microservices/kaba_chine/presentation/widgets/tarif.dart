import 'package:KABA/src/microservices/kaba_chine/Enums/TarifType.dart';
import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/tarif/shipping_entity.dart';
import '../../domain/tarif/tarif_entity.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';

import '../../functions/checkInfos.dart';
import '../bloc/information/information_bloc.dart';
Widget tarifExpeditionWidget({required BuildContext context,required ShippingEntity shipping,required TarifEntity boatRate,required TarifEntity planeRate}) {
  Size size = MediaQuery.of(context).size;
  return Padding(
    padding: const EdgeInsets.all(15.0),
    child:  Container(
      width: size.width,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5.0,
              spreadRadius: 1.0,
              offset: Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
          color: Colors.white
      ),
      child: Column(
        children: [
          Container(
              width: size.width,
              height: 30,
              decoration: BoxDecoration(
                color:  Color(0xa6f1f1f1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 10,),
                      Icon(Icons.money,color: Colors.black87,),
                      SizedBox(width: 10,),
                      Text(
                        "${AppLocalizations.of(context)!.translate('our_shipping_rates')}",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                IconButton(onPressed: (){
                  BlocProvider.of<InformationBloc>(context).add(getInfosEvent());
                  CherryToast.info(
                    toastPosition: Position.center,
                    toastDuration:
                    Duration(seconds: 5),
                    title: Text("${AppLocalizations.of(context)!.translate('shipping_rates_updating')}"),

                  ).show(context);
                }, icon:Icon(Icons.refresh, color: Colors.black54, size: 16,),)
                ],
              )
          ),

          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                  width: 100,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0x61dadada),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text("${shipping.departure}")
              ),

              Row(
                children: [
                  Container(
                    width:50,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Color(0x61dadada),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  Icon(Icons.circle,size: 14,color: KabaChineColors.primary),
                  SizedBox(width: 10,),
                  Icon(Icons.circle,size: 14,color: KabaChineColors.primary),
                  SizedBox(width: 10,),
                  Icon(Icons.circle,size: 14,color: KabaChineColors.primary),
                ],
              ),

              Container(
                  width: 100,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0x61dadada),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text("${shipping.destination}")
              ),
            ],
          ),
          SizedBox(height: 20,),
          planeRate.isActive!?TarifWidget(
              context: context,
              tarif: planeRate
          ):SizedBox(),
          SizedBox(height: 10),
         boatRate.isActive!? TarifWidget(
            context: context,
            tarif: boatRate
          ): SizedBox(),
          SizedBox(height: 20),

        ],
      ),
    ),
  );

}

TarifWidget({required BuildContext context, required TarifEntity tarif}) {
  Size size = MediaQuery.of(context).size;
  return Container(
    width: size.width*.85,
    decoration: BoxDecoration(
      color:  Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 5.0,
          spreadRadius: 1.0,
          offset: Offset(0, 2),
        ),
      ],
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                  decoration: BoxDecoration(
                    color: tarif.mode==Tariftype.plane.value? Colors.blueAccent:
                    Color(0xff28A2B5),

                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [
                      Transform.rotate(
                          angle: tarif.mode==Tariftype.plane.value? 120:0,
                          child: Icon(tarif.mode==Tariftype.plane.value? Icons.airplanemode_active_outlined:Icons.directions_boat_outlined, color: Colors.white,size:15,)),
                      SizedBox(width: 5,),
                      Text(
                        tarif.mode == 0 ? "${AppLocalizations.of(context)!.translate('boat')}" : "${AppLocalizations.of(context)!.translate('plane')}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.black54,size: 14,),
                    Text("${tarif.mode== Tariftype.plane.value ? "15" : "40"} ${AppLocalizations.of(context)!.translate('to')} ${tarif.mode== Tariftype.plane.value ? "25" : "60"} ${AppLocalizations.of(context)!.translate('days')}",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

              ],
            ),
            SizedBox(height: 5,),
            Row(
              children: [
                
                Text(
                  "${tarif.mode==Tariftype.boat.value?"240.000":tarif.price?.toInt()} FCFA ",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('/ ${tarif.mode== Tariftype.plane.value ? "kg" : "m3/Cbm"}')
              ],
            ),

            SizedBox(height: 5,),
            tarif.mode== Tariftype.plane.value
                ? Row(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: KabaChineColors.success, size: 16,),
                        SizedBox(width: 5,),
                        Text(
                          "${AppLocalizations.of(context)!.translate('fast_delivery')}",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 10,),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: KabaChineColors.success, size: 16,),
                        SizedBox(width: 5,),
                        Text(
                          "${AppLocalizations.of(context)!.translate('real_time_tracking')}",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
            ): Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: KabaChineColors.success, size: 16,),
                    SizedBox(width: 5,),
                    Text(
                      "${AppLocalizations.of(context)!.translate('economy_rate')}",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize:10,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 10,),
                Row(
                  children: [
                    Icon(Icons.check_circle, color: KabaChineColors.success, size: 16,),
                    SizedBox(width: 5,),
                    Text(
                     "${AppLocalizations.of(context)!.translate('large_packages_accepted')}",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize:12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 5,),
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: KabaChineColors.primary,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                child: GestureDetector(
                  onTap: (){
                    showShippingCostPopup(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.ads_click, color: Colors.white,size: 16,),
                      SizedBox(width: 5,),
                      Text("${AppLocalizations.of(context)!.translate('calculate_shipping_cost')}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
    ),
  );
}