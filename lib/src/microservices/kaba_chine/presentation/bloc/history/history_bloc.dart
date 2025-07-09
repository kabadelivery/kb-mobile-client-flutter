import 'dart:math';

import 'package:KABA/src/microservices/kaba_chine/data/order/data_remote_source.dart';
import 'package:KABA/src/microservices/kaba_chine/data/order/delivery_model.dart';
import 'package:KABA/src/microservices/kaba_chine/domain/order/repository.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../../../../../utils/functions/CustomerUtils.dart';
import '../../../functions/getRandomDecoys.dart';
import '../../../usecases/order/get_orders.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(HistoryInitial()) {
    on<HistoryEvent>((event, emit)async {
     if(event is GetHistoryEvent) {
       /*
       *
        List <Delivery> deliveries = [];
        CustomerModel customer = await CustomerUtils.getCustomer();
        bool error = false;
        GetDeliveryHistory getDeliveryHistory = GetDeliveryHistory(DeliveryRepositoryImpl(DeliveryRemoteDataSourceImpl(http.Client())));
        deliveries = await getDeliveryHistory.call(customer.id.toString());
        if(deliveries==null||deliveries.isEmpty) {
          error = true;
          deliveries = [];
        }
       **/

        List<Delivery> fake_delivery = [
          randomizedStatusDecoy(),
          randomizedStatusDecoy(),
          randomizedStatusDecoy(),
          randomizedStatusDecoy(),
        ];
        bool decoy_error  = false;
        emit(GetHistoryState(deliveries: fake_delivery.reversed.toList(), error: decoy_error));
      } else if (event is GetHistoryByIdEvent) {
       }
    });
  }
}
