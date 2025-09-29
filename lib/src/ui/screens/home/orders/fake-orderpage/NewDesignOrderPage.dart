import 'package:flutter/material.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
class NewDesignOrderPage extends StatefulWidget {
  @override
  _NewDesignOrderPageState createState() => _NewDesignOrderPageState();
}

class _NewDesignOrderPageState extends State<NewDesignOrderPage> {
  bool deliverNow = true;
  bool showCodeInput = false; // 👈 new state for showing the container
  TextEditingController infoController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  double articlePrice = 2000;
  double deliveryPrice = 2200;
  double extraFees = 0;
  double userBalance = 50;

  @override
  Widget build(BuildContext context) {
    double total = articlePrice + deliveryPrice + extraFees;

    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmer la commande ',style: TextStyle(color:Colors.white , fontSize: 18),),
        backgroundColor: KColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Item
            Card(
              child: ListTile(
                leading: Icon(Icons.fastfood),
                title: Text('Spaghetti dosé'),
                subtitle: Text('x2'),
                trailing: Text('1000 FCFA'),
              ),
            ),

            SizedBox(height: 16),

            // Preparation Time
           

             Container(
              padding: const EdgeInsets.only(
                  top: 15, bottom: 15, left: 12, right: 12), // Adjust padding
              decoration: BoxDecoration(
                
                color: Color(0xFFEFF5FF),
                borderRadius: BorderRadius.circular(21),
                
                border:
                    Border.all(color: Colors.blue),
              ),
              child: Column(
                children: [
                  Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.timer_outlined, color: Colors.blue),
                SizedBox(width:32),
                Text('Temps de préparation '),
                SizedBox(width: 70),
                 Text('30 min',style: TextStyle(color: Colors.red,)),
               /*  ElevatedButton(

                  onPressed: () {},
                  child: Icon(Icons.plus_one_rounded, color: Colors.blue),
                ) */
              ],
            ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Delivery Options
            Container(
               padding: const EdgeInsets.only(
                  top: 15, bottom: 15, left: 0.5, right: 12), // Adjust padding
              decoration: BoxDecoration(
                
                color: Color(0xFFFFFFFFF),
                borderRadius: BorderRadius.circular(21),
                 boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
                
              ),
              child: 
              Column(
              children: [
                RadioListTile<bool>(
                  value: true,
                  groupValue: deliverNow,
                  onChanged: (val) {
                    setState(() {
                      deliverNow = val!;
                    });
                  },
                  title: Text('Commandez et faites-vous livrer maintenant',style: TextStyle(fontSize: 15),),
                ),
                RadioListTile<bool>(
                  value: false,
                  groupValue: deliverNow,
                  onChanged: (val) {
                    setState(() {
                      deliverNow = val!;
                    });
                  },
                  title: Text(
                      'Précommandez et faites-vous livrer à une heure spécifique', style: TextStyle(fontSize: 15))  
                ),
              ],
            )
            ),

            SizedBox(height: 16),

            // Additional Info
            /* TextField(
              controller: infoController,
              decoration: InputDecoration(
                labelText: 'Avez-vous des infos supplémentaires ?',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ), */

             Container(
              padding: const EdgeInsets.only(
                  top: 15, bottom: 15, left: 12, right: 12), // Adjust padding
              decoration: BoxDecoration(
                
                color: Color(0xFFFFE8ED),
                borderRadius: BorderRadius.circular(21),
                
                border:
                    Border.all(color: Colors.red),
              ),
              child: Column(
                children: [
                  Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.chat_bubble_outline_outlined, color: Colors.red),
                SizedBox(width:15),
                Text("Avez vous des Infos Suplementaires ? ",style: TextStyle(fontWeight:FontWeight.normal),),
                SizedBox(width:30),
                 Icon(Icons.keyboard_arrow_down, color: Colors.red),
               /*  ElevatedButton(

                  onPressed: () {},
                  child: Icon(Icons.plus_one_rounded, color: Colors.blue),
                ) */
              ],
            ),
                ],
              ),
            ),

            SizedBox(height: 16),

          Container(
              padding: const EdgeInsets.only(
                  top: 15, bottom: 15, left: 12, right: 12), // Adjust padding
              decoration: BoxDecoration(
                
                color: Color(0xFFEFF5FF),
                borderRadius: BorderRadius.circular(21),
                
                border:
                    Border.all(color: Colors.blue),
              ),
              child: Column(
                children: [
                  Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.place_outlined, color: Colors.blue),
                SizedBox(width:32),
                Text("Choisir l'adresse de Livraison ",style: TextStyle(fontWeight:FontWeight.normal),),
                SizedBox(width:70),
                 Icon(Icons.control_point_outlined, color: Colors.blue),
               /*  ElevatedButton(

                  onPressed: () {},
                  child: Icon(Icons.plus_one_rounded, color: Colors.blue),
                ) */
              ],
            ),
                ],
              ),
            ),
            

            SizedBox(height: 16),

            // Promo / Tip
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showCodeInput = !showCodeInput; // 👈 toggle visibility
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFCC1E44)),
                    child: Text('Ajouter Code Abo.'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFE9A00)),
                    child: Text('Ajouter un don'),
                  ),
                ),
              ],
            ),

            // 👇 The container that appears under the button
            if (showCodeInput) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: codeController,
                      decoration: InputDecoration(
                        hintText: 'Entrez le code ici',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // 👉 handle validation logic here
                        print("Code entré: ${codeController.text}");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text('Valider'),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 16),

            // Invoice Details
            Container(
               decoration: BoxDecoration(

                          color: Color(0xFFFFFFFF), // background color
                          borderRadius: BorderRadius.circular(8),
                          border:
                          Border.all(color: const Color.fromARGB(255, 172, 108, 108)),
                                  boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ]
                        ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Détails de la facture'),
                    SizedBox(height: 22),
                    _buildInvoiceRow('Prix article', articlePrice),
                    _buildInvoiceRow('Prix Livraison', deliveryPrice),
                    _buildInvoiceRow('Frais supplémentaires', extraFees),
                    Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // internal padding
            decoration: BoxDecoration(
              color: Color(0xFFF3F3F5), // grey background
              borderRadius: BorderRadius.circular(8), // small border radius
            ),
            child: Row(
              children: [
              Container(
                
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child:  Text(
                    "Ces frais s'appliquent en cas de pluie, jours fériés,week-end,\n forte demande et la nuit ",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),)  
              ],
    ),
  ),
),
                    Divider(),
                    SizedBox(height: 10),
                    _buildInvoiceRow('Total', total, isTotal: true),
                    SizedBox(height: 13),
                   Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFFFC8D4),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color.fromARGB(255, 173, 46, 46)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40, // small square container
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xFFFFC8D4), // background color
                          borderRadius:
                              BorderRadius.circular(8), // rounded corners
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                              8.0), // inner padding for the image
                          child: Image.asset(
                            "assets/images/png/abonnement-icons/Package.png", // your image
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "💡 Économisez sur vos livraisons !",
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFFCD1F45),
                            ),
                          ),
                          SizedBox(height: 4), // spacing between texts
                          Text(
                            "  Cette livraison vous aurait coûté 0 Franc \n  si vous aviez souscrit à une de nos formules \n  d'abonnement Kaba.",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4), // spacing between texts
                           Text(
                            " ⚡ Economies: 2 300 FCFA",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF00A63E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
               SizedBox(height: 11),
                ElevatedButton(
              onPressed: () {
                // 👉 handle order confirmation logic here
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 173, 46, 46)  ,
                  minimumSize: Size(double.infinity, 30)),
              child: Text(' S’abonner ? '),
            ), ],


              ),
            ),
                  ],
                ),
              ),
              
            ),

            SizedBox(height: 16),

            // Subscription / Savings
            /*   Card(
              color: Colors.red[50],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Économisez sur vos livraisons !',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Cette livraison vous aurait coûté 0 Franc si vous aviez souscrit à une de nos formules d\'abonnement Kaba.'),
                    SizedBox(height: 8),
                    Text('+ Économies: 2 300 FCFA', style: TextStyle(color: Colors.green)),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('S\'abonner ?'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                      ),
                    ),
                  ],
                ),
              ),
            ), */

           

            SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.only(
                  top: 5, bottom: 5, left: 12, right: 12), // Adjust padding
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color.fromARGB(255, 172, 108, 108)),
              ),
              child: Column(
                children: [
                  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Votre solde:'),
                SizedBox(width:8 ),
                Text('$userBalance FCFA',style: TextStyle(color: const Color.fromARGB(255, 173, 46, 46) ),),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('RECHARGER'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 173, 46, 46) ),
                ),
              ],
            ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // User Balance
            ElevatedButton(
              onPressed: () {
                // 👉 handle order confirmation logic here
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 173, 46, 46)  ,
                  minimumSize: Size(double.infinity, 50)),
              child: Text('PAYER LA COMMANDE'),
            ),

            
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('${value.toStringAsFixed(0)} FCFA'),
        ],
      ),
    );
  }
}
