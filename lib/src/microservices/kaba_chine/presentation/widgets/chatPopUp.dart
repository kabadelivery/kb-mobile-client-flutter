import 'package:flutter/material.dart';

import '../../Enums/deliveryStatus.dart';
import '../../core/utils.dart';
import '../../data/order/delivery_model.dart';
import '../../functions/getStatusInfo.dart';

void startChatPopUp({required BuildContext context,required List<Delivery> deliveries}) {

  showDialog(context: context,

      builder:(BuildContext context){

          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Nouvelle conversation",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.close,
                          color: Colors.black87,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text("A propos de quelle lignes souhaitez-vous discuter ?",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: deliveries.isEmpty ? 1 : deliveries.length,
                      itemBuilder: (context, index) {

                        if(deliveries.isEmpty){
                          return Center(
                            child: Text(
                              "Aucune livraison trouvée",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }else{
                          final info = getStatusInfo(DeliveryStatus.values.firstWhere(
                                (e) => e.value == deliveries[index].status,
                            orElse: () => DeliveryStatus.pending,
                          ));
                          return MaterialButton(
                            padding: EdgeInsets.zero,
                            minWidth: MediaQuery.of(context).size.width,

                            onPressed: () {

                            },
                            color: Colors.white,
                            child:Container(
                              padding: EdgeInsets.symmetric(horizontal: 0,vertical: 10),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border(bottom: BorderSide(color: KabaChineColors.border, width: 1))
                              ),
                              child:  Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        info.text,
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "${deliveries[index].packageName}",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                          "${deliveries[index].createdAt!.day}/${deliveries[index].createdAt!.month}/${deliveries[index].createdAt!.year}",
                                          style: TextStyle(
                                              color: Colors.grey)),
                                    ],
                                  ),
                                  Icon(Icons.arrow_forward_ios,
                                    color: Colors.black54,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                      },
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width ,
                    height: 60,
                    child: MaterialButton(
                      onPressed: () {

                      },
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      color: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      child: Center(
                        child: Text(
                          'Demande générale',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
      });
}