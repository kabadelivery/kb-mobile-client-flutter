import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../Enums/menu.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc() : super(MenuInitial()) {
    on<MenuEvent>((event, emit) {
      if(event is changeMenuEvent) {
        emit(MenuChangedState(selectedMenu: event.selectedMenu));
      }
    });
  }
}
