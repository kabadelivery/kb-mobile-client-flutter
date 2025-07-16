import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:KABA/src/microservices/kaba_chine/presentation/bloc/menu/menu_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../Enums/menu.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
Widget MenuWidget({
  required BuildContext context,
  required MenuEnum selectedMenu,
}) {
  MenuEnum currentMenu = selectedMenu;
  MenuBloc menuBloc = BlocProvider.of<MenuBloc>(context);
  return BlocSelector<MenuBloc, MenuState, MenuState>(

  selector: (state) {
    return state;
  },
  builder: (context, state) {

    if(state is MenuChangedState){
      currentMenu = state.selectedMenu;
    }
    return Container(
    width: MediaQuery.of(context).size.width,
    height: 80,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color:Colors.white,
      border:Border(top: BorderSide(
        color: Colors.grey.withOpacity(0.2),
        width: 1,
      )),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap:(){
            if(currentMenu!=MenuEnum.informations){
              menuBloc.add(changeMenuEvent(selectedMenu: MenuEnum.informations));
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.info,
                color: currentMenu==MenuEnum.informations?KabaChineColors.primary:Colors.grey,
                size: 30,
              ),
              SizedBox(height: 5,),
              Text("${AppLocalizations.of(context)!.translate('information')}",
                style: TextStyle(
                  color:  currentMenu==MenuEnum.informations?KabaChineColors.primary:Colors.grey,
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
        GestureDetector(
          onTap:(){
            if(currentMenu!=MenuEnum.demande){
              menuBloc.add(changeMenuEvent(selectedMenu: MenuEnum.demande));
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.truckFast,
                color: currentMenu==MenuEnum.demande?KabaChineColors.primary: Colors.grey,
                size: 30,
              ),
              SizedBox(height: 5,),
              Text("${AppLocalizations.of(context)!.translate('request')}",
                style: TextStyle(
                  color:  currentMenu==MenuEnum.demande?KabaChineColors.primary:Colors.grey,
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
        GestureDetector(
          onTap:(){
            if(currentMenu!=MenuEnum.historique){
              menuBloc.add(changeMenuEvent(selectedMenu: MenuEnum.historique));
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.history,
                color: currentMenu==MenuEnum.historique?KabaChineColors.primary: Colors.grey,
                size: 30,
              ),
              SizedBox(height: 5,),
              Text("${AppLocalizations.of(context)!.translate('history')}",
                style: TextStyle(
                  color: currentMenu==MenuEnum.historique?KabaChineColors.primary: Colors.grey,
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
        GestureDetector(
          onTap:(){
            if(currentMenu!=MenuEnum.discussion){
              menuBloc.add(changeMenuEvent(selectedMenu: MenuEnum.discussion));
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.comment,
                color:  currentMenu==MenuEnum.discussion?KabaChineColors.primary:Colors.grey,
                size: 30,
              ),
              SizedBox(height: 5,),
              Text("${AppLocalizations.of(context)!.translate('discussion')}",
                style: TextStyle(
                  color:  currentMenu==MenuEnum.discussion?KabaChineColors.primary:Colors.grey,
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
      ],
    )
  );
  },
);
}