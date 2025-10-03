import 'package:KABA/src/microservices/expedition/data/expedition/expedition_model.dart';
import 'package:KABA/src/microservices/expedition/data/expedition/package_model.dart';
import 'package:KABA/src/microservices/expedition/domain/expedition/repo.dart';
import 'package:KABA/src/microservices/expedition/presentation/bloc/expedition/expedition_bloc.dart';
import 'package:KABA/src/microservices/expedition/presentation/pages/billing.dart';
import 'package:KABA/src/microservices/expedition/presentation/pages/homepage.dart';
import 'package:KABA/src/microservices/expedition/usecases/create_expedition.dart';
import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:KABA/src/microservices/kaba_chine/presentation/bloc/chat/chat_bloc.dart';
import 'package:KABA/src/ui/screens/home/HomePage.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kkiapay_flutter_sdk/utils/config.dart' as KColors;

import '../../../../models/CustomerModel.dart';
import '../../../../ui/customwidgets/LoadingPopUp.dart';
import '../../../../utils/functions/CustomerUtils.dart';
import '../../Enums/expedition_type.dart';
import '../../core/utils.dart';
import '../../data/expedition/create_expedition_model.dart';
import '../../data/expedition/remote_data_source.dart';
import '../../functions/error_handler_message.dart';
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
  bool isLoading = false;
  @override
  void initState() {
    BlocProvider.of<ExpeditionBloc>(context).add(ExpeditionInitialEvent());
    expeditionBloc = BlocProvider.of<ExpeditionBloc>(context);
    expeditionBloc.add(getAvailableLines());
    super.initState();
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
        createExpedition.adresseDestination = "319 Rue AGP, Agbalépédo, Lomé TOGO";

      } else if (state is chooseShippingMethodAddressTypeState) {
        createExpedition.adresseOrigine = state.coords;
      }
      else if(state is enterSendPhoneNumberState){
        createExpedition.telephoneOrigine = state.phoneNumber;
        debugPrint("phone number ${state.phoneNumber}");
      }
      else if (state is chooseFetchDateState) {
        createExpedition.dateCollecte = state.date;
      } else if (state is chooseFetchTimeState) {
        createExpedition.heureCollecte = state.hour;
      }

    });
    return WillPopScope(
      onWillPop: ()async{
         Navigator.of(context).pushReplacement(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => KabaExpeditionHomePage(),
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
        return true;
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          body:Container(
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
                          EdgeInsets.only(left: 20,right:20 ,bottom: 20,top: 60),
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
                            width: 220,
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
                              width: 80,
                              child: Text(step==2?"Destination":"Estimation",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12,color: KabaExpeditionColor.primary,fontWeight: FontWeight.bold),)),
                          Container(
                              width: 80,
                              child: Text("Détails du colis",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12,color: step==2? KabaExpeditionColor.primary: Colors.black54,fontWeight: FontWeight.bold),)),

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
                        Container(
                            margin: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                          width:350,
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
                          width: 350,
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: KabaExpeditionColor.primary.withOpacity(.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: KabaExpeditionColor.primary,width: .5)
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
                              Text("Ce coût prend en compte la récupération de votre colis, l’expédition et la livraison à l’adresse exacte du destinataire.  Il peut changer en fonction de la nature et du conditionnement de votre colis",
                                  style: TextStyle(fontSize: 14,color: Colors.black), textAlign: TextAlign.justify),
                            ],
                          )),
                        SizedBox(height: 20,),
                        Container(
                          width: 350,
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
                       width:MediaQuery.of(context).size.width,
                       padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.08),
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
                         width: 350,
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
                   handleExpeditionFormMessage(createExpedition).isNotEmpty?  Container(
                     width: 350,
                      decoration: BoxDecoration(
                        color: KabaExpeditionColor.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: KabaExpeditionColor.primary.withOpacity(1),width: .5),

                      ),
                      padding: EdgeInsets.all(15),
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.infoCircle,color: KabaExpeditionColor.primary,size: 15,),
                          SizedBox(width: 10,),
                          Flexible(
                            child: Text(handleExpeditionFormMessage(createExpedition)
                              ,style:
                            TextStyle(color: KabaExpeditionColor.primary),),
                          ),
                        ],
                      ),
                   ):Container(),
               Container(
                     width: 350,
                     child: MaterialButton(
                       color: KabaExpeditionColor.primary,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(10)

                       ),
                       elevation: 0,
                       onPressed: ()async{
                         String message =handleExpeditionFormMessage(createExpedition);
                         if(message.isEmpty){
                           setState(() {
                             isLoading = true;
                           });

                             await Future.delayed(Duration(milliseconds: 500));
                             CustomerModel customer = await CustomerUtils.getCustomer();
                             CreateExpeditionUseCase createExpeditionUseCase = CreateExpeditionUseCase(ExpeditionRepositoryImpl(ExpeditionRemoteDataSourceImpl()));
                           List<ExpeditionModel> expeditionModels = [];
                            try{
                              List<ExpeditionModel> expeditionModels = await createExpeditionUseCase.call(
                                body: createExpedition,
                                customer: customer,
                              );
                              expeditionModels = expeditionModels.map((exp) {
                                exp.colis = createExpedition.colis;
                                return exp;
                              }).toList();
                              Navigator.of(context).pushReplacement(PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => BillingPage(

                                      expedition:expeditionModels
                                  ),
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
                            }catch(e){
                              debugPrint("XXX ERROR CREATING EXPEDITION ${e}");
                              CherryToast.error(
                                title: Text("Erreur lors de la création de l'expedition"),
                                toastPosition: Position.center,
                              ).show(context);
                              setState(() {
                                isLoading =false;
                              });
                            }
                         }else{
                           setState(() {
                           });
                         }
                       },
                       child: Container(
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Icon(Icons.check_circle_outline_rounded,color: Colors.white),
                             SizedBox(width: 10,),
                             Text(isLoading?"Création en cours...":"Continuer et Négocier ?",style: TextStyle(color: Colors.white,),),
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
      ),
    );
  }
}
