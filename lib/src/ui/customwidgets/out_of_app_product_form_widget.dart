import 'dart:io';

import 'package:KABA/src/state_management/out_of_app_order/products_state.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../localizations/AppLocalizations.dart';
import '../../utils/functions/OutOfAppOrder/imagePicker.dart';
import 'BouncingWidget.dart';
import 'package:image_picker/image_picker.dart';
Widget OutOfAppProductForm(BuildContext context){
  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  Size size = MediaQuery.of(context).size;

  String imagePath='';
  final _formKey = GlobalKey<FormState>();
  return Container(
    width: size.width,
    height: 290,
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

    return GestureDetector(
              onTap: ()async{
                try{
                  await PickImage(context,ref).then((value){
                    ref.read(imageCacheProvider.notifier).state = value;
                    imagePath = ref.watch(imageCacheProvider.notifier).state;
                  });

                }catch(e){
                  print("##Error in image picking, out of app order## $e");
                }
              },
              child: Container(
                height: 100,
                width: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Color(0x64d2d2d2),
                    borderRadius: BorderRadius.circular(5),
                    image: imagePath.isNotEmpty? DecorationImage(
                        image: FileImage(File(imageCache)),
                      fit: BoxFit.cover
                    ):null,
                ),
                child: imagePath.isEmpty?
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
              child: Column(

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



                      return Column(
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
                            ref.read(productListProvider.notifier).addProduct(product);
                            quantityNotifier.reset();
                            ref.read(imageCacheProvider.notifier).saveImagePath("");

                            Navigator.pop(context);

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
                    ],
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