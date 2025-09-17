import 'package:KABA/src/microservices/expedition/Enums/status.dart';
import 'package:KABA/src/microservices/expedition/data/expedition/city_model.dart';
import 'package:KABA/src/microservices/expedition/data/expedition/expedition_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../contracts/topup_contract.dart';
import '../../../../ui/screens/home/me/money/TopNewUpPage.dart';
import '../../../../utils/Enums/type_of_transaction.dart';
import '../../core/utils.dart';
import '../../data/expedition/createdby_model.dart';
import '../../data/expedition/line_model.dart';
import '../../data/expedition/package_model.dart';
import '../widget/popAnimation.dart';

class TrackingPackage extends StatefulWidget {
 final  ExpeditionModel expeditionModel;
  const TrackingPackage({required this.expeditionModel,super.key});
  @override
  State<TrackingPackage> createState() => _TrackingPackageState();
}

class _TrackingPackageState extends State<TrackingPackage>  with SingleTickerProviderStateMixin {
  int star_selected = 3;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;
  TextEditingController _commentController = TextEditingController();
  ExpeditionModel expedition = ExpeditionModel();
  List<String> likings = [
    "⚡ Livraison rapide",
    "💰 Prix abordable",
    "👩‍💼  Service client",
    "📱 Facilité d’utilisation",
    "📍 Suivi temps réel",
    "📦 Colis sécurisé"
  ];
  List<int> selected_liking = [];
  @override
  void initState() {
    super.initState();
    expedition = widget.expeditionModel;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 0.2), weight: 20), // 0.2 rad ≈ 11°
      TweenSequenceItem(tween: Tween(begin: 0.2, end: -0.2), weight: 40),
      TweenSequenceItem(tween: Tween(begin: -0.2, end: 0), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onStarTap(int index) {
    setState(() {
      star_selected = index + 1;
    });
    _controller.forward(from: 0); // relance l’animation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,

                    padding:
                    EdgeInsets.only(left: 20, top: 50,bottom: 30),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30)),
                        color: KabaExpeditionColor.primary)
                    ,child: Row(
                    children: [
                      Icon(Icons.arrow_back_sharp,color: Colors.white,size: 19,),
                      SizedBox(width: 10,),
                      Text('Suivis du colis',style: TextStyle(fontSize:16,color: Colors.white,fontWeight: FontWeight.bold),)
                    ],
                  ),
                  ),
                ),
                SizedBox(height: 20),
                PopInWidget(
                  duration: Duration(milliseconds: 500),
                  child: Container(
                    width: 330,
                    height: 160,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: widget.expeditionModel.status==ExpeditionStatus.RECUPERATION_EFFECTUEE.value|| widget.expeditionModel.status==ExpeditionStatus.ACCEPTEE.value? Color(0xFFECFDF5):
                        Color(0xFFFFDCC3),
                        boxShadow: [
                          BoxShadow(
                              color:  widget.expeditionModel.status==ExpeditionStatus.RECUPERATION_EFFECTUEE.value || widget.expeditionModel.status==ExpeditionStatus.ACCEPTEE.value?Color(0xFF01792E).withOpacity(0.2):
                              Color(0xFFFFA358).withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 20,
                              offset: Offset(0, 3)),
                        ]
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right:0,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                                color: widget.expeditionModel.status==ExpeditionStatus.RECUPERATION_EFFECTUEE.value || widget.expeditionModel.status==ExpeditionStatus.ACCEPTEE.value?Color(0xFFD2F9E1)
                                    :Color(0x6EE69027),
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50),topRight: Radius.circular(15))
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                                color: widget.expeditionModel.status==ExpeditionStatus.RECUPERATION_EFFECTUEE.value|| widget.expeditionModel.status==ExpeditionStatus.ACCEPTEE.value?Color(0xFFD2F9E1)
                                    :Color(0x6EE69027),
                                borderRadius: BorderRadius.only(topRight: Radius.circular(50),bottomLeft: Radius.circular(15))
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              SizedBox(height: 20,),
                              PopInWidget(
                                duration: Duration(milliseconds: 1500),
                                child: Container(
                                    width: 60,
                                    height: 60,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(100),
                                        gradient: LinearGradient(
                                            colors: [
                                              widget.expeditionModel.status==ExpeditionStatus.RECUPERATION_EFFECTUEE.value|| widget.expeditionModel.status==ExpeditionStatus.ACCEPTEE.value?
                                              Color(0xFF39CF7B):
                                              Color(0xFFFF926B),
                                              widget.expeditionModel.status==ExpeditionStatus.RECUPERATION_EFFECTUEE.value|| widget.expeditionModel.status==ExpeditionStatus.ACCEPTEE.value?
                                              Color(0xFF00A163):
                                              Color(0xFFFFCF50),
                                            ]


                                        )
                                    ),
                                    child: Center(child: Icon(widget.expeditionModel.status==ExpeditionStatus.RECUPERATION_EFFECTUEE.value|| widget.expeditionModel.status==ExpeditionStatus.ACCEPTEE.value?CupertinoIcons.check_mark_circled:Icons.access_time_rounded,color: Colors.white,size: 40,))
                                ),
                              ),
                              Text(widget.expeditionModel.status==ExpeditionStatus.EN_ATTENTE.value?"Demande en cours":
                                  widget.expeditionModel.status==ExpeditionStatus.EN_COURS_EXPEDITION.value?"En cours d’expedition":
                                      widget.expeditionModel.status==ExpeditionStatus.ARRIVE_EN_VILLE.value?"Arrivé à destination":
                                          widget.expeditionModel.status==ExpeditionStatus.DEPART_CONFIRME.value?"Départ confirmé":
                                              widget.expeditionModel.status==ExpeditionStatus.PAIEMENT.value?"Validation de paiement":
                                                  widget.expeditionModel.status==ExpeditionStatus.NEGOCIATION.value?"En cours de negociation":
                                                      widget.expeditionModel.status==ExpeditionStatus.RECUPERATION_EFFECTUEE.value?"Colis récupéré":
                                                      widget.expeditionModel.status==ExpeditionStatus.ACCEPTEE.value?"Demande acceptée":
                                                      "🥳 Colis livré avec succès"
                                ,style: TextStyle(color:widget.expeditionModel.status==ExpeditionStatus.RECUPERATION_EFFECTUEE.value || widget.expeditionModel.status==ExpeditionStatus.ACCEPTEE.value?Color(0xFF3D6F2E):
                                      Color(0xFF894B00),
                                    fontWeight: FontWeight.bold,fontSize: 18),),
                              SizedBox(height: 15,),
                              Container(
                                  width: 330,
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text("Merci d’avoir choisi KABA Expédition",textAlign: TextAlign.center,

                                    style: TextStyle(fontSize: 14,color: widget.expeditionModel.status==ExpeditionStatus.RECUPERATION_EFFECTUEE.value || widget.expeditionModel.status==ExpeditionStatus.ACCEPTEE.value?Color(0xFF01792E)
                                    :Color(0xFF894B00)),
                                  )),
                              SizedBox(height: 20,),

                            ],
                          ),
                        ),
                        Column(
                          children: [
                            SizedBox(height: 20,),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                PopInWidget(
                  duration: Duration(milliseconds: 1700),
                  child: Container(
                    width: 330,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black38.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 20,
                            offset: Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 330,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(

                            color: Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
                          ),
                          child: Text("Récapitulatif de livraison"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              SizedBox(height:expedition.status=="DELIVERED"? 20:0,),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children:[
                                    Text("Numéro",style: TextStyle(fontSize: 14,color: Colors.black87),),
                                    Text(expedition.trackingNumber.toString().substring(0,10)+"...",style: TextStyle(fontSize: 12,color: Colors.black,fontWeight: FontWeight.bold),),
                                    Row(
                                      children: [
                                        Text("Route : ",style: TextStyle(fontSize: 14,color: Colors.black87),),
                                        Row(
                                          children: [
                                            Text("${expedition.ligne!.depart!.nom.toString()}",style: TextStyle(fontSize: 14,color: Colors.black,fontWeight: FontWeight.bold)),
                                            Icon(Icons.arrow_forward,color: Colors.black,size: 14,),
                                            Text("${expedition.ligne!.arrivee!.nom.toString()}",style: TextStyle(fontSize: 14,color: Colors.black,fontWeight: FontWeight.bold))
                                          ],
                                        )
                                      ],
                                    ),
                                  ]
                              ),
                              SizedBox(height:expedition.status=="DELIVERED"? 20:0,),
                          expedition.status=="DELIVERED"?   Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children:[
                                    Text("Livré le :",style: TextStyle(fontSize: 12,color: Colors.black87),),
                                    Text("${expedition.actualDelivery!.day}/${expedition.actualDelivery!.month}/${expedition.actualDelivery!.year}",style: TextStyle(fontSize: 12,color: Colors.black,fontWeight: FontWeight.bold),),
                                    Row(
                                      children: [
                                        Text("Durée : ",style: TextStyle(fontSize: 12,color: Colors.black87),),
                                        Text("${expedition.createdAt!.difference(expedition.actualDelivery!).inDays}",style: TextStyle(fontSize: 12,color: Color(0xFF01792E),fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ]
                              ):Container(),
                              SizedBox(height: 10,),
                            ],
                          ),
                        ),

                      ],
                    ),

                  ),
                ),
        widget.expeditionModel.status==ExpeditionStatus.NEGOCIATION.value|| widget.expeditionModel.status==ExpeditionStatus.ACCEPTEE.value?
                Container(
                  width: 330,
                  padding: EdgeInsets.all(10),
                  child: MaterialButton(
                      onPressed: ()async{
                        Map results = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TopNewUpPage(presenter: TopUpPresenter(TopUpView()),transactionType: TransactionType.expedition,additionnal_infos: {'delivery_id':expedition.id,},amount_to_send: expedition.colisDetail!.prixFinal,),
                          ),
                        );
                      },
                      color: KabaExpeditionColor.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                      minWidth: 330,
                      child: Text("Procéder au payement",style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.bold))),
                ):Container(),
                widget.expeditionModel.status==ExpeditionStatus.LIVRAISON_AU_DESTINATAIRE?
                Column(
                  children: [
                    SizedBox(height: 20,),
                                   PopInWidget(
                      duration: Duration(milliseconds: 1900),

                      child: Container(
                        width: 330,
                        alignment:Alignment.center,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black38.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 20,
                                  offset: Offset(0, 3)),
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Comment évaluez-vous notre colis ?",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 13),),
                            SizedBox(height:10 ,),
                            Container(
                              alignment: Alignment.center,
                              width: 330,
                              height: 50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(width: 25,),
                                  Flexible(
                                    child: ListView.builder(
                                      itemCount: 5,
                                      scrollDirection: Axis.horizontal,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final isSelected = index < star_selected;

                                        return Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: GestureDetector(
                                            onTap: () => _onStarTap(index),
                                            child: AnimatedBuilder(
                                              animation: _controller,
                                              builder: (context, child) {
                                                return Transform.rotate(
                                                  angle: isSelected ? _shakeAnimation.value : 0,
                                                  child: Transform.scale(
                                                    scale: isSelected ? _scaleAnimation.value : 1.0,
                                                    child: AnimatedContainer(
                                                      duration: const Duration(milliseconds: 200),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        boxShadow: isSelected
                                                            ? [
                                                          BoxShadow(
                                                            color: Colors.amber.withOpacity(0.3),
                                                            blurRadius: 12,
                                                            spreadRadius: 2,
                                                          )
                                                        ]
                                                            : [],
                                                      ),
                                                      child: Icon(
                                                        FontAwesomeIcons.solidStar,
                                                        color: isSelected
                                                            ? const Color(0xFFECB736)
                                                            : Colors.grey.withOpacity(0.5),
                                                        size: 40,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 10,),
                            Container(
                              width: 250,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(0xFFFFF8EC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Color(0xFFFFD467),width: .5),
                              ),
                              child: Text(star_selected==5?"Excellent 🥰":star_selected==4?"Bon😄":star_selected==3?"Moyen😊":star_selected==2?"Médiocre 🙁":"Mauvais 😡",textAlign:TextAlign.center,style: TextStyle(color: Color(0xFF894B00),fontWeight: FontWeight.bold,fontSize: 13),),
                            ),
                            SizedBox(height: 20,),


                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    PopInWidget(
                      duration: Duration(milliseconds: 2100),

                      child: Container(
                        width:330,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black38.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 20,)
                            ]
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Qu'avez-vous aimé ?",style: TextStyle(color: Colors.black,fontSize: 13,fontWeight: FontWeight.bold)),
                              Container(
                                  width: 330,
                                  child: GridView.builder(
                                      itemCount: likings.length,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,childAspectRatio: 2.5,crossAxisSpacing:10,mainAxisSpacing: 15),
                                      itemBuilder: (context,index){
                                        return MaterialButton(
                                          padding: EdgeInsets.all(5),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              side: BorderSide(color: selected_liking.contains(index)?KabaExpeditionColor.primary: Colors.grey.withOpacity(0.5),width: .5)
                                          ),
                                          elevation: 0,
                                          color: selected_liking.contains(index)?KabaExpeditionColor.primary.withOpacity(1):Colors.white,
                                          highlightElevation: 0,
                                          onPressed: (){
                                            setState(() {
                                             if(selected_liking.contains(index)){
                                               selected_liking.remove(index);
                                             }else{
                                               selected_liking.add(index);
                                             }
                                            });
                                          },
                                          child: Text(likings[index],style: TextStyle(fontSize: 12,color:selected_liking.contains(index)?Colors.white: Colors.black),),
                                        );
                                      })
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    PopInWidget(
                      duration: Duration(milliseconds: 2300),

                      child: Container(
                        width: 330,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black38.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 20,)
                            ]
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20,),
                            Text("Commentaire (optionnel)",style: TextStyle(color: Colors.black,fontSize: 14,fontWeight: FontWeight.w100)),
                            SizedBox(height: 20,),
                            TextFormField(
                              controller: _commentController,
                              maxLines: 4,
                              style:TextStyle(fontSize: 12,color: Colors.black87),
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xFFF3F3F5),
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
                                  hintText: "Partagez votre expérience avec Kaba...",
                                  hintStyle: TextStyle(fontSize: 12,color: Colors.grey.shade400),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 10)
                              ),

                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    PopInWidget(
                      duration: Duration(milliseconds: 2500),
                      child: GestureDetector(
                        child: Container(
                          width: 330,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(colors: [
                                Color(0xFFCC1E44),
                                Color(0xFFBC1520)
                              ])
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.paperplane,color: Colors.white,),
                              SizedBox(width: 10),
                              Text("Envoyer mon avis",style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.bold),),

                            ],
                          ),
                        ),
                      ),
                    ),
                    PopInWidget(
                      duration: Duration(milliseconds: 2700),
                      child: Container(
                        width: 330,
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),

                          ),
                          onPressed: (){
                        Navigator.pop(context);

                          },
                          child: Text("Plus tard"),
                        ),
                      ),
                    ),
                  ],
                ):Container(),

              ],
            ),
          ),
        )
    );
  }
}
