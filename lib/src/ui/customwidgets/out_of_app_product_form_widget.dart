import 'dart:async';
import 'dart:io';

import 'package:KABA/src/state_management/out_of_app_order/products_state.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:dotted_border/dotted_border.dart';
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

import '../../utils/functions/permissions.dart';
import '../../xrint.dart';
import '../screens/out_of_app_orders/out_of_app.dart';
import 'billing_widget.dart';
import 'out_of_app_product_widget.dart';

class OutOfAppProductForm extends ConsumerWidget {
  const OutOfAppProductForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ici tu peux utiliser Riverpod normalement
    return _OutOfAppProductFormContent();
  }
}

class _OutOfAppProductFormContent extends StatefulWidget {
  @override
  State<_OutOfAppProductFormContent> createState() =>
      _OutOfAppProductFormContentState();
}

class _OutOfAppProductFormContentState
    extends State<_OutOfAppProductFormContent> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _priceFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ScrollController scrollController = ScrollController();
  var imagePath;
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _nameFocusNode.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      decoration: BoxDecoration(
        color: Colors.white ,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding:  EdgeInsets.all(12),
        child:SingleChildScrollView(
          controller: scrollController,
          child:  Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text("Ajouter des produits",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                      SizedBox(height: 5),
                      Text("Créez votre liste de commande",style: TextStyle(fontSize: 14,color: Colors.black54),),
                    ],
                  ),
                 Container()
                ],
              ),
              SizedBox(height: 25),
              Container(
                width: size.width*.9,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  border: Border.all(width: .5,color: Colors.grey),
                  borderRadius: BorderRadius.circular(15),

                ),
                child: Column(
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        final imageCache = ref.watch(imageCacheProvider);
                        final outOfAppScreenState = ref.watch(outOfAppScreenStateProvier);

                        return GestureDetector(
                          onTap: outOfAppScreenState.showLoading == false
                              ? () async {
                                      if(Platform.isAndroid){
                                        try {
                                            await pickImageAndroid(context).then((value) {
                                              ref.read(imageCacheProvider.notifier).state = value;
                                              imagePath = ref.watch(imageCacheProvider.notifier).state!;
                                            });
                                        } catch (e) {
                                          print("##Error in image picking, out of app order## $e");
                                        }
                                      }else{
                                        try {
                                          bool granted = await requestCameraAndGalleryPermissions();
                                          if(granted==true){
                                            await pickImageIOS(context).then((value) {
                                              ref.read(imageCacheProvider.notifier).state = value;
                                              imagePath = ref.watch(imageCacheProvider.notifier).state!;
                                            });
                                          }
                                        } catch (e) {
                                          print("##Error in image picking, out of app order## $e");
                                        }
                                      }
                          }
                              : null,
                          child: DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              dashPattern: [4,8],
                              strokeWidth: 1,
                              color: KColors.primaryColor,
                              radius: Radius.circular(10),
                            ),
                            child: Container(
                              height: 100,
                              width: 100,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xFFF3DDE3),
                                borderRadius: BorderRadius.circular(10),
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
                                      Icons.camera_alt_outlined,
                                      color: Color(0xFFCD1F45),
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "${AppLocalizations.of(context)!.translate('choose_an_image')}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: KColors.primaryColor,
                                    ),
                                  ),
                                ],
                              )
                                  : Container(),
                            ),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                            "${AppLocalizations.of(context)!.translate('product_name')}",style: TextStyle(fontSize: 15,color: Colors.black87,fontWeight: FontWeight.bold),),
                            SizedBox(height: 10),
                            TextFormField(
                              focusNode: _nameFocusNode,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(_priceFocusNode);
                                if (_priceController.text == "0") {
                                  _priceController.text = "";
                                }
                              },
                              controller: _nameController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "${AppLocalizations.of(context)!.translate('enter_product_name')}";
                                }
                                if (value.length > 30) {
                                  return "${AppLocalizations.of(context)!.translate('name_too_long')}";
                                }
                                return null;
                              },
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: "Ex : Paracétamol 500mg",
                                filled: true,
                                fillColor: Color(0x9EECECEC),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15), // arrondi
                                  borderSide: BorderSide(width: .5,color: Colors.grey),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(width: 1,color: Colors.grey)
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD02245), // bordure rouge foncé quand focus
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text("${AppLocalizations.of(context)!.translate('product_price')} (FCFA)",style: TextStyle(fontSize: 15,color: Color(
                                0xFF424242),fontWeight: FontWeight.bold),),
                            SizedBox(height: 10),
                            TextFormField(
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).unfocus();
                              },
                              focusNode: _priceFocusNode,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onTap: (){
                                if(_priceController.text=="0"){
                                  _priceController.text="";
                                }
                              },

                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(

                                filled: true,
                                fillColor: Color(0x9EECECEC),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15), // arrondi
                                  borderSide: BorderSide(width: .5,color: Colors.grey),
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(width: 1,color: Colors.grey)
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD02245), // bordure rouge foncé quand focus
                                    width: 1.5,
                                  ),
                                ),
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
                                    ?

                                Column(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${AppLocalizations.of(context)!.translate('quantity')}:",
                                          style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border:Border.all(width: .5, color:KColors.primaryColor),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: IconButton(
                                                onPressed: () {
                                                  quantityNotifier.decrease();
                                                  print("decrease");
                                                },
                                                icon: Icon(
                                                  Icons.remove,
                                                  color: KColors.primaryColor,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 20,),
                                            Container(
                                              width: 50,
                                              height:50,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                               boxShadow: [
                                                 BoxShadow(
                                                   color: Colors.grey.withOpacity(0.5),
                                                   spreadRadius: 1,
                                                   blurRadius: 5,
                                                   offset: Offset(0, 3)),
                                               ],
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  quantity.toString(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.black87
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 20,),
                                            Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border:Border.all(width: .5, color:KColors.primaryColor),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: IconButton(
                                                onPressed: () {
                                                  quantityNotifier.increase();
                                                  print("increase $quantity");
                                                },
                                                icon: Icon(
                                                  Icons.add,
                                                  color: KColors.primaryColor,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ],
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
                                          scrollController.animateTo(
                                              scrollController.position.maxScrollExtent,
                                              duration: Duration(milliseconds: 500),
                                              curve: Curves.easeOut);
                                        }

                                      },
                                      child: Container(
                                        width: size.width,
                                        decoration: BoxDecoration(
                                          color: KColors.primaryColor,
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add, color: Colors.white,size: 20),
                                              Text(
                                                "${AppLocalizations.of(context)!.translate('add_product')}",
                                                style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Ma commande :",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: KColors.primaryColor,
                                            borderRadius: BorderRadius.circular(50)
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 25,vertical: 5),
                                          child: Text("${products.length} ${products.length>1?"produits":"produit"}",style: TextStyle(color:Colors.white,fontSize: 15,fontWeight: FontWeight.bold),),

                                        )
                                      ],
                                    ),
                                    SizedBox(height: 15),
                                    products!=null && products.isNotEmpty?
                                    Container(
                                        width: size.width,
                                        alignment: Alignment.center,
                                        height: 105.0*products.length,
                                        child: ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            itemCount: products.length,
                                            itemBuilder: (context,index){
                                              Map<String,dynamic> product = products[index];
                                              if(products.length!=0){
                                                return Container(
                                                  alignment: Alignment.center,
                                                    margin: EdgeInsets.only(bottom: 15),
                                                    child: OutOfAppProduct(
                                                        context,
                                                        ref,
                                                        index,
                                                        product['image']??File(''),
                                                        product['name'],
                                                        product['price'],
                                                        product['quantity']));
                                              }
                                              else{
                                                return Text('Aucun produit');
                                              }
                                            }
                                        )
                                    ):Container(),
                                    SizedBox(height: 15),
                                    products!=null && products.isNotEmpty?
                                    Container(
                                      width: size.width,
                                      height:50,
                                      decoration:BoxDecoration(
                                        borderRadius:BorderRadius.circular(15),
                                        color:KColors.primaryColor.withOpacity(.1),
                                        border:Border.all(width: .5,color:KColors.primaryColor)
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 15),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Total",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                            Text("${products.map((el)=>el['price']*el['quantity']).reduce((a,b)=>a+b)} FCFA"
                                            ,
                                              style: TextStyle(fontSize: 20,color:KColors.primaryColor,fontWeight: FontWeight.bold),)
                                          ],
                                      ),
                                    ):Container(),
                                    SizedBox(height: 15),
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
                                            await api.computeBillingAction(customer,
                                                order_address,
                                                formData,
                                                shipping_adress,
                                                _selectedVoucher??null,
                                                _usePoint??false).then((value) {
                                              if(value.shipping_pricing==0){
                                                showOutOfRangePopup(context);
                                                outOfAppNotifier.setIsBillBuilt(false);
                                                outOfAppNotifier.setShowLoading(false);
                                              }else{
                                                ref.read(orderBillingStateProvider.notifier)
                                                    .setOrderBillConfiguration(value);
                                                outOfAppNotifier.setIsBillBuilt(true);
                                                outOfAppNotifier.setShowLoading(false);
                                              }
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
                                       Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => OutOfAppOrderPage(),
                                          ),
                                       );
                                      },
                                      child: Container(
                                        width: size.width,
                                        decoration: BoxDecoration(
                                          color: KColors.primaryColor,
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(
                                            "${AppLocalizations.of(context)!.translate('finalize')}",
                                            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
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
            ],
          ),
        )
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
                  color: Color(0x3dd0d0ff),
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
                   if (_typingTimer != null) {
                     _typingTimer!.cancel();
                   }
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
                                          customer,
                                          locationState.selectedOrderAddress,
                                          ref.watch(productListProvider),
                                          locationState.selectedShippingAddress,
                                          voucherState.selectedVoucher,
                                          false
                                        );

                                    if(orderBillConfiguration.shipping_pricing==0){
                                      showOutOfRangePopup(context);
                                      outOfAppNotifier.setIsBillBuilt(false);
                                      outOfAppNotifier.setShowLoading(false);
                                    }else{
                                      ref.read(orderBillingStateProvider.notifier)
                                          .setOrderBillConfiguration(orderBillConfiguration);
                                      outOfAppNotifier.setIsBillBuilt(true);
                                      outOfAppNotifier.setShowLoading(false);
                                    }
                                  } catch (e) {
                                    xrint("impossible_to_load_bill $e");
                                    Fluttertoast.showToast(
                                    backgroundColor: Colors.black87,
                                    textColor: Colors.white,
                                    fontSize: 14,
                                    toastLength: Toast.LENGTH_LONG ,
                                    msg: "🚨 "+AppLocalizations.of(context)!.translate("impossible_to_load_bill")+" 🚨");
                                    outOfAppNotifier.setIsBillBuilt(false);
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
                  color: Color(0x3dd0d0ff),
                  borderRadius: BorderRadius.circular(15)
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
