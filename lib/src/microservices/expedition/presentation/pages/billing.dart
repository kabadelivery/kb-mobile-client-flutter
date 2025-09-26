import 'package:KABA/src/microservices/expedition/data/expedition/expedition_model.dart';
import 'package:KABA/src/microservices/expedition/data/expedition/remote_data_source.dart';
import 'package:KABA/src/microservices/expedition/domain/expedition/repo.dart';
import 'package:KABA/src/microservices/expedition/presentation/bloc/expedition/expedition_bloc.dart';
import 'package:KABA/src/microservices/expedition/presentation/pages/confirmationPage.dart';
import 'package:KABA/src/microservices/expedition/usecases/createNegociation.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../models/CustomerModel.dart';
import '../../../../utils/functions/CustomerUtils.dart';
import '../../core/utils.dart';
import '../../data/expedition/negociation_model.dart';

class BillingPage extends StatefulWidget {
  final ExpeditionModel expedition;
  const BillingPage({required this.expedition, super.key});
  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  bool negociate=false;
  TextEditingController _negociationPriceController=TextEditingController();
  ExpeditionModel expedition = ExpeditionModel();
  GlobalKey _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    expedition = widget.expedition;
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child:Column(
          children: [
            InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding:
                EdgeInsets.only(left: 20, top: 60,bottom: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30)),
                    color: KabaExpeditionColor.primary)
                ,child: Row(
                children: [
                  Icon(Icons.arrow_back_sharp,color: Colors.white,size: 19,),
                  SizedBox(width: 10,),
                  Text('Facture & Négociation',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
                ],
              ),
              ),
            ),
            SizedBox(height: 20,),
            Container(
              width: 330,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 0.5,color: Colors.grey),
                color: Colors.white
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.fileText,color: KabaExpeditionColor.primary,size: 18,),
                        SizedBox(width: 10,),
                        Text("Récapitulatif de votre expédition",style: TextStyle(fontSize:14,fontWeight: FontWeight.bold),),

                      ],
                    ),
                    SizedBox(height: 10,),
                    //Route
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Route : ",style: TextStyle(color: Colors.black54,fontSize: 14),),
                        Row(
                          children: [
                            Text("${expedition.colis![0].departureTown}", style: TextStyle(fontSize: 14,color: Colors.black)),
                            SizedBox(width: 5,),
                            Icon(Icons.arrow_forward,color: Colors.black,size: 15,),
                            SizedBox(width: 5,),
                            Text("${expedition.colis![0].arrivalTown}",style: TextStyle(fontSize: 14,color: Colors.black)),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 10,),
                    //Weight
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Poids : ",style: TextStyle(color: Colors.black54,fontSize: 14),),
                        Text("${expedition.colis!.map((e) => e.poids).reduce((value, element) => value! + element!).toString()} Kg", style: TextStyle(fontSize: 14,color: Colors.black))
                      ],
                    ),
                    SizedBox(height: 10,),
                    //Quantity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Quantité de colis : ",style: TextStyle(color: Colors.black54,fontSize: 14),),
                        Text("${expedition.colis!.length}", style: TextStyle(fontSize: 14,color: Colors.black))
                      ],
                    ),
                    SizedBox(height: 20,),
                    Container(
                      height: .5,
                      width: 300,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 20,),
                    //Billing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Montant provisoire :",style: TextStyle(fontSize: 14,color:Colors.black,fontWeight: FontWeight.bold),),
                        Text("25000 FCFA",style: TextStyle(fontSize: 14,color:Color(0xFFCD1F45),fontWeight: FontWeight.bold,decorationColor:KabaExpeditionColor.primary, decoration: negociate?TextDecoration.lineThrough:null),)

                      ],
                    ),

                    //Negociation
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          negociate?
                              TextFormField(
                                controller: _negociationPriceController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d+[\.,]?\d{0,}$')),
                                ],
                                validator: (value){
                                  if(value==null || value.isEmpty){
                                    return "Veuillez entrer un montant correct";
                                  }
                                  return null;
                                },
                                onChanged: (value){
                                  setState(() {
                                    _negociationPriceController.text = value;
                                  });
                                },
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Color(0xFFFFFFFF),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: KabaExpeditionColor.primary,width: 1)
                                    ),
                                    border:OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: KabaExpeditionColor.primary,width: 1)
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: KabaExpeditionColor.primary,width: 1)
                                    ),
                                    hintText: "Entrez votre proposition (Ex :20 000 CFA)",
                                    hintStyle: TextStyle(fontSize: 12,color: Colors.grey.shade400),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 10)
                                ),

                              )
                              :Container(),
                          negociate?
                          Container(
                            width: 330,
                            child: MaterialButton(
                                elevation: 0,
                                color: KabaExpeditionColor.primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Text(isLoading?"Envoie en cours...":"Envoyer la proposition",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color:Colors.white),),
                                onPressed: ()async{
                                  setState(() {
                                    isLoading = true;
                                  });
                                  NegotiationModel negotiationModel = NegotiationModel(
                                      expeditionId: expedition.id!,
                                      montantPropose:
                                      double.parse(_negociationPriceController.text),
                                      raison: "Négociation du prix de l'expédition");
                                  CreateNegociation createNegociation = CreateNegociation(
                                    ExpeditionRepositoryImpl(
                                      ExpeditionRemoteDataSourceImpl()
                                    )
                                  );
                                  CustomerModel customerToken = await CustomerUtils.getCustomer();
                                  await createNegociation.call(body: negotiationModel.toJson(), customerToken: customerToken.token!).then((_){
                                    Navigator.of(context).pushReplacement(PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) => Confirmationpage(),
                                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                          var begin = Offset(1.0, 0.0);
                                          var end = Offset.zero;
                                          var curve = Curves.ease;
                                          var tween = Tween(begin: begin, end: end);
                                          var curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
                                          return SlideTransition(
                                              position: tween.animate(curvedAnimation),
                                              child: child
                                          );
                                        }
                                    ));
                                  }).catchError((error){
                                    debugPrint("XXX Error ${error.toString()}");
                                    CherryToast.error(
                                      title: Text("Une erreur s'est produite",style: TextStyle(color: Colors.black87),),
                                    ).show(context);
                                  });
                                  setState(() {
                                    isLoading = false;
                                  });

                                }),
                          ):Container(),
                        ],
                      ),
                    )

                  ],
                ),
              ),
            ),
            SizedBox(height: 20,),
            Container(
              width: 330,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: KabaExpeditionColor.primary,width: 0.5)
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline_outlined,color: KabaExpeditionColor.primary,size: 22,),
                  SizedBox(width: 10,),
                  Flexible(child: Text("Ce montant est provisoire et peut être ajusté après vérification de votre colis par nos équipes",
                  style: TextStyle(fontSize: 14),))
                ],
              ),
            ),
            !negociate? Container(
              width: 330,
              child: MaterialButton(
                  elevation: 0,
                  color: KabaExpeditionColor.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline_rounded,color: Colors.white,size: 19,),
                      SizedBox(width: 5,),
                      Text("Accepter et continuer",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color:Colors.white),)
                    ],
                  ),
                  onPressed: (){
                    Navigator.of(context).pushReplacement(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => Confirmationpage(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          var begin = Offset(1.0, 0.0);
                          var end = Offset.zero;
                          var curve = Curves.ease;
                          var tween = Tween(begin: begin, end: end);
                          var curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
                          return SlideTransition(
                              position: tween.animate(curvedAnimation),
                              child: child
                          );
                        }
                    ));
                  }),
            ):Container(),
            !negociate? Container(
              width: 330,

              child: MaterialButton(
                  highlightElevation: 0,
                  elevation: 0,
                  highlightColor: KabaExpeditionColor.primary.withOpacity(0.2),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(width: 0.5,color:KabaExpeditionColor.primary)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.chat_bubble,color: KabaExpeditionColor.primary,size: 19,weight: 3,),
                      SizedBox(width: 5,),
                      Text("Négocier le prix",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color:KabaExpeditionColor.primary),)
                    ],
                  ),
                  onPressed: (){
                    setState(() {
                      negociate = !negociate;
                    });
                  }),
            ):Container()

          ],
        )

    )
    );
  }
}
