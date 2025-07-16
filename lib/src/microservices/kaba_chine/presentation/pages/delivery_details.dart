import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:KABA/src/microservices/kaba_chine/data/order/delivery_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import '../../Enums/TarifType.dart';
import '../../Enums/deliveryStatus.dart';
import '../../functions/getStatusInfo.dart';
import '../widgets/transaction.dart';

class PackageDeliveryDetailsWidget extends StatefulWidget {
  final Delivery delivery;
  const PackageDeliveryDetailsWidget({super.key, required this.delivery});

  @override
  State<PackageDeliveryDetailsWidget> createState() => _PackageDeliveryDetailsWidgetState();
}

class _PackageDeliveryDetailsWidgetState extends State<PackageDeliveryDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    final info = getStatusInfo(context,DeliveryStatus.values.firstWhere(
      (e) => e.value == widget.delivery.status,
      orElse: () => DeliveryStatus.pending,
    ));
    Size size = MediaQuery.of(context).size;
    List<Map<String,dynamic>> fake_transactions = [
      {
        "id": "123456789",
        'user_id': "123456789",
        'amount': 10000,
        'currency': 'FCFA',
        'created_date':DateTime.now(),
        'type_of_transaction':"FLOOZ"
      },
      {
        "id": "123456789",
        'user_id': "123456789",
        'amount': 10000,
        'currency': 'FCFA',
        'created_date':DateTime.now(),
        'type_of_transaction':"MIXX BY YAS"
      }
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: KabaChineColors.primary,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          }),
        title: Text("${AppLocalizations.of(context)!.translate('parcel')}",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.delivery.packageName??"",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87.withOpacity(0.7),
                    )),
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
              Container(
                width: size.width,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: info.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(info.icon, color: info.color, size: 20),
                    SizedBox(width: 5),
                    Text(info.text,
                        style: TextStyle(
                            color: info.color,
                            fontSize: 16,
                            fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: size.width*0.95,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5.0,
                      spreadRadius: 1.0,
                      offset: Offset(0, 2),
                    ),
                  ],
              ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${AppLocalizations.of(context)!.translate('general_information')}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87.withOpacity(0.7),
                        )),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${AppLocalizations.of(context)!.translate('tracking_code')}",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            )),
                          Text(widget.delivery.trackingCode!,
                            style: TextStyle(
                              color: Colors.black87.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            )),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${AppLocalizations.of(context)!.translate('creation_date')}",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            )),
                          Text(widget.delivery.createdAt!.toLocal().toString().split(' ')[0]+" à "+widget.delivery.createdAt!.toLocal().toString().split(' ')[1].split('.')[0],
                            style: TextStyle(
                              color: Colors.black87.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            )),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${AppLocalizations.of(context)!.translate('last_update')}",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ))
                          ,
                          Text(widget.delivery.updatedAt!.toLocal().toString().split(' ')[0]+" à "+widget.delivery.updatedAt!.toLocal().toString().split(' ')[1].split('.')[0],
                            style: TextStyle(
                              color: Colors.black87.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            )),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${AppLocalizations.of(context)!.translate('shipping_method')}",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            )),
                          Row(
                            children: [
                              SizedBox(width: 5),
                              Icon(widget.delivery.shippingMode == Tariftype.plane.value ? Icons.airplanemode_active : Icons.directions_boat,
                                color: Colors.black87.withOpacity(0.7), size: 16),
                              SizedBox(width: 5),
                              Text(widget.delivery.shippingMode == Tariftype.plane.value ?"${AppLocalizations.of(context)!.translate('plane')}": "${AppLocalizations.of(context)!.translate('boat')}",
                                style: TextStyle(
                                  color: Colors.black87.withOpacity(0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                )),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                  width: size.width*0.95,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5.0,
                  spreadRadius: 1.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child:Padding(
              padding: const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${AppLocalizations.of(context)!.translate('parcel_details')}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87.withOpacity(0.7),
                    )),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${AppLocalizations.of(context)!.translate('declared_value')}",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        )),
                       Text("${widget.delivery.declaredValue} FCFA",
                        style: TextStyle(
                          color: Colors.black87.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${AppLocalizations.of(context)!.translate('estimated_weight')}",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          )),
                      Text("${widget.delivery.estimatedWeight} kg",
                          style: TextStyle(
                            color: Colors.black87.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            )

          ),
              SizedBox(height: 20),
              Container(
                  width: size.width*0.95,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5.0,
                        spreadRadius: 1.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child:Padding(
                    padding: const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${AppLocalizations.of(context)!.translate('address_and_destination')}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87.withOpacity(0.7),
                            )),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${AppLocalizations.of(context)!.translate('collection_office')}",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                )),
                            Text("${widget.delivery.collectionOffice}",
                                style: TextStyle(
                                  color: Colors.black87.withOpacity(0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${AppLocalizations.of(context)!.translate('destination_office')}",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                )),
                            Text("${widget.delivery.destinationOffice}",
                                style: TextStyle(
                                  color: Colors.black87.withOpacity(0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${AppLocalizations.of(context)!.translate('delivery_method')}",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                )),
                            Text("${widget.delivery.homeDelivery!?"${AppLocalizations.of(context)!.translate('home_delivery')}":"${AppLocalizations.of(context)!.translate('pickup_at_office')}"}",
                                style: TextStyle(
                                  color: Colors.black87.withOpacity(0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${AppLocalizations.of(context)!.translate('delivery_address')}",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                )),
                            Text("${widget.delivery.addressText=="null"?"${AppLocalizations.of(context)!.translate('none')}":widget.delivery.addressText}",
                                style: TextStyle(
                                  color: Colors.black87.withOpacity(0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  )

              ),
              SizedBox(height: 20),
              Container(
                  width: size.width*0.95,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5.0,
                        spreadRadius: 1.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child:Padding(
                    padding: const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${AppLocalizations.of(context)!.translate('recipient')}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87.withOpacity(0.7),
                            )),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${AppLocalizations.of(context)!.translate('recipient_name')}",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                )),
                            Text("${widget.delivery.recipientName}",
                                style: TextStyle(
                                  color: Colors.black87.withOpacity(0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${AppLocalizations.of(context)!.translate('recipient_phone')}",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                )),
                            Text("${widget.delivery.buyerPhoneNumber}",
                                style: TextStyle(
                                  color: Colors.black87.withOpacity(0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  )

              ),
              SizedBox(height: 20),
              widget.delivery.notes!=null&& widget.delivery.notes!.isNotEmpty?
              Container(
                  width: size.width*0.95,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5.0,
                        spreadRadius: 1.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child:Padding(
                    padding: const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${AppLocalizations.of(context)!.translate('notes')}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87.withOpacity(0.7),
                            )),
                        SizedBox(height: 10),
                        Text("${widget.delivery.notes}",
                          style: TextStyle(
                            color: Colors.black87.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          )),
                      ],
                    ),
                  )

              ):Container(),
              widget.delivery.notes!=null&& widget.delivery.notes!.isNotEmpty?
              SizedBox(height: 20):Container(),

              Container(
                width: size.width,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:  KabaChineColors.info.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(info.icon, color:  KabaChineColors.info, size: 20),
                    SizedBox(width: 5),
                    Text("${AppLocalizations.of(context)!.translate('your_transactions')}",
                        style: TextStyle(
                            color: KabaChineColors.info,
                            fontSize: 16,
                            fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              widget.delivery.payments==null||widget.delivery.payments!.isEmpty?
                  Text("${AppLocalizations.of(context)!.translate('no_transactions_found')}"):
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.delivery.payments!.length,
                    itemBuilder: (context, index) {
                      Map<String,dynamic> transaction = widget.delivery.payments![index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Transaction(context: context,transaction: transaction),
                      );
                    }
                  ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: fake_transactions.length,
                  itemBuilder: (context, index) {
                    Map<String,dynamic> transaction = fake_transactions[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Transaction(context: context,transaction: transaction),
                    );
                  }
              ),
            ],
          ),
        ),
      )
    );
  }
}
