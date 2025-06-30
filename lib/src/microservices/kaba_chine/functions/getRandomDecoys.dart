import 'dart:math';

import '../Enums/deliveryStatus.dart';
import '../data/order/delivery_model.dart';

DeliveryStatus getRandomDeliveryStatus() {
  final statuses = DeliveryStatus.values;
  final randomIndex = Random().nextInt(statuses.length);
  return statuses[randomIndex];
}

Delivery randomizedStatusDecoy() {
final randomStatus = getRandomDeliveryStatus();
Delivery delivery = Delivery.decoy();
delivery.status = randomStatus.value;
return delivery;
}