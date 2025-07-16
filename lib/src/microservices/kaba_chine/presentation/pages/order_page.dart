import 'package:KABA/src/microservices/kaba_chine/Enums/deliveryStatus.dart';
import 'package:KABA/src/microservices/kaba_chine/data/order/delivery_model.dart';
import 'package:KABA/src/microservices/kaba_chine/domain/user/user_entity.dart';
import 'package:KABA/src/microservices/kaba_chine/presentation/bloc/menu/menu_bloc.dart';
import 'package:KABA/src/microservices/kaba_chine/presentation/bloc/order/order_bloc.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cherry_toast/cherry_toast.dart';
import '../../../../utils/functions/CustomerUtils.dart';
import '../../Enums/menu.dart';
import '../../core/utils.dart';
import '../../domain/tarif/shipping_entity.dart';
import '../../functions/checkInfos.dart';
import '../widgets/office.dart';
import '../widgets/package_form_info.dart';
import 'history_page.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
class KabaChineOrderPage extends StatefulWidget {
  const KabaChineOrderPage({super.key});

  @override
  State<KabaChineOrderPage> createState() => _KabaChineOrderPageState();
}

class _KabaChineOrderPageState extends State<KabaChineOrderPage> {

  String customercode = "TG-XXXXXX";
  String userPhoneNumber = "";
  String username = "";
  bool accept_general_service = false;
  bool confirm_packages_is_safe = false;
  bool isLoading =false;
  List<ShippingEntity> shipping_offices = [
    ShippingEntity(departure: "GuangZhou", destination: "Agbalépédogan",),
  ];
  Delivery delivery = Delivery(
      id: "",
      packageName: "",
      trackingCode: "",
      declaredValue: 0,
      recipientName: "",
      buyerPhoneNumber: "",
      shippingMode: 0,
      status: DeliveryStatus.pending.toString(),
      homeDelivery: false,
      estimatedWeight: 0,
      collectionOffice: "GuangZhou",
      destinationOffice: "Agbalépédogan",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      notes: "",
      productImage:"",
      purchaseProofImage: "",
  );
  @override
  void initState() {
    super.initState();
    BlocProvider.of<OrderBloc>(context).add(getInfosEvent());
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    
    return BlocConsumer<OrderBloc, OrderState>(
  listener: (context, state) {
    if(state is getInfosState) {
      username = state.user.name!;
      userPhoneNumber = state.user.phone_number!;
      delivery.recipientName = state.user.name!;
      delivery.buyerPhoneNumber = state.user.phone_number!;
      customercode = state.user.customer_code!;
      BlocProvider.of<OrderBloc>(context).add(initUserInfoEvent(username: username, userPhoneNumber: userPhoneNumber));

    }
    else if(state is chooseExpeditionModeState) {
      delivery.shippingMode = state.expeditionMode.value;
      debugPrint(delivery.shippingMode.toString());
    }
    else if(state is switchDeliveryModeState) {
      delivery.homeDelivery = state.isHomeDelivery;
      debugPrint(delivery.homeDelivery.toString());
    }
    else if(state is enterPackageNameState) {
      delivery.packageName = state.packageName;
      debugPrint(delivery.packageName);
    }
    else if(state is enterPackageWeightState) {
      delivery.estimatedWeight = state.packageWeight;
      debugPrint(delivery.estimatedWeight.toString());
    }
    else if(state is enterPackagePriceState) {
      delivery.declaredValue = state.packagePrice;
      debugPrint(delivery.declaredValue.toString());
    }
    else if(state is enterRecipientNameState) {
      delivery.recipientName = state.recipientName;
      debugPrint(delivery.recipientName);
    }
    else if(state is enterRecipientPhoneState) {
      delivery.buyerPhoneNumber = state.recipientPhone;
      debugPrint(delivery.buyerPhoneNumber);
    }
    else if(state is enterAdditionnalNotesState) {
      delivery.notes = state.additionnalNotes;
      debugPrint(delivery.notes);
    }
    else if(state is enterAddressState){
      delivery.destinationOffice = state.addressText;
    }
    else if(state is checkPackageIsSafeState) {
      confirm_packages_is_safe = state.packageCondition;
      debugPrint(confirm_packages_is_safe.toString());
    }
    else if(state is checkGeneralConditionState) {
      accept_general_service = state.generalCondition;
      debugPrint(accept_general_service.toString());
    }
    else if(state is chooseProofImageState) {
      BlocProvider.of<OrderBloc>(context).add(uploadImageEvent(imagePath: state.proofImage.path, type: 'proof'));
    }
    else if(state is chooseProductImageState) {
      BlocProvider.of<OrderBloc>(context).add(uploadImageEvent(imagePath: state.productImage.path, type: 'product'));
    }
    else if(state is LoadingState){
      isLoading = true;
      BlocProvider.of<OrderBloc>(context).add(startOrderingEvent(delivery: delivery,context: context));
    }
    else if(state is enterPackageCodeState){
      delivery.trackingCode =state.packageCode;
    }
    else if(state is endOrderingState){
      isLoading = false;
      if(state.error==false){
        MenuBloc menuBloc = BlocProvider.of<MenuBloc>(context);
        menuBloc.add(changeMenuEvent(selectedMenu: MenuEnum.historique));
        CherryToast.success(
            toastPosition: Position.center,
            toastDuration:
            Duration(seconds: 5),
            title: Text(state.msg)).show(context);
      }else{
        CherryToast.error(
            toastPosition: Position.center,
            toastDuration:
            Duration(seconds: 5),
            title: Text(state.msg)).show(context);
      }
    }
    else if(state is uploadImageState){
      if(state.url.isEmpty){
        CherryToast.error(
            toastPosition: Position.center,
            toastDuration:
            Duration(seconds: 5),
            title: Text("${AppLocalizations.of(context)!.translate('image_send_error')}")).show(context);
      }else{
        if(state.type == 'proof'){
          delivery.purchaseProofImage = state.url;
        }else{
          delivery.productImage = state.url;
        }
      }
    }
  },
  builder: (context, state) {

    return isLoading == true ? Center(child: MyLoadingProgressWidget()) : SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: size.width,
            height: 170,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  KabaChineColors.primary,
                  KabaChineColors.primary_darker,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 20,),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: KabaChineColors.card.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(Icons.arrow_back_sharp,size: 20,color: KabaChineColors.card,),
                    ),
                    Container()
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("${AppLocalizations.of(context)!.translate('delivery_request')}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 23),),
                    SizedBox(height: 10),
                    Text("${AppLocalizations.of(context)!.translate('your_customer_code')}"+": $customercode",style: TextStyle(color: Colors.white,fontSize: 14),)
                  ],
                ),

              ],
            )
          ),
          SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: size.width,
              height: 90,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5.0,
                    spreadRadius: 1.0,
                    offset: Offset(0, 2),
                  ),
                ],
                color:  Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border(left: BorderSide(width: 4,color: KabaChineColors.primary)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${AppLocalizations.of(context)!.translate('customer_code')}"),
                    Text("${customercode}",style: TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.bold),),
                    Text("${AppLocalizations.of(context)!.translate('code_usage_info')}",style: TextStyle(color: Colors.black54,fontSize: 12),)
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          OfficesWidget(context: context,shipping_offices:[ShippingEntity(departure: "GuangZhou", destination: "Agbalépédogan")]),
          SizedBox(height: 10),
          ExpeditionModes(),
          SizedBox(height: 10,),
          PackageFormInfo(),
          SizedBox(height: 10,),
          UserFormInfo(username:username.toString(), userPhoneNumber: userPhoneNumber.toString()),
          SizedBox(height: 10,),
          DeliveryConditions(),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: MaterialButton(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: 50,
              color: KabaChineColors.primary,
              minWidth: size.width,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onPressed: () async{
                Map isformCorrect = await isFormInfosCorrect(context:context,delivery:delivery,generalConditionsAccepted:  accept_general_service,packageIsSafeConditionAccepted:  confirm_packages_is_safe);
                if(isformCorrect['is_good']==false){
                  CherryToast.error(
                      toastPosition: Position.center,
                      toastDuration:
                      Duration(seconds: 5),
                      title: Text(isformCorrect['msg'])
                  ).show(context);
                }else{
                  CustomerModel customer = await CustomerUtils.getCustomer();
                  delivery.buyerId = customer!.id.toString();
                  delivery.userId = customer.id.toString();
                  delivery.kabaUserId = customer.id.toString();
                  debugPrint("IsHomeDelivery"+delivery.homeDelivery.toString());
                  BlocProvider.of<OrderBloc>(context).add(LoadingEvent());
                }
                },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send,color:Colors.white,size: 20,),
                  SizedBox(width: 10,),
                  Text("${AppLocalizations.of(context)!.translate('submit_request')}",style: TextStyle(color: Colors.white,fontSize: 16),)
                ],
              ),
            ),
          ),
                  ]
    )
    );
  },
);
  }
}
