import 'package:KABA/src/microservices/expedition/data/expedition/package_model.dart';
import 'package:KABA/src/microservices/expedition/presentation/bloc/expedition/expedition_bloc.dart';
import 'package:KABA/src/microservices/expedition/presentation/pages/billing.dart';
import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kkiapay_flutter_sdk/utils/config.dart' as KColors;

import '../../Enums/expedition_type.dart';
import '../../core/utils.dart';
import '../../data/expedition/create_expedition_model.dart';
import '../widget/estimation_math.dart';
import '../widget/expedition_detail_form.dart';

class Expedition extends StatefulWidget {
  final ExpeditionType type;
  const Expedition({required this.type, super.key});

  @override
  State<Expedition> createState() => _ExpeditionState();
}

class _ExpeditionState extends State<Expedition> {
  int step = 1;
  List<PackageModel> packages = [
    PackageModel()
  ];
  ExpeditionBloc expeditionBloc = ExpeditionBloc();
  CreateExpedition createExpedition = CreateExpedition();
  @override
  void initState() {
    BlocProvider.of<ExpeditionBloc>(context).add(ExpeditionInitialEvent());
    expeditionBloc = BlocProvider.of<ExpeditionBloc>(context);
    expeditionBloc.add(getAvailableLines());
    super.initState();
  }
  @override
  void dispose() {
    BlocProvider.of<ExpeditionBloc>(context).add(ExpeditionInitialEvent());
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    expeditionBloc.stream.listen((state){
      if (state is ExpeditionInitial) {}
      else if (state is ExpeditionCreated) {
      } else if (state is NegociationCreated) {
      } else if (state is PackagesUpdatedState) {
        createExpedition.colis = state.packages;
      }
      else if (state is chooseShippingMethodState) {
        createExpedition.methodeCollecte = state.method;

      } else if (state is chooseShippingMethodAddressTypeState) {
        createExpedition.adresseOrigine = state.coords;
      }
      else if(state is enterSendPhoneNumberState){
        createExpedition.telephoneOrigine = state.phoneNumber;
      }
      else if (state is chooseFetchDateState) {
        createExpedition.dateCollecte = state.date;
      } else if (state is chooseFetchTimeState) {
        createExpedition.heureCollecte = state.hour;
      }

    });
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
                children: [
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                    width: MediaQuery.of(context).size.width,

                    padding:
                        EdgeInsets.only(left: 20,right:20 ,bottom: 20,top: 50),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30)),
                        color: KabaExpeditionColor.primary)
                ,child: Row(
                  children: [
                    Icon(Icons.arrow_back_sharp,color: Colors.white,size: 19,),
                    SizedBox(width: 10,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.type==ExpeditionType.international?"Expédition Internationale":"Expédition Nationale",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                        Text("Etape $step sur 2",style: TextStyle(color: Colors.white,fontSize: 12),)
                      ],
                    )
                  ],
                ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color:Colors.grey.withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          height: 35,
                          width: 35,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: KabaExpeditionColor.primary,
                            shape: BoxShape.circle,

                          ),
                          child:step==2?Icon(Icons.check,color: Colors.white,size: 19,weight: 2,): Text("1",style: TextStyle(color: Colors.white,fontWeight:FontWeight.bold), textAlign: TextAlign.center,),
                        ),
                        Container(
                          height: 2,
                          width: 210,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                KabaExpeditionColor.primary,

                               step==2?KabaExpeditionColor.primary: Colors.grey.withOpacity(0.7),
                              ]
                            ),
                            borderRadius: BorderRadius.circular(2)
                          ),
                        ),
                        Container(
                          height: 35,
                          width: 35,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: step==2? KabaExpeditionColor.primary:Colors.grey.withOpacity(0.3),
                              shape: BoxShape.circle
                          ),
                          child: Text("2",style: TextStyle(color:step==2?Colors.white:
                          Colors.black38,fontWeight:FontWeight.bold), textAlign: TextAlign.center,),
                        ),

                          ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: 60,
                            child: Text("Détails du colis",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 10,color: KabaExpeditionColor.primary,fontWeight: FontWeight.bold),)),
                        Container(
                            width: 60,
                            child: Text("Destination & Poids",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 10,color: step==2? KabaExpeditionColor.primary: Colors.black54,fontWeight: FontWeight.bold),)),

                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 10,),
           step==1?   Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Container(margin: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                        width:330,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color:KabaExpeditionColor.primary.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 5,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: EstimationForm()),
                      SizedBox(height: 20,),
                      Container(
                        width: 330,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blueAccent.shade700,width: .5)
                        ),
                        child:Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline,color: KabaExpeditionColor.primary,),
                                SizedBox(width: 10,),
                                Text("Important",style: TextStyle(fontWeight: FontWeight.bold),)
                                ],
                            ),
                            Text("Votre facture peut changer en fonction de la nature et du conditionnement de votre colis.",style: TextStyle(fontSize: 12,color: Colors.black), textAlign: TextAlign.justify),

                          ],
                        )),
                      SizedBox(height: 20,),
                      Container(
                        width: 330,
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: (){
                                  if(step==1){
                                    setState(() {
                                      step=2;
                                    });
                                  }else{
                                    Navigator.pop(context);
                                  }
                                },
                                child: Container(
                                  height: 45,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey,width: .5),
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Text("Annuler",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold),),
                                ),
                              ),
                            ),
                            SizedBox(width: 20,),
                            Expanded(
                              child: InkWell(
                                onTap: (){
                                  if(step==1){
                                    setState(() {
                                      step=2;
                                    });
                                  }else{
                                    Navigator.pop(context);
                                  }
                                },
                                child: Container(
                                  height: 45,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: KabaExpeditionColor.primary,
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(step==1?"Continuer":"Finaliser",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                      SizedBox(width: 5,),
                                      Icon(Icons.arrow_forward,color: Colors.white,size: 15,)
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 50,),
                       ],
                  ),
                ),
              )
           :Expanded(
             child: SingleChildScrollView(
             child: Column(
               children: [
                 SizedBox(height: 10,),
                 Container(
                     width: 330,
                     child: PackageSelector()),
                 BlocConsumer<ExpeditionBloc, ExpeditionState>(
                   bloc: expeditionBloc,
                   listener: (context, state) {
                     if(state is PackagesUpdatedState){
                       packages = state.packages;
                     }
                     if(state is ExpeditionInitial){
                       step = 1;
                       packages = [
                         PackageModel()
                       ];
                     }
                   },
                   builder: (context, state) {
                     return Container(
                       width: 330,
                       child: Column(
                         children: packages
                             .asMap()
                             .entries
                             .map((entry) => Padding(
                           padding: const EdgeInsets.symmetric(vertical: 8.0),
                           child: ExpeditionDetailForm(index: entry.key),
                         ))
                             .toList(),
                       ),
                     );
                   },

                 ),
                 SizedBox(height: 10),
                 PickUpOptions(),
                 SizedBox(height: 10,),
                 Container(
                   width: 350,
                   child: MaterialButton(
                     color: KabaExpeditionColor.primary,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(10)

                     ),
                     elevation: 0,
                     onPressed: (){
                       Navigator.of(context).push(PageRouteBuilder(
                           pageBuilder: (context, animation, secondaryAnimation) => BillingPage(),
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
                     },
                     child: Container(
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(Icons.check_circle_outline_rounded,color: Colors.white,),
                           SizedBox(width: 10,),
                           Text("Continuer et Négocier ?",style: TextStyle(color: Colors.white,),),
                           ],
                       ),
                     ),
                   ),
                 ),
                 SizedBox(height: 20,),
               ],
             ),
           )),
            ]
            )
        )
    );
  }
}
