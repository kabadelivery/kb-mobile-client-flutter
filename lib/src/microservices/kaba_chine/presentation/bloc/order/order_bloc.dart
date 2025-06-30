import 'dart:io';

import 'package:KABA/src/microservices/kaba_chine/Enums/TarifType.dart';
import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/order/delivery_model.dart';
import '../../../data/user/user_model.dart';
import '../../../domain/user/user_entity.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(OrderInitial()) {
    on<OrderEvent>((event, emit) async{

      UserModel userModel = await KabaChineUtils().getUserInfo();
      CustomerModel customerModel = await CustomerUtils.getCustomer();
      UserEntity user = UserEntity(customer_code: userModel.customer_code,name: customerModel.nickname,phone_number: customerModel.phone_number);

      if(event is getInfosEvent){
        emit(getInfosState(user: user));
      }
      else if(event is chooseExpeditionModeEvent){
        emit(chooseExpeditionModeState(expeditionMode: event.expeditionMode));
      }
      else if(event is switchDeliveryModeEvent){
        emit(switchDeliveryModeState(isHomeDelivery: event.isHomeDelivery));
      }
      else if(event is chooseProofImageEvent){
        emit(chooseProofImageState(proofImage: event.proofImage));
      }
      else if(event is chooseProductImageEvent){
        emit(chooseProductImageState(productImage: event.productImage));
      }
      else if(event is enterPackageNameEvent){
        emit(enterPackageNameState(packageName: event.packageName));
      }
      else if(event is enterPackageWeightEvent){
        emit(enterPackageWeightState(packageWeight: event.packageWeight));
      }
      else if(event is enterPackagePriceEvent){
        emit(enterPackagePriceState(packagePrice: event.packagePrice));
      }
      else if(event is enterRecipientNameEvent){
        emit(enterRecipientNameState(recipientName: event.recipientName));
      }
      else if(event is enterRecipientPhoneEvent){
        emit(enterRecipientPhoneState(recipientPhone: event.recipientPhone));
      }
      else if(event is enterAdditionnalNotesEvent){
        emit(enterAdditionnalNotesState(additionnalNotes: event.additionnalNotes));
      }
      else if(event is checkPackageIsSafeEvent){
        emit(checkPackageIsSafeState(packageCondition: event.packageCondition));
      }
      else if(event is checkGeneralConditionEvent){
        emit(checkGeneralConditionState(generalCondition: event.generalCondition));
      }
      else if(event is startOrderingEvent){
        Delivery delivery = event.delivery;
        await Future.delayed(Duration(seconds: 2));
        String success = "Votre commande a été enregistrée avec succès. Vous pouvez suivre son état dans la section historique.";
        String error = "Une erreur s'est produite lors de l'enregistrement de votre commande. Veuillez réessayer plus tard.";

        emit(endOrderingState(msg: success,error: false));
      }
      else if(event is LoadingEvent){
        emit(LoadingState());
      }
    });
  }
}
