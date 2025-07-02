import 'package:KABA/src/microservices/kaba_chine/Enums/TarifType.dart';
import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../domain/tarif/shipping_entity.dart';
import '../../domain/tarif/tarif_entity.dart';

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
                children: [
                  SizedBox(width: 10,),
                  Icon(Icons.money,color: Colors.black87,),
                  SizedBox(width: 10,),
                  Text(
                    "Nos Tarifs d'Expédition",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                    width: 100,
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
          TarifWidget(
              context: context,
              tarif: planeRate
          ),
          SizedBox(height: 10),
          TarifWidget(
            context: context,
            tarif: boatRate
          ),
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
                          child: Icon(tarif.mode==Tariftype.plane.value? Icons.airplanemode_active_outlined:Icons.directions_boat_outlined, color: Colors.white,)),
                      SizedBox(width: 5,),
                      Text(
                        tarif.mode == 0 ? "Bateau" : "Avion",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.black54,size: 14,),
                    Text(
                      "${tarif.duration} jours",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
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
                  "${tarif.price?.toInt()} FCFA ",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('/ ${tarif.mode== Tariftype.plane.value ? "kg" : "cbm"}')
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
                          "Livraison rapide",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
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
                          "Suivi en temps réel",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
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
                      "Tarif économique",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
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
                      "Colis volumineux acceptés",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        )
    ),
  );
}