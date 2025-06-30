import 'dart:math';

import 'package:KABA/src/microservices/kaba_chine/data/order/delivery_model.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../functions/getRandomDecoys.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(HistoryInitial()) {
    on<HistoryEvent>((event, emit)async {
      if(event is GetHistoryEvent) {
        List <Delivery> deliveries = [];
        await Future.delayed(Duration(seconds: 2));
        deliveries = [
          randomizedStatusDecoy(),
          randomizedStatusDecoy(),
          randomizedStatusDecoy(),
          randomizedStatusDecoy(),
        ];
        bool error = false;


        emit(GetHistoryState(deliveries: deliveries, error: error));
      } else if (event is GetHistoryByIdEvent) {
       }
    });
  }
}
