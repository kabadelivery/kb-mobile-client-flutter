part of 'history_bloc.dart';

@immutable
sealed class HistoryState {}

final class HistoryInitial extends HistoryState {}
final class GetHistoryState extends HistoryState {
  final List<Delivery> deliveries;
  final bool error;
  GetHistoryState({required this.error, required this.deliveries});
}
final class PayForDeliveryState extends HistoryState {
  bool error;
  bool msg;
  PayForDeliveryState({required this.error, required this.msg});
}