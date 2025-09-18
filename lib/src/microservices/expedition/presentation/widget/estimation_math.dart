import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:KABA/src/microservices/kaba_chine/presentation/bloc/order/order_bloc.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../kaba_chine/presentation/widgets/package_form_info.dart';
import '../../core/utils.dart';
import '../../data/expedition/line_model.dart';
import '../bloc/estimation/estimation_bloc.dart';

class EstimationForm extends StatefulWidget {
  const EstimationForm({super.key});

  @override
  State<EstimationForm> createState() => _EstimationFormState();
}

class _EstimationFormState extends State<EstimationForm> {
  GlobalKey _formKey = GlobalKey<FormState>();
  TextEditingController _weight = TextEditingController();
  String? selected_departure_town="Lomé";
  String selected_arrival_town ="Accra";
  double? estimation_price =null;
  List<Map<String,String>> map_of_town_arrival= [
  ];
  List<Map<String,String>> map_of_town_departure= [
  ];
  List<LineModel>availableLines=[];
  bool error = false;
  EstimationBloc estimationBloc = EstimationBloc();
  bool isLoading = false;
  @override
  void initState() {
    estimationBloc = BlocProvider.of<EstimationBloc>(context);
    estimationBloc.add(InitEstimationEvent());
    estimationBloc.add(getAvailableLines());
    super.initState();
  }
  @override
  void dispose(){
    _weight.dispose();
    estimationBloc.add(InitEstimationEvent());
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    estimationBloc = BlocProvider.of<EstimationBloc>(context);
    return  Form(
      key: _formKey,
      child: BlocSelector<EstimationBloc, EstimationState,EstimationState>(
  selector: (state) {
   return state;
  },
  builder: (context, state) {
    debugPrint("XXX state ${state}");
    if(state is DepartureTownChosen){
      selected_departure_town = state.town;
    }
    if(state is ArrivalTownChosen){
      selected_arrival_town = state.town;
    }
    if(state is EstimationCalculated){
      estimation_price =state.result.prixFinal;
    }
    if(state is getAvailableLinesState){
      if(state.lines.isNotEmpty){
        debugPrint("XXX state lines${state.lines}");
        availableLines = state.lines;
        selected_departure_town= state.lines[0].depart!.nom??"";
        selected_arrival_town= state.lines[0].arrivee!.nom??"";
        map_of_town_arrival.clear();
        map_of_town_departure.clear();
        error = false;
        isLoading = false;
        for(LineModel line in state.lines){
          Map<String,String> lineDepartureMap =  {"id":"${line.id}","name":line.depart!.nom??"","country_code":line.depart!.pays!['code']??"",'country':line.depart!.pays!['nom']};
          Map<String,String> lineArrivalMap =  {"id":"${line.id}","name":line.arrivee!.nom??"","country_code":line.arrivee!.pays!['code']??"",'country':line.arrivee!.pays!['nom']};

          if (!map_of_town_departure.any((m) => m["name"] == line.depart!.nom)) {
            map_of_town_departure.add(lineDepartureMap);
          }
          if (!map_of_town_arrival.any((m) => m["name"] == line.arrivee!.nom)) {
            map_of_town_arrival.add(lineArrivalMap);
          }
        }
      }else{
        error = true;
        isLoading = false;
      }
    }
    if(state is EstimationInitial){
      estimation_price =null;
      selected_departure_town="Lomé";
      selected_arrival_town ="Accra";
    }
    return Container(
        width: 330,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(10),topLeft:Radius.circular(10) ),
                  color: KabaExpeditionColor.primary.withOpacity(0.1)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Color(0xFFCD1F45).withOpacity(0.1)
                    ),
                    child: Icon(FontAwesomeIcons.calculator,color: Color(0xFFCD1F45).withOpacity(.8),),
                  ),
                  SizedBox(width: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text("Calculer votre estimation",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.black87),),
                      SizedBox(height: 5,),
                      Text("Prix transparent et compétitif",style: TextStyle(fontSize: 13,color: Colors.black54),)
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  FormTitleWithIcon(title: "Ville de départ", icon: Icon(Icons.location_on_outlined,color: Color(0xFFCD1F45),)),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    width: 330,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Color(0xFFCD1F45).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 1,color: Color(0xFFCD1F45).withOpacity(0.6),
                        )),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButton<String>(
                      hint: Text("Sélectionner la ville de départ"),
                      value: selected_departure_town,
                      isExpanded: true,
                      elevation: 16,
                      underline: Container(
                        height: 0,
                      ),
                      icon: Icon(Icons.keyboard_arrow_down_outlined,color: Color(0xFFCD1F45),),
                      items: map_of_town_departure.map((town){
                        return DropdownMenuItem<String>(
                            value: town['name'],
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('${town['country_code']}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),),
                                SizedBox(width: 10,),
                                Text(town['name']!,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 14),),
                              ],
                            ));
                      }).toList(),
                      onChanged: (value){
                        estimationBloc.add(ChooseDepartureTown(value.toString()));
                      },
                    ),
                  ),
                  FormTitleWithIcon(title: "Ville d'arrivé", icon: Icon(Icons.add_circle_outline,color: Color(0xFFCD1F45),)),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    width: 330,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Color(0xFFCD1F45).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 1,color: Color(0xFFCD1F45).withOpacity(0.6),
                        )),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButton<String>(
                      hint: Text("Sélectionner la ville de départ"),
                      value: selected_arrival_town,
                      isExpanded: true,
                      elevation: 16,
                      underline: Container(
                        height: 0,
                      ),
                      icon: Icon(Icons.keyboard_arrow_down_outlined,color: Color(0xFFCD1F45),),
                      items: map_of_town_arrival.map((town){
                        return DropdownMenuItem<String>(
                            value: town['name'],
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,

                              children: [
                                Text('${town['country_code']}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),),
                                SizedBox(width: 10,),
                                Text(town['name']!,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 14),),
                              ],
                            ));
                      }).toList(),
                      onChanged: (value){
                        estimationBloc.add(ChooseArrivalTown(value.toString()));
                      },
                    ),
                  ),
                  FormTitleWithIcon(title: "Poids approximatif (Kg)", icon: Icon(FontAwesomeIcons.box,size:19,color: Color(0xFFCD1F45),)),
                  SizedBox(height: 10,),
                  Container(
                    width: 330,
                    height: 50,
                    child: TextFormField(
                      controller: _weight,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+[\.,]?\d{0,}$')),
                      ],

                      validator: (value){
                        if(value==null || value.isEmpty){
                          return "Veuillez entrer le poids approximatif";
                        }
                        return null;
                      },
                      onChanged: (value){
                        estimationBloc.add(WeightChanged(double.parse(_weight.text)));
                      },
                      maxLines: 1,
                      decoration: InputDecoration(
                          hintText: "Ex: 2.5",
                          hintStyle: TextStyle(fontSize: 12,color: Colors.black54),
                          filled: _weight.text.isNotEmpty?true:false,
                          fillColor: Color(0xFFCD1F45).withOpacity(0.1),
                          focusColor: Colors.grey.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),

                            borderSide: BorderSide(width: 1,color: Color(0xFFCD1F45).withOpacity(0.6)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(width: 1,color: Color(0xFFCD1F45).withOpacity(0.6)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(width: 1,color: Color(0xFFCD1F45).withOpacity(0.6)),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),

                      ),

                    ),
                  ),
                  SizedBox(height: 20,),
                  error?
                GestureDetector(
                onTap: (){
                  setState(() {
                    isLoading=true;
                  });
                 estimationBloc.add(getAvailableLines());
                },
                child: Container(
                height: 40,
                width: 330,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors:[
                Color(0xFFCC1E44),
                Color(0xFFB71B3E),
                Color(0xFFA11738),
                ]
                ),
                borderRadius: BorderRadius.circular(5)
                ),
                child:   Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                FormTitleWithIcon(title: isLoading?"Recherche...":'Reéssayer', icon: Icon(FontAwesomeIcons.calculator,size:19,color: Colors.white,),textColor: Colors.white ),
                ],
                ),
                ),
                ):
                  GestureDetector(
                    onTap: (){
                      if(_formKey.currentState!=null && (_formKey.currentState as FormState).validate()){
                        estimationBloc.add(
                            CalculateEstimation(arrivalTown: selected_arrival_town,
                                departureTown: selected_departure_town!,
                                weight: double.parse(_weight.text),
                                availableLines: availableLines));
                      }
                    },
                    child: Container(
                      height: 40,
                      width: 330,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors:_weight.text.isEmpty? [
                              Color(0xFFCC1E44).withOpacity(.5),
                              Color(0xFFB71B3E).withOpacity(.5),
                              Color(0xFFA11738).withOpacity(.5),
                              ]: [
                                Color(0xFFCC1E44),
                                Color(0xFFB71B3E),
                                Color(0xFFA11738),
                              ]
                          ),
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child:   Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FormTitleWithIcon(title: state is EstimationLoading?"Calcul en cours...":"Calculer l'estimation", icon: Icon(FontAwesomeIcons.calculator,size:19,color: Colors.white,),textColor: Colors.white ),
                        ],
                      ),
                    ),
                  ),
                  estimation_price!=null?
                  Column(
                    children: [
                      SizedBox(height: 20,),
                      Container(
                        width: 330,
                        decoration: BoxDecoration(
                            color: Color(0x2092FFC1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green.shade300,width: .5)
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color:  Color(0xFF00C35B)
                                  ),
                                  child: Icon(FontAwesomeIcons.calculator,color:Colors.white,size:15),
                                ),
                                SizedBox(width: 10,),
                                Text("Estimation calculée",textAlign:TextAlign.start, style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Color(0xFF00C35B)),)
                              ],
                            ),
                            SizedBox(height: 10,),
                            Text("$estimation_price FCFA",style: TextStyle(fontSize: 22,fontWeight:
                            FontWeight.bold,color: Color(0xFF00C35B)),),
                            SizedBox(height: 10,),
                            Text("Prix final confirmé après vérification du colis",style: TextStyle(fontSize: 12,color: Color(
                                0xFF009E47)),)

                          ],
                        ),
                      ),
                    ],
                  ):Container(),

                  estimation_price!=null? Column(
                    children: [
                      SizedBox(height: 20,),
                      GestureDetector(
                        onTap: (){
                          showNegotiationDialog(context);
                        },
                        child: Container(
                          width: 330,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.black54,
                                    Colors.black54,
                                  ]
                              ),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Text("Négocier le prix",style: TextStyle(fontSize: 14,color: Colors.white,fontFamily: 'Inter')),
                        ),
                      ),
                    ],
                  ):Container(),
                  SizedBox(height: 10,),
                ],
              ),
            )

          ],
        ),
      );
  },
),
    );
  }
}


Widget  FormTitleWithIcon({required String title, required Icon icon,Color?textColor}){
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      icon,
      SizedBox(width: 5,),
      Text(title,style: TextStyle(fontSize: 14,color: textColor??Colors.black87),),
    ],
  );
}

void showNegotiationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        children: const [
          Icon(Icons.info_outline, color:KabaExpeditionColor.primary),
          SizedBox(width: 8),
          Text(
            "Négociation de prix",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: const Text(
        "La négociation du prix n’est possible qu’après l’étape 2 (détails du colis).\n\n",
           style: TextStyle(fontSize: 14, height: 1.4),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: KabaExpeditionColor.primary, // couleur du bouton
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "J'ai compris",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    ),
  );
}