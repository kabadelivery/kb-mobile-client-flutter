import 'dart:async';

import 'package:KABA/src/microservices/kaba_chine/presentation/bloc/order/order_bloc.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import '../../../../contracts/topup_contract.dart';
import '../../../../ui/screens/home/me/money/TopNewUpPage.dart';
import '../../../../utils/Enums/type_of_transaction.dart';
import '../../Enums/TarifType.dart';
import '../../Enums/deliveryStatus.dart';
import '../../core/utils.dart';
import '../../data/order/data_remote_source.dart';
import '../../data/order/delivery_model.dart';
import '../../data/order/payment_model.dart';
import '../../domain/order/repository.dart';
import '../../functions/getStatusInfo.dart';
import '../../functions/payment_code_msg.dart';
import '../../usecases/order/getPaymentInfo.dart';
import '../pages/delivery_details.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
Widget PackageDeliveryWidget(
    {required BuildContext context, required Delivery delivery})
{
  Size size = MediaQuery.of(context).size;
  final info = getStatusInfo(context,DeliveryStatus.values.firstWhere(
      (e) => e.value == delivery.status,
      orElse: () => DeliveryStatus.pending,
    ));
  return Container(
    width: size.width,
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 5.0,
          spreadRadius: 1.0,
          offset: Offset(0, 2), // changes position of shadow
        ),
      ],
      borderRadius: BorderRadius.circular(10),
      border: info.actionRequired==null &&delivery.status!=DeliveryStatus.cancelled.value?null: Border(
        left: BorderSide(
          color: info.color,
          width: 5,
        ),
      ),
    ),
    child: MaterialButton(
      onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PackageDeliveryDetailsWidget(
                delivery: delivery,
              ),
            ),
          );
      },
      padding: EdgeInsets.all(0),
      highlightColor: info.color.withOpacity(0.1),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),

      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
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
                  FontAwesomeIcons.box,
                  color: Colors.black54,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "${AppLocalizations.of(context)!.translate('shipping').toUpperCase()} ${delivery.trackingCode}",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${delivery.packageName}",
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: info.color.withOpacity(0.2),
                  border: info.actionRequired==null?null: Border.all(
                    color: info.color,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(info.icon, color: info.color, size: 16),
                    SizedBox(width: 5),
                    Text(info.text,
                        style: TextStyle(
                            color: info.color,
                            fontSize: 12,
                            fontWeight: FontWeight.normal)),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(FontAwesomeIcons.barcode,
                  color: Colors.black54, size: 16),
              Text(delivery.trackingCode??"",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.normal)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              Row(
                children: [
                  Icon(delivery.shippingMode==Tariftype.plane.value?FontAwesomeIcons.plane:Icons.directions_boat,color: Colors.black54,size: 20),
                  SizedBox(width: 5),
                  Text(delivery.shippingMode==Tariftype.plane.value?"${AppLocalizations.of(context)!.translate('plane')}":"${AppLocalizations.of(context)!.translate('boat')}",
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.normal)),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.calendar_month_rounded,
                      color: Colors.black54, size: 20),
                  SizedBox(width: 5),
                  Text(
                    "${delivery.createdAt!.day}/${delivery.createdAt!.month<10?"0"+delivery.createdAt!.month.toString():delivery.createdAt!.month}/${delivery.createdAt!.year}",
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ),
                ],
              )
            ]
          ),
          SizedBox(height: 10),
          if (info.actionRequired != null || delivery.status == DeliveryStatus.cancelled.value)
            Container(
              width: size.width,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: info.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: info.color,
                    size: 16,
                  ),
                  SizedBox(width: 5),
                  Text(
                    delivery.status == DeliveryStatus.cancelled.value?"${delivery.cancellationReason}":info.actionRequired!,
                    style: TextStyle(
                        color: info.color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          SizedBox(height: 10),
          if (delivery.status != DeliveryStatus.outForDelivery.value && delivery.status != DeliveryStatus.delivered.value && delivery.status != DeliveryStatus.cancelled.value)
            BlocSelector<OrderBloc,OrderState,OrderState>(selector: (state){
              return state;
            }, builder: (context, state) {

              return Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if(state is getDeliveryPaymentInfoState && state.paymentInfo!=null)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(delivery.shippingMode==Tariftype.plane.value?FontAwesomeIcons.plane:Icons.directions_boat_outlined,color: Colors.black54,size: 15),
                                SizedBox(width: 5),
                                Text("${AppLocalizations.of(context)!.translate('shipping_price').toLowerCase()} : ",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal)
                                ),
                              ],
                            ),
                            Text("${state.paymentInfo.shippingFee} FCFA",
                                style:   TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,

                                )
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Row(
                              children: [
                                Icon(Icons.payments_outlined,color: Colors.black54,size: 15),
                                SizedBox(width: 5),
                                Text("${AppLocalizations.of(context)!.translate('payment_info')} : ",
                                style:
                                TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal)
                                ),
                              ],
                            ),
                            Text("${state.paymentInfo.minPercent} % (${((state.paymentInfo.minPercent*state.paymentInfo.shippingFee)/100).toStringAsFixed(2)}) FCFA",
                                style:   TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,

                                )
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Row(
                              children: [
                                Icon(Icons.attach_money_outlined,color: Colors.black54,size: 15),
                                SizedBox(width: 5),
                                Text(
                                  "${AppLocalizations.of(context)!.translate('already_payed')} : ",
                                  style:
                                  TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal)
                                ),
                              ],
                            ),
                            Text(
                              "${state.paymentInfo.totalPaid} FCFA",
                                style:   TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,

                                )
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Row(
                              children: [
                                Icon(Icons.attach_money_outlined,color: Colors.black54,size: 15),
                                SizedBox(width: 5),
                                Text(
                                  "${AppLocalizations.of(context)!.translate('remaining_to_pay')} : ",
                                  style:  TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal
                                ),
                                ),
                              ],
                            ),
                            Text(
                              "${state.paymentInfo.remaining} FCFA",
                              style:   TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,

                              )
                            ),
                          ],
                        )
                      ]
                    )
                    else Container(),
                    MaterialButton(

                      color:  state is getDeliveryPaymentInfoState && state.paymentInfo!=null? KabaChineColors.info:
                      Color(0x62818181),
                      elevation: 0,
                      minWidth: 120,
                      height: 40,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      onPressed: () async{
                        Map? results = null;
                        BlocProvider.of<OrderBloc>(context).add(getDeliveryPaymentInfo(deliveryId: delivery.id));
                        late Timer _timer;
                        _timer = Timer.periodic(Duration(seconds: 15), (timer) {
                          BlocProvider.of<OrderBloc>(context).add(getDeliveryPaymentInfo(deliveryId: delivery.id));
                          debugPrint("XXX timer shipping price");
                        });

                        if(state is getDeliveryPaymentInfoState && state.paymentInfo!=null){
                        results = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TopNewUpPage(presenter: TopUpPresenter(TopUpView()),transactionType: TransactionType.kaba_chine,additionnal_infos: {'delivery_id':delivery.id}),
                          ),
                        );
                        }
                        if (results!=null) {
                          if (results["success"]) {
                            CherryToast.success(
                              title: Text("${AppLocalizations.of(context)!.translate('payment_successful')}"),
                              toastPosition: Position.center,
                            ).show(context);
                          }else{
                            String msg = paymentStateMessage(context: context,code: results['code']);
                            CherryToast.error(
                              title: Text(msg),
                              toastPosition: Position.center,
                            ).show(context);
                          }
                        }
                        else{
                          CherryToast.warning(
                            title: Text("${AppLocalizations.of(context)!.translate('give_us_a_second')}"),
                            toastPosition: Position.center,
                          ).show(context);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.credit_card, color: Colors.white),
                          Text(
                            state is getDeliveryPaymentInfoState && state.paymentInfo!=null?"${AppLocalizations.of(context)!.translate('pay_now')}":"${AppLocalizations.of(context)!.translate('init_payment')}",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ]),
      ),
    ),
  );
}
