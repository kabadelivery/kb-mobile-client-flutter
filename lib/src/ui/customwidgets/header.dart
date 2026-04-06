import 'package:KABA/src/ui/customwidgets/performance_ui.dart';
import 'package:KABA/src/ui/screens/chat/ChatPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../StateContainer.dart';
import '../../contracts/transaction_contract.dart';
import '../../localizations/AppLocalizations.dart';
import '../../microservices/expedition/presentation/widget/contact.dart';
import '../../models/CustomerModel.dart';
import '../../resources/socket/sockets.dart';
import '../../utils/_static_data/AppConfig.dart';
import '../../utils/_static_data/KTheme.dart';
import '../../utils/functions/CustomerUtils.dart';
import '../../utils/functions/NotLoggedInPopUp.dart';
import '../../utils/functions/Utils.dart';
import '../../utils/functions/popups.dart';
import '../screens/chat/ChatPage.dart';
import '../screens/home/me/abonnement/kaba_abonnements.dart';
import 'performance_ui.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  Map<String, dynamic>? performance;
  String userId = '';
  int unreadMessages = 0;

  @override
  void initState() {
    super.initState();
    getPerf();
    _loadCustomer();
    SocketService().unreadStream.listen((count) {
      if (mounted) {
        setState(() {
          unreadMessages = count;
        });
      }
    });
  }

  Future<void> _loadCustomer() async {
    CustomerModel customer = await CustomerUtils.getCustomer();
    setState(() {
      userId = customer.phone_number.toString();
    });

    if (userId.isNotEmpty) {
      SocketService().init(userId);
    }
  }

  void getPerf() async {
    performance = await Utils.getAppPerformance();
    CustomerModel customerModel = await CustomerUtils.getCustomer();
     setState(() {});
  }

  void _resetUnread() {
    SocketService().resetUnread();
  }

  void _navigateToChat() {
    if (StateContainer.of(context).loggingState == 0) {
      NotLoggedInPopUp(context);
      return;
    }

    _resetUnread();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(token: '', receiverId: 92109474),
      ),
    );
  }

  void _showBottomContactSheet(BuildContext context) {
    // Keep your existing implementation
  }

  @override
  Widget build(BuildContext context) {
//    WidgetsBinding.instance.addPostFrameCallback((_){
//       getPerf();
//     });
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: KColors.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          performance != null
              ? GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IntrinsicWidth(
                    child: IntrinsicHeight(
                      child: PerformanceCard(
                        currentRating: double.parse(performance!['final'].toString())==0?3.0:double.parse(performance!['final'].toString()),
                        reviewCount: performance!['count'],
                        speed: double.parse(performance!['speed'].toString()),
                        geolocationRespect: double.parse(performance!['geolocation'].toString()),
                        attitude: double.parse(performance!['attitude'].toString()),
                        appearance:double.parse( performance!['appearance'].toString()),
                      ),
                    ),
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFCF2A4E),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(FontAwesomeIcons.boltLightning,
                      color: Colors.orangeAccent, size: 14),
                  Text(
                    "${performance!['final']==0?3:performance!['final']}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "/5",
                    style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
              : const SizedBox.shrink(),
          Container(
            width: 170,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Abonnement button
                GestureDetector(
                  onTap: () {
                    showModernPopup(title: AppLocalizations.of(context)!.translate("t_unavailable"),context: context, text: "${AppLocalizations.of(context)!.translate('service_unavailable')}", icon:Icon( FontAwesomeIcons.lock));
                    /*
                    * Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Kaba_abonnement(presenter: TransactionPresenter(TransactionView())),
                      ),
                    );
                    * */
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/png/abo_white.png", width: 25, height: 25),
                      const Text(
                        "Abo.",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 20, color: Colors.white),

                // Chat button with persistent unread badge
                GestureDetector(
                  onTap: _navigateToChat,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 25),
                          if (unreadMessages > 0)
                            Positioned(
                              right: -2,
                              top: -5,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unreadMessages.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      color: KColors.primaryColor),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Text(
                        "Chat",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 20, color: Colors.white),

                // Call button
                GestureDetector(
                  onTap: () => showBottomContactSheet(context: context, number: '+228${AppConfig.CUSTOMER_CARE_PHONE_NUMBER}'),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.call_outlined, color: Colors.white),
                      Text(
                        "Call",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
