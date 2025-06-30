import 'package:KABA/src/microservices/kaba_chine/Enums/menu.dart';
import 'package:KABA/src/microservices/kaba_chine/presentation/pages/chat_list.dart';
import 'package:KABA/src/microservices/kaba_chine/presentation/pages/history_page.dart';
import 'package:KABA/src/microservices/kaba_chine/presentation/pages/information_page.dart';
import 'package:KABA/src/microservices/kaba_chine/presentation/pages/order_page.dart';
import 'package:KABA/src/microservices/kaba_chine/presentation/widgets/menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/menu/menu_bloc.dart';

class WelcomeToKabaChine extends StatefulWidget {
  static var routeName = "/WelcomeToKabaChine";

  const WelcomeToKabaChine({super.key});

  @override
  State<WelcomeToKabaChine> createState() => _WelcomeToKabaChineState();
}

class _WelcomeToKabaChineState extends State<WelcomeToKabaChine> {
  MenuEnum selectedMenu = MenuEnum.informations;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 80,
              child: BlocSelector<MenuBloc, MenuState, MenuState>(
                selector: (state) {
                  return state;
                },
                builder: (context, state) {
                  if (state is MenuChangedState) {
                    selectedMenu = state.selectedMenu;
                    final newIndex = MenuEnum.values.indexOf(state.selectedMenu);
                    if (_pageController.hasClients && _pageController.page?.round() != newIndex) {
                    _pageController.animateToPage(
                    newIndex,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    );
                  }
                  }
                  return PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      context.read<MenuBloc>().add(changeMenuEvent(selectedMenu: MenuEnum.values[index]));
                    },
                    children: [
                      UserInformationPage(),
                      KabaChineOrderPage(),
                      DeliveryHistory(),
                      AllChatPage(),
                    ],
                  );
                }
              ),
            ),
            Positioned(
                left: 0,
                bottom: 0,
                child: MenuWidget(context: context,
                  selectedMenu: selectedMenu,
                )),
          ]
      ),
    );
  }
}
