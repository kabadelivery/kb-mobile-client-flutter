import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget PackageFormInfo({required BuildContext context}) {
  Size size = MediaQuery.of(context).size;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _declaredValue = TextEditingController();
  TextEditingController _weight = TextEditingController();
  FileImage? _purchaseProofImage;
  FileImage? _productImage;
  return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
          width: size.width,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5.0,
              spreadRadius: 1.0,
              offset: Offset(0, 2),
            ),
          ], borderRadius: BorderRadius.circular(10), color: Colors.white),
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
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
                          color: Colors.black87,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Informations du colis",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                ),
                SizedBox(height: 10),
                FormTitle(context: context, title: "Nom du colis", isRequired: true),
                SizedBox(height: 10),
                FormTextFieldContainerDecoration(
                    context: context,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Transform.rotate(
                            angle: -10,
                            child:Icon(Icons.label_sharp, color: Colors.black54)),
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: "Nom ou description du colis",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le nom du colis';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    )),
              ])
          )
      )
  );
}

Widget FormTitle({required BuildContext context,required String title, required bool isRequired}) {
  return Row(
    children: [
      Text("$title",style:TextStyle()),
      SizedBox(width: 5,),
      isRequired?Text('*', style: TextStyle(color: KabaChineColors.primary, fontSize: 16)) : Container(),
    ],
  );
}
Widget FormTextFieldContainerDecoration({required BuildContext context,required Widget child}) {
  Size size = MediaQuery.of(context).size;
  return Container(
    width: size.width,
    height: 50,
    decoration: BoxDecoration(
      border: Border.all(width: 1, color: KabaChineColors.border),
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: child,
  );

}