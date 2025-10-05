import 'package:KABA/src/microservices/expedition/data/expedition/expedition_model.dart';
import 'package:KABA/src/microservices/expedition/data/expedition/facturation.dart';
import 'package:KABA/src/microservices/expedition/presentation/bloc/expedition/expedition_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/utils.dart';
import '../../data/expedition/city_model.dart';
import '../../data/expedition/createdby_model.dart';
import '../../data/expedition/line_model.dart';
import '../../data/expedition/package_model.dart';
import '../widget/expedition_widget.dart';
import '../widget/popAnimation.dart';

class TrackingPackages extends StatefulWidget {
  const TrackingPackages({super.key});

  @override
  State<TrackingPackages> createState() => _TrackingPackagesState();
}

class _TrackingPackagesState extends State<TrackingPackages> {
  List<ExpeditionModel> expeditions = [
  ];
  ExpeditionBloc expeditionBloc = ExpeditionBloc();
  bool isLoading = true;
  bool error = false;
  @override
  void initState() {
    super.initState();
    expeditionBloc = BlocProvider.of<ExpeditionBloc>(context);
    setState(() {
      isLoading = true;
    });
    expeditionBloc.add(GetUserExpeditionEvent());
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: BlocConsumer<ExpeditionBloc, ExpeditionState>(
          listener: (context, state) {
            if(state is UserExpeditionsLoaded){
              expeditions = state.expeditions;
              isLoading = false;
              error = state.error??false;
            }
          },
          builder: (context, state) {
            return
            Column(

              children: [
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,

                    padding: EdgeInsets.only(left: 20,right: 20,bottom: 20,top: 70),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30)),
                        color: KabaExpeditionColor.primary)
                    ,child: Row(
                    children: [
                      Icon(Icons.arrow_back_sharp,color: Colors.white,size: 19,),
                      SizedBox(width: 10,),
                     Text("Suivi du colis",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 16),)
                    ],
                  ),
                  ),
                ),
                isLoading?
                    Container(
                      width:size.width,
                      height:size.height-240,
                      alignment: Alignment.center,
                      child: Center(child: CircularProgressIndicator()),
                    ):
                error?Container(
                  width:size.width,
                  height:size.height-240,
                  alignment: Alignment.center,
                  child: MaterialButton(
                    color: KabaExpeditionColor.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: KabaExpeditionColor.primary)
                    ),
                    onPressed:(){
                      setState(() {
                        error=false;
                        isLoading=true;
                      });
                      expeditionBloc.add(GetUserExpeditionEvent());
                    },
                    child: Text("Réessayer",style: TextStyle(color: Colors.white),),

                  ),
                ):
                Container(
                  width:size.width,

                  alignment: Alignment.center,
                  child:expeditions.isEmpty?
                  Container(
                    child: Text("Aucun colis pour le moment"),
                  ):
                  Column(
                    children: [
                      SizedBox(height: 20,),
                      Container(
                        width: size.width*.95,
                        height: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Color(0xFFECFDF5),
                            boxShadow: [
                              BoxShadow(
                                  color: Color(0xFF01792E).withOpacity(0.2),
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
                                    color: Color(0xFFD2F9E1),
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
                                    color: Color(0xFFD2F9E1),
                                    borderRadius: BorderRadius.only(topRight: Radius.circular(50),bottomLeft: Radius.circular(15))
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                   Color(0xFF39CF7B),
                                                   Color(0xFF00A163)
                                                ]
                                            )
                                        ),
                                        child: Center(child: Icon(FontAwesomeIcons.box,color: Colors.white,size: 30,))
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Total expéditions"
                                        ,style: TextStyle(color:Color(0xFF3D6F2E),
                                            fontWeight: FontWeight.bold,fontSize: 24),),
                                      SizedBox(height: 5,),
                                      Text("${expeditions.length}",textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 24,color:Color(0xFF01792E),fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20,)

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
                      Container(
                        width:size.width,
                        height:size.height-240,
                        child: ListView.builder(
                            itemCount: expeditions.length,
                            itemBuilder: (context,index){
                              return ExpeditionWidget(context:context,expedition: expeditions[index]);
                            }),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        )
    );
  }
}
