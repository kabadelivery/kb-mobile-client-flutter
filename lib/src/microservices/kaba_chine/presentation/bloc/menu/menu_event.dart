part of 'menu_bloc.dart';

@immutable
sealed class MenuEvent {}

class changeMenuEvent extends MenuEvent {
  final MenuEnum selectedMenu;

  changeMenuEvent({required this.selectedMenu});
}