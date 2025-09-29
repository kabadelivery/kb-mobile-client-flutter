 import 'package:KABA/src/contracts/login_contract.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:kkiapay_flutter_sdk/utils/config.dart' as KColors;

class Modal_2_connect extends StatelessWidget {
    const Modal_2_connect({super.key});

  @override
  Widget build(BuildContext context) {
   return AlertDialog(
              
              content:
              
               SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    /* add an image*/
                    // location_permission
                   Stack(
  clipBehavior: Clip.none, // allow icons to overflow outside container
  children: [
    // The main container
    Container(
      margin: const EdgeInsets.only(left: 90, right: 90, top: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFCD1F45),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: const Icon(
        Icons.shield_outlined,
        color: Colors.white,
        size: 50,
      ),
    ),

    // ⭐ Top right star
    const Positioned(
      top: 5,  // move it a bit outside
      right: 70,
      child: Icon(
        Icons.auto_awesome_outlined,
        color: const Color(0xFFCD1F45),
        size: 24,
      ),
    ),

    // ⭐ Bottom left star
    const Positioned(
      bottom: -13,
      left: 60,
      child: Icon(
        Icons.auto_awesome_outlined,
        color: const Color(0xFFCD1F45),
        size: 24,
      ),
    ),
  ],
)
 ,

                        
                
                const SizedBox(height: 20), // Title
                      RichText(
  textAlign: TextAlign.center,
  text: TextSpan(
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.black87, // default color
    ),
    children: const [
      TextSpan(text: "Accès sécurisé "),
      TextSpan(
        text: "KABA",
        style: TextStyle(color: const Color(0xFFCD1F45)), // only KABA in red 
      ),
    ],
  ),
),
              const SizedBox(height: 8), // Subtitle
              const Text(
                "Vous devez vous connecter pour avoir accès à votre compte KABA",
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              
                    
                    /* Text(
                        "${AppLocalizations.of(context)!.translate(msg[value % 2])}",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14)) */
                  ],
                ),
              ),
              actions: <Widget>[

                ElevatedButton.icon( 
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCD1F45),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {
                 Navigator.of(context).pop();

                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            LoginPage(presenter: LoginPresenter(LoginView()))));
                },
                icon: const Icon(Icons.person_outline),
                label: const Text("Se connecter =>"),
                
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                 Navigator.of(context).pop();
                },
                
                label: const Text("Pas Maintenant "),
              )
           
                /* TextButton(
                  child: Text(
                      "${AppLocalizations.of(context)!.translate('not_now')}"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ) */ 
                /* TextButton(
                  child: Text(
                      "${AppLocalizations.of(context)!.translate('login')}"),
                  onPressed: () {
                    /* */
                    /* jump to login page... */
                    Navigator.of(context).pop();

                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            LoginPage(presenter: LoginPresenter(LoginView()))));
                  },
                ) */
              ],
            );
  }
}
