import 'dart:io';
import 'dart:ui' as BorderType;

import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../utils/functions/OutOfAppOrder/imagePicker.dart';
import '../../../../utils/functions/permissions.dart';
import '../bloc/order/order_bloc.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
class PackageFormInfo extends StatefulWidget {
  const PackageFormInfo({super.key});

  @override
  State<PackageFormInfo> createState() => _PackageFormInfoState();
}

class _PackageFormInfoState extends State<PackageFormInfo> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  TextEditingController _declaredValue = TextEditingController();
  TextEditingController _weight = TextEditingController();
  int proofImageType = 0;
  int imageProductType = 1;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
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
          color: Colors.white,
        ),
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
                    SizedBox(width: 10),
                    Icon(FontAwesomeIcons.box, color: Colors.black87),
                    SizedBox(width: 10),
                    Text(
                       "${AppLocalizations.of(context)!.translate('package_information')}",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              FormTitle(
                context: context,
                title:  "${AppLocalizations.of(context)!.translate('package_name')}",
                isRequired: true,
              ),
              SizedBox(height: 10),
              FormTextFieldContainerDecoration(
                context: context,
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    Transform.rotate(
                      angle: -10,
                      child: Icon(Icons.label_sharp, color: Colors.black54),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText:  "${AppLocalizations.of(context)!.translate('package_name_or_description')}",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        onChanged: (value) {
                          BlocProvider.of<OrderBloc>(
                            context,
                          ).add(enterPackageNameEvent(packageName: value));
                          _nameController.text = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              FormTitle(
                context: context,
                title:  "${AppLocalizations.of(context)!.translate('tracking_code')}",
                isRequired: true,
              ),
              SizedBox(height: 10),
              FormTextFieldContainerDecoration(
                context: context,
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    Icon(FontAwesomeIcons.barcode, color: Colors.black54),
                    SizedBox(width: 10),
                    Text(
                      "KBA-",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          hintText:  "${AppLocalizations.of(context)!.translate('tracking_code')}",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        onChanged: (value) {
                          BlocProvider.of<OrderBloc>(
                            context,
                          ).add(enterPackageCodeEvent(packageCode: value));
                          _codeController.text = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              FormTitle(
                context: context,
                title:  "${AppLocalizations.of(context)!.translate('declared_value_fcfa')}",
                isRequired: true,
              ),
              SizedBox(height: 10),
              FormTextFieldContainerDecoration(
                context: context,
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    Icon(Icons.money, color: Colors.black54),
                    Expanded(
                      child: TextFormField(
                        controller: _declaredValue,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: "${AppLocalizations.of(context)!.translate('package_value_fcfa')}",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        onChanged: (value) {
                          BlocProvider.of<OrderBloc>(context).add(
                            enterPackagePriceEvent(
                              packagePrice: double.parse(value),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              FormTitle(
                context: context,
                title:  "${AppLocalizations.of(context)!.translate('estimated_weight_kg')}",
                isRequired: true,
              ),
              SizedBox(height: 10),
              FormTextFieldContainerDecoration(
                context: context,
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    Icon(Icons.monitor_weight, color: Colors.black54),
                    Expanded(
                      child: TextFormField(
                        controller: _weight,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+[\.,]?\d{0,}$')),
                        ],
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        onChanged: (value) {
                          BlocProvider.of<OrderBloc>(context).add(
                            enterPackageWeightEvent(
                              packageWeight: double.parse(value),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              FormTitle(
                context: context,
                title:  "${AppLocalizations.of(context)!.translate('purchase_proof_image')}",
                isRequired: false,
              ),
              SizedBox(height: 10),
              PackageImageForm(type: proofImageType),
              SizedBox(height: 10),
              FormTitle(
                context: context,
                title:  "${AppLocalizations.of(context)!.translate('product_image')}",
                isRequired: false,
              ),
              SizedBox(height: 10),
              PackageImageForm(type: imageProductType),
            ],
          ),
        ),
      ),
    );
  }
}

class UserFormInfo extends StatefulWidget {
  final String username;
  final String userPhoneNumber;
  const UserFormInfo({
    super.key,
    required this.username,
    required this.userPhoneNumber,
  });

  @override
  State<UserFormInfo> createState() => _UserFormInfoState();
}

class _UserFormInfoState extends State<UserFormInfo> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _userPhoneNumberController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  bool isHomeDelivery = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("username ${widget.username}");

    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
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
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: BlocListener<OrderBloc, OrderState>(
  listener: (context, state) {
    if(state is initUserInfoState){
      _usernameController.text = state.username;
      _userPhoneNumberController.text = state.userPhoneNumber;
    }
  },
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
                    SizedBox(width: 10),
                    Icon(FontAwesomeIcons.box, color: Colors.black87),
                    SizedBox(width: 10),
                    Text(
                       "${AppLocalizations.of(context)!.translate('recipient_information')}",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              FormTitle(
                context: context,
                title:  "${AppLocalizations.of(context)!.translate('recipient_name')}",
                isRequired: true,
              ),
              SizedBox(height: 10),
              FormTextFieldContainerDecoration(
                context: context,
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    Icon(Icons.person, color: Colors.black54),
                    Expanded(
                      child: TextFormField( 
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText:  "${AppLocalizations.of(context)!.translate('recipient_name')}",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        onChanged: (value) {
                          BlocProvider.of<OrderBloc>(
                            context,
                          ).add(enterRecipientNameEvent(recipientName: value));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              FormTitle(
                context: context,
                title:  "${AppLocalizations.of(context)!.translate('phone_number_field_')}",
                isRequired: true,
              ),
              SizedBox(height: 10),
              FormTextFieldContainerDecoration(
                context: context,
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    Icon(Icons.phone, color: Colors.black54),
                    Expanded(
                      child: TextFormField(
                        controller: _userPhoneNumberController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(8),
                        ],
                        decoration: InputDecoration(
                          hintText:  "${AppLocalizations.of(context)!.translate('our_offices')}",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        onChanged: (value) {
                          BlocProvider.of<OrderBloc>(context).add(
                            enterRecipientPhoneEvent(recipientPhone: value),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              //Livraison à domicile
              BlocSelector<OrderBloc, OrderState, OrderState>(
                selector: (state) {
                  return state;
                },
                builder: (context, state) {
                  if (state is switchDeliveryModeState) {
                    isHomeDelivery = state.isHomeDelivery;
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.home, color: Colors.black54),
                          FormTitle(
                            context: context,
                            title:  "${AppLocalizations.of(context)!.translate('home_delivery')}",
                            isRequired: false,
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          BlocProvider.of<OrderBloc>(context).add(
                            switchDeliveryModeEvent(
                              isHomeDelivery: !isHomeDelivery,
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: 60,
                          height: 30,
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color:
                                isHomeDelivery
                                    ? KabaChineColors.info
                                    : Colors.grey[400],
                          ),
                          alignment:
                              isHomeDelivery
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              BlocSelector<OrderBloc, OrderState, OrderState>(
                selector: (state) {
                  return state;
                },
                builder: (context, state) {
                  if (state is switchDeliveryModeState) {
                    isHomeDelivery = state.isHomeDelivery;
                  }
                  return isHomeDelivery
                      ? Column(
                        children: [
                          SizedBox(height: 10),
                          FormTitle(
                            context: context,
                            title:"${AppLocalizations.of(context)!.translate('delivery_address')}",
                            isRequired: false,
                          ),
                          SizedBox(height: 10),
                          FormTextFieldContainerDecoration(
                            context: context,
                            maxLines: 3,

                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.home_outlined,
                                    color: Colors.black54,
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _addressController,
                                      keyboardType: TextInputType.text,
                                      maxLines: 5,
                                      inputFormatters: <TextInputFormatter>[
                                        LengthLimitingTextInputFormatter(1000),
                                      ],
                                      onChanged: (value) {
                                        BlocProvider.of<OrderBloc>(context).add(
                                          enterAddressEvent(addressText: value),
                                        );
                                      },
                                      decoration: InputDecoration(
                                        hintText:
                                          "${AppLocalizations.of(context)!.translate('delivery_address_description')}",
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                      : Container();
                },
              ),
              SizedBox(height: 10),
              FormTitle(
                context: context,
                title: "${AppLocalizations.of(context)!.translate('note_optional')}",
                isRequired: false,
              ),
              SizedBox(height: 10),
              FormTextFieldContainerDecoration(
                context: context,
                maxLines: 3,

                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      SizedBox(width: 10),
                      Icon(Icons.note_alt, color: Colors.black54),
                      Expanded(
                        child: TextFormField(
                          controller: _noteController,
                          keyboardType: TextInputType.text,
                          inputFormatters: <TextInputFormatter>[
                            LengthLimitingTextInputFormatter(1000),
                          ],
                          maxLines: 5,
                          onChanged: (value) {
                            BlocProvider.of<OrderBloc>(context).add(
                              enterAdditionnalNotesEvent(
                                additionnalNotes: value,
                              ),
                            );
                          },
                          decoration: InputDecoration(
                            hintText:
                                "${AppLocalizations.of(context)!.translate('special_delivery_instructions')}",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
),
        ),
      ),
    );
  }
}

Widget FormTitle({
  required BuildContext context,
  required String title,
  required bool isRequired,
}) {
  return Row(
    children: [
      Text("$title", style: TextStyle()),
      SizedBox(width: 5),
      isRequired
          ? Text(
            '*',
            style: TextStyle(color: KabaChineColors.primary, fontSize: 16),
          )
          : Container(),
    ],
  );
}

Widget FormTextFieldContainerDecoration({
  required BuildContext context,
  required Widget child,
  int maxLines = 1,
}) {
  Size size = MediaQuery.of(context).size;
  return Container(
    width: size.width,
    height: (maxLines > 1 ? 55 : 50) * maxLines.toDouble(),
    decoration: BoxDecoration(
      border: Border.all(width: 1, color: KabaChineColors.border),
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: child,
  );
}

class PackageImageForm extends StatefulWidget {
  final int type;
  const PackageImageForm({super.key, required this.type});

  @override
  State<PackageImageForm> createState() => _PackageImageFormState();
}

class _PackageImageFormState extends State<PackageImageForm> {
  File? _purchaseProofImage;
  File? _productImage;
  bool _purchaseProofImageSelected = false;
  bool _productImageSelected = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    OrderBloc orderBloc = BlocProvider.of<OrderBloc>(context);

    return BlocSelector<OrderBloc, OrderState, OrderState>(
      selector: (state) {
        return state;
      },
      builder: (context, state) {
        if (state is chooseProofImageState) {
          _purchaseProofImage = state.proofImage;
          _purchaseProofImageSelected = true;
        } else if (state is chooseProductImageState) {
          _productImage = state.productImage;
          _productImageSelected = true;
        }
        return GestureDetector(
          onTap: () async {
            if (Platform.isAndroid) {
              try {
                await pickImageAndroid(context).then((value) {
                  if (value != null) {
                    if (widget.type == 0)
                      orderBloc.add(chooseProofImageEvent(proofImage: value));
                    else if (widget.type == 1)
                      orderBloc.add(
                        chooseProductImageEvent(productImage: value),
                      );
                  } else {
                    debugPrint("No image picked or image too large.");
                    CherryToast.error(
                      toastPosition: Position.center,
                       title: Text("${AppLocalizations.of(context)!.translate('error')}"),
                      description: Text("${AppLocalizations.of(context)!.translate('no_image_or_too_large')}"),
                      toastDuration: Duration(seconds: 5),
                    ).show(context);
                    // Optionally show a SnackBar or handle cancellation here
                  }
                });
              } catch (e) {
                debugPrint("##Error in image picking, out of app order## $e");
              }
            } else {
              try {
                bool granted = await requestCameraAndGalleryPermissions();
                if (granted) {
                  await pickImageIOS(context).then((value) {
                    if (widget.type == 0)
                      orderBloc.add(chooseProofImageEvent(proofImage: value!));
                    else if (widget.type == 1)
                      orderBloc.add(
                        chooseProductImageEvent(productImage: value!),
                      );
                  });
                  debugPrint("Camera permission granted!");
                     CherryToast.success(
                      toastPosition: Position.center,
                      title: Text("${AppLocalizations.of(context)!.translate('success')}"),
                      description:Text("${AppLocalizations.of(context)!.translate('camera_permission_granted')}"),
                     toastDuration: Duration(seconds: 5),
                    ).show(context);
               
                } else {
                  debugPrint("Camera permission denied.");
                     CherryToast.error(
                      toastPosition: Position.center,
                           title: Text("${AppLocalizations.of(context)!.translate('error')}"),
                     description: Text("${AppLocalizations.of(context)!.translate('camera_permission_denied')}"),
                     toastDuration: Duration(seconds: 5),
                    ).show(context);
               
            
                }
              } catch (e) {
                debugPrint("##Error in image picking, out of app order## $e");
              }
            }
          },
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              dashPattern: [3, 3],
              strokeWidth: 1,
              color: Colors.black38,
              radius: Radius.circular(10),
            ),
            child: Container(
              width: size.width,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.withOpacity(0.1),
              ),
              child: Container(
                decoration: BoxDecoration(
                  image:
                      _purchaseProofImageSelected && widget.type == 0
                          ? DecorationImage(
                            image: FileImage(_purchaseProofImage!),
                            fit: BoxFit.cover,
                          )
                          : _productImageSelected && widget.type == 1
                          ? DecorationImage(
                            image: FileImage(_productImage!),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 10),
                    Icon(Icons.camera_alt, color: Colors.black38),
                    SizedBox(width: 10),
                    Text(
                      "${AppLocalizations.of(context)!.translate('select_image')}",
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DeliveryConditions extends StatefulWidget {
  const DeliveryConditions({super.key});

  @override
  State<DeliveryConditions> createState() => _DeliveryConditionsState();
}

class _DeliveryConditionsState extends State<DeliveryConditions> {
  bool accept_general_service = false;
  bool confirm_packages_is_safe = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
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
          color: Colors.white,
        ),
        child: BlocSelector<OrderBloc, OrderState, OrderState>(
          selector: (state) {
            return state;
          },
          builder: (context, state) {
            if (state is checkPackageIsSafeState) {
              confirm_packages_is_safe = state.packageCondition;
            } else if (state is checkGeneralConditionState) {
              accept_general_service = state.generalCondition;
            }
            return Padding(
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
                        SizedBox(width: 10),
                        Icon(Icons.gpp_good_rounded, color: Colors.black87),
                        SizedBox(width: 10),
                        Text(
                          "Conditions",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        side: BorderSide(
                          color: KabaChineColors.border,
                          width: 1,
                        ),
                        value: accept_general_service,
                        onChanged: (value) {
                          BlocProvider.of<OrderBloc>(context).add(
                            checkGeneralConditionEvent(
                              generalCondition: !accept_general_service,
                            ),
                          );
                        },
                      ),
                      Expanded(
                        child: Text(
                          "${AppLocalizations.of(context)!.translate('accept_terms')}",
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        side: BorderSide(
                          color: KabaChineColors.border,
                          width: 1,
                        ),
                        value: confirm_packages_is_safe,
                        onChanged: (value) {
                          if (value != null)
                            BlocProvider.of<OrderBloc>(context).add(
                              checkPackageIsSafeEvent(packageCondition: value!),
                            );
                        },
                      ),
                      Expanded(
                        child: Text(
                        "${AppLocalizations.of(context)!.translate('confirm_no_prohibited_items')}",
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info, color: Colors.black54, size: 16),
                      SizedBox(width: 5),
                      Text(
                        "${AppLocalizations.of(context)!.translate('fields_marked')}",
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      Text(
                        "*",
                        style: TextStyle(
                          color: KabaChineColors.primary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                       "${AppLocalizations.of(context)!.translate('are_required')}",
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
