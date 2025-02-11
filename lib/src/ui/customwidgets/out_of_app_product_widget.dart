import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state_management/out_of_app_order/products_state.dart';
import '../../utils/_static_data/KTheme.dart';

Widget OutOfAppProduct(
    BuildContext context,
    WidgetRef ref,
    int index,
    String image,
    String name,
    int price,
    int quantity){
  Size size = MediaQuery.of(context).size;
  bool isDeleted= false;
  return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500),
      builder: (context,double value,child){
    return Opacity(
      opacity: value,
    child: Transform.scale(
        scale: value,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            width: size.width*.85,
            decoration: BoxDecoration(
                color: Color(0x42d2d2d2),
                borderRadius: BorderRadius.circular(5)
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //image
                  Row(
                    children: [
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                                image: FileImage(File(image)),
                                fit: BoxFit.cover
                            )
                        ),

                      ),
                      SizedBox(width: 10,),
                      //Name
                      Text(name.length>15?name.substring(0,15)+"..":name,),

                    ],
                  ),
                  Text("${price.toInt()}x${quantity}",style: TextStyle(fontWeight: FontWeight.bold),),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xfff0dbe1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text("${(price*quantity).toInt()} FCFA",style: TextStyle(color: KColors.primaryColor,fontWeight: FontWeight.bold),),
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(width: 10,),
          GestureDetector(
            onTap: (){
              ref.read(productListProvider.notifier).removeProduct(index);
            },
            child: Container(
              height: 30,
              width: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: KColors.primaryColor,
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.delete,color: Colors.white,size: 15,),
              ),
            ),
          )
        ],
      ),
    ),
    );
  }) ;
}