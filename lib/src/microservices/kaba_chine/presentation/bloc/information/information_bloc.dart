import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:KABA/src/microservices/kaba_chine/data/user/user_model.dart';
import 'package:KABA/src/microservices/kaba_chine/domain/tarif/repository.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../../../Enums/TarifType.dart';
import '../../../data/tarif/data_remote_source.dart';
import '../../../domain/tarif/tarif_entity.dart';
import '../../../domain/user/user_entity.dart';
import '../../../usecases/tarif/get_tarif.dart';

part 'information_event.dart';
part 'information_state.dart';

class InformationBloc extends Bloc<InformationEvent, InformationState> {
  InformationBloc() : super(InformationInitial()) {
    on<InformationEvent>((event, emit) async{
      if(event is getInfosEvent){
        String customerCode = "TG-XXXXXXX";
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
        debugPrint("Active Rates ${rates.toString()}");

        CustomerModel customerModel = await CustomerUtils.getCustomer();
        customerCode = "TG-"+customerModel.phone_number!;//decoy
        UserEntity user = UserEntity(customer_code: customerCode,name: customerModel.nickname,phone_number: customerModel.phone_number);
        UserModel userModel = UserModel(
          customer_code: user.customer_code,
          name: user.name,
          phone_number: user.phone_number,
        );
        KabaChineUtils().SaveUserInfo(userModel);
        emit(getInfosState(user: user, bookTarif: boatRate, planeTarif: planeRate));
      }
    });
  }
}
