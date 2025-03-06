import 'dart:io';

import 'package:KABA/src/state_management/out_of_app_order/products_state.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../localizations/AppLocalizations.dart';
import '../../models/CustomerModel.dart';
import '../../models/DeliveryAddressModel.dart';
import '../../resources/out_of_app_order_api.dart';
import '../../state_management/out_of_app_order/additionnal_info_state.dart';
import '../../state_management/out_of_app_order/location_state.dart';
import '../../state_management/out_of_app_order/order_billing_state.dart';
import '../../state_management/out_of_app_order/out_of_app_order_screen_state.dart';
import '../../state_management/out_of_app_order/voucher_state.dart';
import '../../utils/functions/OutOfAppOrder/imagePicker.dart';
import 'BouncingWidget.dart';
import 'package:image_picker/image_picker.dart';
Widget OutOfAppProductForm(BuildContext context){
  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  Size size = MediaQuery.of(context).size;

  File imagePath=null;
  final _formKey = GlobalKey<FormState>();
  return Container(
    width: size.width,
    height: 300,
    decoration: BoxDecoration(
        color: Color(0x42d2d2d2),
        borderRadius: BorderRadius.circular(5)
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer(
  builder: (context, ref,child) {
    final imageCache = ref.watch(imageCacheProvider);
    final outOfAppScreenState = ref.watch(outOfAppScreenStateProvier);

    return GestureDetector(

              onTap:outOfAppScreenState.showLoading==false? ()async{
                try{
                  await pickImage(context,ref).then((value){
                    ref.read(imageCacheProvider.notifier).state = value;
                    imagePath = ref.watch(imageCacheProvider.notifier).state;
                  });

                }catch(e){
                  print("##Error in image picking, out of app order## $e");
                }
              }:null,
              child: Container(
                height: 100,
                width: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Color(0x64d2d2d2),
                    borderRadius: BorderRadius.circular(5),
                    image: imagePath!=null? DecorationImage(
                        image: FileImage(imagePath),
                      fit: BoxFit.cover
                    ):null,
                ),
                child: imagePath==null?
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BouncingWidget(
                    duration: Duration(milliseconds: 400),
                    scaleFactor: 2,
                    child: Icon(Icons.camera_alt,   color: Color(0x868A8A8A),)),
                    SizedBox(height: 5,),
                    Text("${AppLocalizations.of(context).translate('choose_an_image')}",
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey)),

                  ],
                )
                    :Container(),
              ),
            );
  },
),
            Container(
              width: size.width*.5,
              alignment: Alignment.center,
              child:
              Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    validator: (value){
                      if(value.isEmpty){
                        return "Entrez le nom du produit";
                      }
                    },
                    decoration: InputDecoration(
                        labelText:"${AppLocalizations.of(context).translate('product_name')}"),
                        style: TextStyle(fontSize: 13),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: "${AppLocalizations.of(context).translate('product_price')}"),
                         style: TextStyle(fontSize: 13),
                    validator: (value){
                    if(value.isEmpty)
                    return "Entrez le prix du produit.";
                    else if(int.parse(value)<=0){
                      return "Le prix ne peut pas être zero.";
                    }
                    }
                  ),
                  SizedBox(height: 10),
                  Consumer(
                    builder: (context, ref,child) {
                      final quantity = ref.watch(quantityProvider);
                      final quantityNotifier = ref.read(quantityProvider.notifier);
                      final products = ref.watch(productListProvider);
                      final outOfAppScreenState = ref.watch(outOfAppScreenStateProvier);
                      final orderBillingState = ref.watch(orderBillingStateProvider);
                      final orderBillingNotifier = ref.read(orderBillingStateProvider.notifier);
                      final locationState = ref.watch(locationStateProvider);
                      final voucherState = ref.watch(voucherStateProvider);
                      final outOfAppNotifier =ref.read(outOfAppScreenStateProvier.notifier);

                      return outOfAppScreenState.showLoading==false?
                      Column(
                    children: [
                      Row(
                        children: [
                          Text("${AppLocalizations.of(context).translate('quantity')}:",
                          style: TextStyle(
                            fontSize: 13
                          ),
                          ),
                          SizedBox(width: 10,),
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                color: Color(0xfff0dbe1),
                                borderRadius: BorderRadius.circular(100),
                            ),
                            child: IconButton(
                              onPressed:(){
                                quantityNotifier.decrease();
                                print("decrease");
                              },
                              icon: Icon(Icons.remove,color: KColors.primaryColor,),
                            ),
                          ),

                          SizedBox(
                            width: 50,
                            child: Center(
                              child: Text(
                                quantity.toString(), 
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                          ),
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Color(0xfff0dbe1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: IconButton(
                              onPressed: (){
                                quantityNotifier.increase();
                                print("increase $quantity");
                                },
                              icon: Icon(Icons.add,color: KColors.primaryColor,),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      InkWell(
                        onTap: (){
                          if (_formKey.currentState.validate()) {
                            final product ={
                              "name":_nameController.text,
                              "price":int.parse(_priceController.text),
                              "quantity":int.parse(quantity.toString()),
                              "image":imagePath
                            };

                            print("product $product");
                            ref.read(productListProvider.notifier).addProduct(product);
                            quantityNotifier.reset();
                            ref.read(imageCacheProvider.notifier).saveImagePath(null);
                            _nameController.text="";
                            _priceController.text="";
                            imagePath=null;
                          }
                        },
                        child:  Container(
                            decoration: BoxDecoration(
                                color: KColors.primaryColor,
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child:Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text("${AppLocalizations.of(context).translate('add_product')}"
                                  ,style:TextStyle(color: Colors.white)
                              ),
                            )
                        ),
                      ),
                      SizedBox(height: 10),
                      InkWell(
                        onTap: ()async{

                              if(locationState.is_shipping_address_picked){
                                var foods = ref.watch(productListProvider);
                                List<Map<String, dynamic>> formData = [];

                                for (int i = 0; i < foods.length; i++) {
                                  formData.add(
                                      { 'name': foods[i]['name'],
                                        'price': foods[i]['price'].toString(),
                                        'quantity': foods[i]['quantity'].toString(),
                                        'image': ""
                                      }
                                  );
                                }
                                OutOfAppOrderApiProvider api = OutOfAppOrderApiProvider();
                                CustomerModel customer =orderBillingState.customer;
                                List<DeliveryAddressModel> order_address = locationState.selectedOrderAddress;
                                DeliveryAddressModel shipping_adress =  locationState.selectedShippingAddress;
                                var _selectedVoucher =voucherState.selectedVoucher;
                                var _usePoint = voucherState.usePoint;
                                outOfAppNotifier.setIsBillBuilt(false);
                                outOfAppNotifier.setShowLoading(true);
                                await api.computeBillingAction(customer, order_address, formData, shipping_adress, _selectedVoucher, _usePoint).then((value){
                                  ref.read(orderBillingStateProvider.notifier).setOrderBillConfiguration(value);
                                  outOfAppNotifier .setIsBillBuilt(true);
                                  outOfAppNotifier.setShowLoading(false);
                                });
                              }else{
                                orderBillingNotifier.setOrderBillConfiguration(null);
                              }
                              Navigator.pop(context);

                        },
                        child:
                        Container(
                            decoration: BoxDecoration(
                                color: Color(0xffeaa243),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child:Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text("${AppLocalizations.of(context).translate('finalize')}"
                                  ,style:TextStyle(color: Colors.white)
                              ),
                            )
                        ),
                      ),
                    ],
                  ):Container(
                        height: 60,
                        alignment: Alignment.center,
                    width: size.width,
                    child: Container(
                          height: 40,width: 40,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),),
                  );
                },
              ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
);
}

Widget PackageAmountForm(BuildContext context) {
  TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  return Consumer(
    builder: (context, ref, child) {
      final products = ref.watch(productListProvider);
      final outOfAppScreenState = ref.watch(outOfAppScreenStateProvier);
      final productsNotifier = ref.read(productListProvider.notifier);
      
      final existingPackage = products.where((p) => 
        p['name'] == (outOfAppScreenState.order_type == 5 ? "shipping_package" : "fetch_package")
      ).toList();
      
      if (existingPackage.isNotEmpty) {
        _amountController.text = existingPackage.first['price'].toString();
      }

      return Padding(
        padding: const EdgeInsets.all(0.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0x42d2d2d2),
                  borderRadius: BorderRadius.circular(5)
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: "${AppLocalizations.of(context).translate('package_amount')}", 
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "${AppLocalizations.of(context).translate('please_enter_amount')}"; 
                      }
                      if (double.tryParse(value) == null) {
                        return "${AppLocalizations.of(context).translate('please_enter_valid_amount')}";
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              BouncingWidget(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    final amount = double.parse(_amountController.text);
                    final packageType = outOfAppScreenState.order_type == 5 ? "shipping_package" : "fetch_package";
                    
                    if (existingPackage.isEmpty) {
                   
                      productsNotifier.addProduct(
                        {
                          'name': packageType,
                          'price': amount,
                          'quantity': 1,
                          'image': null
                        }
                      );
                    } else {
                      existingPackage.first['price'] = amount;
                      productsNotifier.modifyProduct(
                          existingPackage.first
                      );
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: KColors.primaryColor,
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      existingPackage.isEmpty ? "${AppLocalizations.of(context).translate('validate')}" : "${AppLocalizations.of(context).translate('modify')}",
                      style: TextStyle(color: Colors.white)
                    ),
                  )
                ),
              )
            ],
          ),
        ),
      );
    }
  );
}
