import 'dart:io';

import 'package:KABA/src/microservices/kaba_chine/Enums/TarifType.dart';
import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:KABA/src/microservices/kaba_chine/data/order/payment_info_model.dart';
import 'package:KABA/src/microservices/kaba_chine/domain/order/repository.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../../../data/order/data_remote_source.dart';
import '../../../data/order/delivery_model.dart';
import '../../../data/order/payment_model.dart';
import '../../../data/tarif/data_remote_source.dart';
import '../../../data/user/user_model.dart';
import '../../../domain/tarif/repository.dart';
import '../../../domain/tarif/tarif_entity.dart';
import '../../../domain/user/user_entity.dart';
import '../../../usecases/order/create_order.dart';
import '../../../usecases/order/getPaymentInfo.dart';
import '../../../usecases/order/upload_image.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';

import '../../../usecases/tarif/get_tarif.dart';
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
      if(event is initUserInfoEvent){
        emit(initUserInfoState(username: event.username, userPhoneNumber: event.userPhoneNumber));
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
      else if(event is enterPackageCodeEvent){
        emit(enterPackageCodeState(packageCode: event.packageCode));
      }
      else if(event is startOrderingEvent){
        CreateDeliveryRequest createDeliveryRequest = CreateDeliveryRequest(DeliveryRepositoryImpl(DeliveryRemoteDataSourceImpl(http.Client())));
        event.delivery.trackingCode = "KBA-"+event.delivery.trackingCode.toString().toUpperCase();

        Delivery delivery = await createDeliveryRequest.call(event.delivery);
        if(delivery == null){
          
          String error = "${AppLocalizations.of(event.context)!.translate('order_save_error')}";
          emit(endOrderingState(msg: error,error: true));
        }else{
          String success = "${AppLocalizations.of(event.context)!.translate('order_save_success')}";
          emit(endOrderingState(msg: success,error: false));
        }
      }
      else if(event is LoadingEvent){
        emit(LoadingState());
      }
      else if (event is enterAddressEvent){
        emit(enterAddressState(addressText: event.addressText));
      }
      else if(event is uploadImageEvent){
        UploadImage uploadImage = UploadImage(DeliveryRepositoryImpl(DeliveryRemoteDataSourceImpl(http.Client())));
        String url = await uploadImage.call(imagePath: event.imagePath,type: event.type);
        if(url.isNotEmpty){
          emit(uploadImageState(url: url,type: event.type));
        }else{
          emit(uploadImageState(url: "",type: event.type));
        }
        }
      else if(event is getDeliveryPaymentInfo){
        GetPaymentInfo getPaymentInfo = GetPaymentInfo(DeliveryRepositoryImpl(DeliveryRemoteDataSourceImpl(http.Client())));
        PaymentInfoModel paymentInfo = await getPaymentInfo.call(event.deliveryId);
        emit(getDeliveryPaymentInfoState(paymentInfo: paymentInfo));
      }
      else if (event is GetExpiditionModeEvent){
        TarifEntity boatRate = TarifEntity();
        TarifEntity planeRate = TarifEntity();
        //call functions here
        GetShippingRates getShippingRates = GetShippingRates(ShippingRepositoryImpl(ShippingRemoteDataSourceImpl(http.Client())));
        List<TarifEntity> rates = await getShippingRates.call();
        for(var rate in rates) {
          if (rate.mode == Tariftype.plane.value) {
            planeRate = rate;
          } else {
            boatRate = rate;
          }
        }
        emit(GetExpiditionModeState(isBoatActive: boatRate.isActive!, isPlaneActive: planeRate.isActive!));
      }
    });
  }
}
