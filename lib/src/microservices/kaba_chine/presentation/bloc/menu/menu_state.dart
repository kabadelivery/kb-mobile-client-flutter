part of 'menu_bloc.dart';

@immutable
sealed class MenuState {}

final class MenuInitial extends MenuState {}
class MenuChangedState extends MenuState {
  final MenuEnum selectedMenu;
  MenuChangedState({required this.selectedMenu});
}