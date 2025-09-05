import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../kaba_chine/presentation/widgets/package_form_info.dart';
import '../../core/utils.dart';

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
  int? estimation_price =null;
  List<Map<String,String>> map_of_town= [
    {"name":"Lomé","country_code":"TG"},
    {"name":"Accra","country_code":"GH"},
    {"name":"Cotonou","country_code":"BJ"},
    {"name":"Abidjan","country_code":"CI"},
    {"name":"Ouagadougou","country_code":"BF"},
    {"name":"Niamey","country_code":"NE"},
    {"name":"Dakar","country_code":"SN"},
  ];
  @override
  Widget build(BuildContext context) {
    return  Form(
      key: _formKey,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 330,
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
                      Text("Prix transparent et compétitif",style: TextStyle(fontSize: 12,color: Colors.black54),)
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: FormTitleWithIcon(title: "Ville de départ", icon: Icon(Icons.location_on_outlined,color: Color(0xFFCD1F45),)),
                  ),
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
                      items: map_of_town.map((town){
                        return DropdownMenuItem<String>(
                            value: town['name'],
                            child: Row(
                              children: [
                                Text('${town['country_code']}',style: TextStyle(fontWeight: FontWeight.bold),),
                                SizedBox(width: 10,),
                                Text(town['name']!,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 14),),
                              ],
                            ));
                      }).toList(),
                      onChanged: (value){
                        setState(() {
                          selected_departure_town = value.toString();
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: FormTitleWithIcon(title: "Ville d'arrivé", icon: Icon(Icons.add_circle_outline,color: Color(0xFFCD1F45),)),
                  ),
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
                      items: map_of_town.map((town){
                        return DropdownMenuItem<String>(
                            value: town['name'],
                            child: Row(
                              children: [
                                Text('${town['country_code']}',style: TextStyle(fontWeight: FontWeight.bold),),
                                SizedBox(width: 10,),
                                Text(town['name']!,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 14),),
                              ],
                            ));
                      }).toList(),
                      onChanged: (value){
                        setState(() {
                          selected_departure_town = value.toString();
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: FormTitleWithIcon(title: "Poids approximatif (Kg)", icon: Icon(FontAwesomeIcons.box,size:19,color: Color(0xFFCD1F45),)),
                  ),
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
                        setState(() {
                          _weight.text = value;
                        });
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
                  GestureDetector(
                    onTap: (){
                      if(_formKey.currentState!=null && (_formKey.currentState as FormState).validate()){
                        setState(() {
                          estimation_price = 10000;
                        });
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
                              colors: [
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
                          FormTitleWithIcon(title: "Calculer l'estimation", icon: Icon(FontAwesomeIcons.calculator,size:19,color: Colors.white,),textColor: Colors.white ),
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

