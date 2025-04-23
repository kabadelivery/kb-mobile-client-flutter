import 'dart:async';
import 'dart:io';

import 'package:KABA/src/state_management/out_of_app_order/products_state.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../localizations/AppLocalizations.dart';
import '../../models/CustomerModel.dart';
import '../../models/DeliveryAddressModel.dart';
import '../../models/OrderBillConfiguration.dart';
import '../../resources/out_of_app_order_api.dart';
import '../../state_management/out_of_app_order/additionnal_info_state.dart';
import '../../state_management/out_of_app_order/location_state.dart';
import '../../state_management/out_of_app_order/order_billing_state.dart';
import '../../state_management/out_of_app_order/out_of_app_order_screen_state.dart';
import '../../state_management/out_of_app_order/voucher_state.dart';
import '../../utils/functions/CustomerUtils.dart';
import '../../utils/functions/OutOfAppOrder/imagePicker.dart';
import 'package:image_picker/image_picker.dart';

import '../../xrint.dart';

class OutOfAppProductForm extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _priceController = TextEditingController();
    _priceController.text = "0";
    final Size size = MediaQuery.of(context).size;
    final FocusNode _nameFocusNode = FocusNode();
    final FocusNode _priceFocusNode = FocusNode();
    var imagePath;
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return Container(
      width: size.width,
      height: 440,
      decoration: BoxDecoration(
        color: Color(0x42d2d2d2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Consumer(
              builder: (context, ref, child) {
                final imageCache = ref.watch(imageCacheProvider);
                final outOfAppScreenState = ref.watch(outOfAppScreenStateProvier);

                return GestureDetector(
                  onTap: outOfAppScreenState.showLoading == false
                      ? () async {
                    try {
                      await pickImage(context, ref).then((value) {
                        ref.read(imageCacheProvider.notifier).state = value;
                        imagePath = ref.watch(imageCacheProvider.notifier).state!;
                      });
                    } catch (e) {
                      print("##Error in image picking, out of app order## $e");
                    }
                  }
                      : null,
                  child: Container(
                    height: 100,
                    width: size.width,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0x64d2d2d2),
                      borderRadius: BorderRadius.circular(5),
                      image: imagePath != null
                          ? DecorationImage(
                        image: FileImage(imagePath),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: imagePath == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BouncingWidget(
                          duration: Duration(milliseconds: 400),
                          scaleFactor: 2,
                          onPressed: () {  },
                          child: Icon(
                            Icons.camera_alt,
                            color: Color(0x868A8A8A),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "${AppLocalizations.of(context)!.translate('choose_an_image')}",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                        : Container(),
                  ),
                );
              },
            ),
            Form(
              key: _formKey,
              child: Container(
                width: size.width,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    TextFormField(
                      focusNode: _nameFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      controller: _nameController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "${AppLocalizations.of(context)!.translate('enter_product_name')}";
                        }
                        if (value!.length>30) {
                          return "${AppLocalizations.of(context)!.translate('name_too_long')}";
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "${AppLocalizations.of(context)!.translate('product_name')}",
                      ),
                      style: TextStyle(fontSize: 13),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).unfocus();
                      },
                      focusNode: _priceFocusNode,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "${AppLocalizations.of(context)!.translate('product_price')}",
                      ),
                      style: TextStyle(fontSize: 13),
                      validator: (value) {
                         if (value!.isEmpty) {
                          return "${AppLocalizations.of(context)!.translate('please_enter_valid_amount')}";
                        }else if (int.parse(value) < 0 ){
                           return "${AppLocalizations.of(context)!.translate('please_enter_valid_amount')}";

                         } else if(int.parse(value) >100000) {
                          return "${AppLocalizations.of(context)!.translate('price_too_high')}";
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    Consumer(
                      builder: (context, ref, child) {
                        final quantity = ref.watch(quantityProvider);
                        final quantityNotifier = ref.read(quantityProvider.notifier);
                        final products = ref.watch(productListProvider);
                        final outOfAppScreenState = ref.watch(outOfAppScreenStateProvier);
                        final orderBillingState = ref.watch(orderBillingStateProvider);
                        final orderBillingNotifier = ref.read(orderBillingStateProvider.notifier);
                        final locationState = ref.watch(locationStateProvider);
                        final voucherState = ref.watch(voucherStateProvider);
                        final outOfAppNotifier = ref.read(outOfAppScreenStateProvier.notifier);
                        return outOfAppScreenState.showLoading == false
                            ? Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "${AppLocalizations.of(context)!.translate('quantity')}:",
                                  style: TextStyle(fontSize: 13),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: Color(0xfff0dbe1),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      quantityNotifier.decrease();
                                      print("decrease");
                                    },
                                    icon: Icon(
                                      Icons.remove,
                                      color: KColors.primaryColor,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 50,
                                  child: Center(
                                    child: Text(
                                      quantity.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
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
                                    onPressed: () {
                                      quantityNotifier.increase();
                                      print("increase $quantity");
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      color: KColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            InkWell(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {

                                  final product = {
                                    "name": _nameController.text,
                                    "price": int.parse(_priceController.text.isEmpty ? "0" : _priceController.text),
                                    "quantity": int.parse(quantity.toString()),
                                    "image": imagePath,
                                  };

                                  print("product $product");
                                  ref.read(productListProvider.notifier).addProduct(product);
                                  quantityNotifier.reset();
                                  ref.read(imageCacheProvider.notifier).saveImagePath(null);
                                  _nameController.text = "";
                                  _priceController.text = "";
                                  imagePath = null;
                                  _priceFocusNode.previousFocus();
                                }

                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: KColors.primaryColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    "${AppLocalizations.of(context)!.translate('add_product')}",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            products.length > 0
                                ? InkWell(
                              onTap: () async {
                                if (locationState.is_shipping_address_picked!) {
                                  var foods = ref.watch(productListProvider);
                                  List<Map<String, dynamic>> formData = [];

                                  for (int i = 0; i < foods.length; i++) {
                                    formData.add({
                                      'name': foods[i]['name'],
                                      'price': foods[i]['price'].toString(),
                                      'quantity': foods[i]['quantity'].toString(),
                                      'image': ""
                                    });
                                  }
                                  OutOfAppOrderApiProvider api = OutOfAppOrderApiProvider();
                                  CustomerModel customer = orderBillingState.customer!;
                                  List<DeliveryAddressModel> order_address = locationState.selectedOrderAddress!;
                                  DeliveryAddressModel shipping_adress = locationState.selectedShippingAddress!;
                                  var _selectedVoucher = voucherState.selectedVoucher;
                                  var _usePoint = voucherState.usePoint;
                                  outOfAppNotifier.setIsBillBuilt(false);
                                  outOfAppNotifier.setShowLoading(true);
                                  try{
                                    await api.computeBillingAction(customer, order_address, formData, shipping_adress, _selectedVoucher!, _usePoint!).then((value) {
                                      ref.read(orderBillingStateProvider.notifier).setOrderBillConfiguration(value);
                                      outOfAppNotifier.setIsBillBuilt(true);
                                      outOfAppNotifier.setShowLoading(false);
                                    });
                                  }catch(e){
                                    xrint("XXX impossible_to_load_bill ERROR $e");
                                    Fluttertoast.showToast(
            backgroundColor: Colors.black87,
            textColor: Colors.white,
            fontSize: 14,
            toastLength: Toast.LENGTH_LONG ,
            msg: "🚨 "+AppLocalizations.of(context)!.translate("impossible_to_load_bill")+" 🚨");
                                    outOfAppNotifier.setShowLoading(false);
                                    outOfAppNotifier.setIsBillBuilt(false);
                                  }
                                } else {
                                  orderBillingNotifier.setOrderBillConfiguration(null);
                                }
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xffeaa243),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    "${AppLocalizations.of(context)!.translate('finalize')}",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            )
                                : Container(),
                          ],
                        )
                            : Container(
                          height: 60,
                          alignment: Alignment.center,
                          width: size.width,
                          child: Container(
                            height: 40,
                            width: 40,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
Widget PackageAmountForm(BuildContext context,String amount,WidgetRef ref) {

  final TextEditingController _amountController = TextEditingController();
  _amountController.text = amount;
  _amountController.selection = TextSelection.fromPosition(
    TextPosition(offset:amount.length),
  );
   Timer? _typingTimer;


      final products = ref.watch(productListProvider);
      final outOfAppScreenState = ref.watch(outOfAppScreenStateProvier);
      final productsNotifier = ref.read(productListProvider.notifier);
      final locationState = ref.watch(locationStateProvider);
      final outOfAppNotifier = ref.read(outOfAppScreenStateProvier.notifier);
      final voucherState = ref.watch(voucherStateProvider);


      return Padding(
        padding: const EdgeInsets.all(0.0),

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
                      labelText: "${AppLocalizations.of(context)!.translate('package_amount')}",
                    ),
                     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value)async {
                      ref.read(outOfAppScreenStateProvier.notifier).setPackageAmount(value);
                      _amountController.text = value;
                  _typingTimer!.cancel();
                   _typingTimer = Timer(Duration(seconds: 2), () async {
                    if(locationState.is_shipping_address_picked! && locationState.selectedOrderAddress!.isNotEmpty) {
                                await CustomerUtils.getCustomer().then((customer) async {
                                  ref.read(orderBillingStateProvider.notifier).setCustomer(customer);
                                  OutOfAppOrderApiProvider api = OutOfAppOrderApiProvider();
                                  outOfAppNotifier.setIsBillBuilt(false);
                                  outOfAppNotifier.setShowLoading(true);
                                  productsNotifier.clearProducts();
                                  productsNotifier.addProduct(
                                    {
                                      'name':"Livraison de colis",
                                      'price':value,
                                      'quantity':1,
                                      'image':""
                                    }
                                  );

                                  try {
                                    OrderBillConfiguration orderBillConfiguration =
                                        await api.computeBillingAction(
                                          customer!,
                                          locationState.selectedOrderAddress!,
                                          ref.watch(productListProvider),
                                          locationState.selectedShippingAddress!,
                                          voucherState.selectedVoucher!,
                                          false
                                        );

                                    ref.read(orderBillingStateProvider.notifier)
                                        .setOrderBillConfiguration(orderBillConfiguration);
                                    outOfAppNotifier.setIsBillBuilt(true);
                                    outOfAppNotifier.setShowLoading(false);
                                  } catch (e) {
                                    xrint("impossible_to_load_bill $e");
                                    Fluttertoast.showToast(
                                    backgroundColor: Colors.black87,
                                    textColor: Colors.white,
                                    fontSize: 14,
                                    toastLength: Toast.LENGTH_LONG ,
                                    msg: "🚨 "+AppLocalizations.of(context)!.translate("impossible_to_load_bill")+" 🚨");
                                    outOfAppNotifier.setIsBillBuilt(true);
                                    outOfAppNotifier.setShowLoading(false);
                                  }
                                });
                              }
    });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "${AppLocalizations.of(context)!.translate('please_enter_amount')}";
                      }
                      if (double.tryParse(value)! <0) {
                        return "${AppLocalizations.of(context)!.translate('please_enter_valid_amount')}";
                      }
                      return null;
                    },
                  ),
                ),
              ),

             ],
          ),

      );

}
Widget PhoneNumberForm(BuildContext context,String phoneNumber,WidgetRef ref) {

  final TextEditingController _phoneController = TextEditingController();
  _phoneController.text = phoneNumber;
  _phoneController.selection = TextSelection.fromPosition(
    TextPosition(offset:phoneNumber.length),
  );
  return Consumer(
    builder: (context, ref, child) {
      final outOfAppScreenState = ref.watch(outOfAppScreenStateProvier);
      final outOfAppNotifier = ref.read(outOfAppScreenStateProvier.notifier);

      if (outOfAppScreenState.phone_number?.isNotEmpty == true &&
          _phoneController.text.isEmpty) {
        _phoneController.text = outOfAppScreenState.phone_number;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),

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
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: "${AppLocalizations.of(context)!.translate(outOfAppScreenState.order_type==6?'fecthing_contact':outOfAppScreenState.order_type==5?'shipping_contact':'phone_number_to_contact')}",
                    ),
                    onChanged: (value){
                        outOfAppNotifier.setPhoneNumber(value);
                        _phoneController.text = outOfAppScreenState.phone_number;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "${AppLocalizations.of(context)!.translate('please_enter_phone_number')}";
                      }
                      return null;
                    },
                  ),
                ),
              ),
          ],
          ),

      );
    }
  );
}
