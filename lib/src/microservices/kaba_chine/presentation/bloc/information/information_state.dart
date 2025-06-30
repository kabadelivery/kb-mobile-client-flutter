part of 'information_bloc.dart';

@immutable
sealed class InformationState {}

final class InformationInitial extends InformationState {}
class getInfosState extends InformationState {
  UserEntity user;
  TarifEntity bookTarif;
  TarifEntity planeTarif;
  getInfosState({required this.user,required this.bookTarif,required this.planeTarif});
}