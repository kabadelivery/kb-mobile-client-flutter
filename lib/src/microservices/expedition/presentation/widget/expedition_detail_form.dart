import 'dart:io';
import 'dart:math';

import 'package:KABA/src/microservices/expedition/presentation/bloc/expedition/expedition_bloc.dart';
import 'package:KABA/src/microservices/expedition/presentation/pages/expedition.dart';
import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../contracts/address_contract.dart';
import '../../../../localizations/AppLocalizations.dart';
import '../../../../models/CustomerModel.dart';
import '../../../../resources/address_api_provider.dart';
import '../../../../ui/screens/home/me/address/MyAddressesPage.dart';
import '../../../../utils/_static_data/AppConfig.dart';
import '../../../../utils/functions/CustomerUtils.dart';
import '../../../../utils/functions/OutOfAppOrder/imagePicker.dart';
import '../../../../utils/functions/permissions.dart';
import '../../../../ui/customwidgets/separator.dart';
import '../../../../utils/recustomlib/place_picker_removed_nearbyplaces.dart';
import '../../core/utils.dart';
import '../../data/expedition/line_model.dart';
import '../../data/expedition/package_model.dart';
import '../../functions/chooseHour.dart';
import '../bloc/estimation/estimation_bloc.dart';
import 'estimation_math.dart';

class ExpeditionDetailForm extends StatefulWidget {
  final int index;
  const ExpeditionDetailForm({required this.index,super.key});

  @override
  State<ExpeditionDetailForm> createState() => _ExpeditionDetailFormState();
}

class _ExpeditionDetailFormState extends State<ExpeditionDetailForm> {
  bool acceptedProhibitedItems = false;
  TextEditingController _recipientPhoneNumber = TextEditingController();
  TextEditingController _packageContainer = TextEditingController();
  String firstImagePath = "";
  String secondImagePath = "";
  String thirdImagePath = "";
  TextEditingController _weight = TextEditingController();
  String? selected_departure_town="Lomé";
  String? selected_arrival_town =null;
  double? estimation_price =null;
  int? estimation_day =null;
  List<Map<String,String>> map_of_town_arrival= [];
  List<Map<String,String>> map_of_town_departure= [];
  List<LineModel>availableLines=[];
  bool expanded = false;
  PackageModel packageModel = PackageModel();
  late ExpeditionBloc expeditionBloc;
  bool gpsAddressChoosed =false;
  bool registeredAddressChoosed =false;
  @override
  void initState() {
    expeditionBloc = BlocProvider.of<ExpeditionBloc>(context);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    expeditionBloc = BlocProvider.of<ExpeditionBloc>(context);
    return BlocConsumer<ExpeditionBloc, ExpeditionState>(
      bloc: expeditionBloc,
      listener: (context, state) {


      },
      builder: (context, state) {
        debugPrint("State: $state");
        if(state is ExpandPackageWidgetState){
          if(state.index==widget.index){
            expanded=  state.expanded;
            availableLines =expeditionBloc.linesList ;
            map_of_town_arrival.clear();
            map_of_town_departure.clear();
            for(LineModel line in availableLines){
              Map<String,String> lineDepartureMap =  {"id":"${line.id}","name":line.depart!.nom??"","country_code":line.depart!.pays!['code']??"",'country':line.depart!.pays!['nom']};
              Map<String,String> lineArrivalMap =  {"id":"${line.id}","name":line.arrivee!.nom??"","country_code":line.arrivee!.pays!['code']??"",'country':line.arrivee!.pays!['nom']};
              if (!map_of_town_departure.any((m) => m["name"] == line.depart!.nom)) {
                map_of_town_departure.add(lineDepartureMap);
              }
              if (!map_of_town_arrival.any((m) => m["name"] == line.arrivee!.nom)) {
                map_of_town_arrival.add(lineArrivalMap);
              }
            }
            if(selected_arrival_town==null && map_of_town_arrival!=null && map_of_town_arrival.isNotEmpty){
              selected_arrival_town = map_of_town_arrival[0]['name'];
              BlocProvider.of<ExpeditionBloc>(context).add(ChooseArrivalTownEvent(packageIndex: widget.index, town: selected_arrival_town!, lineId: availableLines.where((element) => element.depart!.nom==selected_departure_town && element.arrivee!.nom==selected_arrival_town).first.id!));
              BlocProvider.of<ExpeditionBloc>(context).add(ChooseDepartureTownEvent(packageIndex: widget.index, town: selected_departure_town!, lineId: availableLines.where((element) => element.depart!.nom==selected_departure_town && element.arrivee!.nom==selected_arrival_town).first.id!));
            }
          }
        }
        if(state is PackagesUpdatedState){
          if(state.index==widget.index){
            packageModel = state.packages[widget.index];
            debugPrint("PackageModel: ${packageModel.toJson()}");
            registeredAddressChoosed = registeredAddressChoosed;
            gpsAddressChoosed = gpsAddressChoosed;
            try{
              firstImagePath = packageModel.images![0]!=null?packageModel.images![0]!:"";
              secondImagePath = packageModel.images![1]!=null?packageModel.images![1]!:"";
              thirdImagePath = packageModel.images![2]!=null?packageModel.images![2]!:"";
            }catch(e){
            }
            _packageContainer.text = packageModel.description!=null?packageModel.description.toString():"";

          }
        }
        return Container(
            width: 350,
            height: expanded?null:60,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 5), )
                ]
            ),
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width:30,
                              height: 30,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient:  LinearGradient(
                                  colors: expanded?[Color(0xFFE93F53), Color(0xFFD11A3F)]:
                                  [Color(0xFF9F9F9F),
                                    Color(0xFF8A8A8A)],

                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child:Text("${widget.index+1}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                            ),
                            SizedBox(width: 10,),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${AppLocalizations.of(context)!.translate('parcel')} ${widget.index+1}",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 14),),
                                Text("${AppLocalizations.of(context)!.translate('requirements')}",style: TextStyle(fontSize: 14,color: Colors.black54),)
                              ],
                            )
                          ],
                        ),
                        MaterialButton(onPressed: (){
                          expeditionBloc.add(ExpandPackageWidgetAction(index: widget.index, expanded: !expanded));
                        },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          highlightColor: Color(0xFFCD1F45).withOpacity(.2),
                          hoverColor: Color(0xFFCD1F45).withOpacity(.2),
                          splashColor: Color(0xFFCD1F45).withOpacity(.2),
                          elevation: 0,
                          highlightElevation: 0,
                          color: Colors.white,
                          focusColor: Color(0xFFCD1F45).withOpacity(.2),
                          child: Text(expanded?"Réduire":"Configurer",style: TextStyle(color: Color(0xFFCD1F45),fontWeight: FontWeight.bold),),
                        )
                      ],
                    ),
                  ),
                  expanded?  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FormTitleWithIcon(title: "${AppLocalizations.of(context)!.translate("departure_town")}", icon: Icon(size:15,Icons.rocket_launch_outlined,color: Color(0xFFCD1F45),)),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                width: 150,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF3F3F5),
                                  borderRadius: BorderRadius.circular(5),

                                ),
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: DropdownButton<String>(
                                  hint: Text("${AppLocalizations.of(context)!.translate('select_departure_city')}"),
                                  value: selected_departure_town,
                                  isExpanded: true,
                                  elevation: 16,
                                  underline: Container(
                                    height: 0,
                                  ),
                                  icon: Icon(Icons.keyboard_arrow_down_outlined,color: Color(0xFF9A9A9A),),
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
                                    setState(() {
                                      selected_departure_town = value;
                                    });
                                    BlocProvider.of<ExpeditionBloc>(context).add(ChooseDepartureTownEvent(packageIndex: widget.index, town: value.toString(), lineId: availableLines.where((element) => element.depart!.nom==selected_departure_town && element.arrivee!.nom==selected_arrival_town).first.id!));
                                    if(_weight.text.isNotEmpty){
                                      BlocProvider.of<EstimationBloc>(context).add(CalculateEstimation(
                                          departureTown: selected_departure_town!,
                                          arrivalTown: selected_arrival_town!,
                                          weight: double.parse(_weight.text),
                                          availableLines: availableLines));
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FormTitleWithIcon(title:  "${AppLocalizations.of(context)!.translate("arrival_town")}", icon: Icon(size:15,Icons.location_on_outlined,color: Color(0xFFCD1F45),)),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                width: 150,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF3F3F5),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: DropdownButton<String>(
                                  hint: Text("${AppLocalizations.of(context)!.translate('select_arrival_city')}"),
                                  value: selected_arrival_town,
                                  isExpanded: true,
                                  elevation: 16,
                                  underline: Container(
                                    height: 0,
                                  ),
                                  icon: Icon(Icons.keyboard_arrow_down_outlined,color: Color(
                                      0xFF9A9A9A),),
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
                                    setState(() {
                                      selected_arrival_town = value!;
                                    });
                                    BlocProvider.of<ExpeditionBloc>(context).add(ChooseArrivalTownEvent(packageIndex: widget.index, town: value.toString(), lineId: availableLines.where((element) => element.arrivee!.nom==selected_arrival_town && element.depart!.nom==selected_departure_town).first.id!));
                                    if(_weight.text.isNotEmpty){
                                      BlocProvider.of<EstimationBloc>(context).add(CalculateEstimation(
                                          departureTown: selected_departure_town!,
                                          arrivalTown: selected_arrival_town!,
                                          weight: double.parse(_weight.text),
                                          availableLines: availableLines));
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text("${AppLocalizations.of(context)!.translate('parcel_weight')}", style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black87),),
                      ),
                      SizedBox(height: 10,),
                      Container(
                        width: 350,
                        height: 50,
                        padding:EdgeInsets.symmetric(horizontal:10),
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
                            expeditionBloc.add(ChangeWeightEvent(weight: double.parse(value), packageIndex: widget.index));
                            BlocProvider.of<EstimationBloc>(context).add(CalculateEstimation(
                              departureTown: selected_departure_town!,
                              arrivalTown: selected_arrival_town!,
                              weight: double.parse(value),
                              availableLines: availableLines,
                            ));
                          },
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: "Ex: 2.5",
                            hintStyle: TextStyle(fontSize: 12,color: Colors.black54),
                            filled:true,
                            fillColor: Color(0xFFF3F3F5),
                            focusColor: Colors.grey.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(width: 1,color: Color(0xFFF3F3F5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(width: 1,color: Color(0xFFF3F3F5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(width: 1,color: Color(0xFFF3F3F5)),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),

                          ),

                        ),
                      ),
                      SizedBox(height: 10,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: BlocSelector<EstimationBloc, EstimationState, EstimationState>(
                          selector: (state) {
                            return state;
                          },
                          builder: (context, state) {
                            if(state is EstimationCalculated){
                              estimation_price = state.result.prixFinal;
                              estimation_day= state.result.dureeJours;
                            }
                            if(state is EstimationLoading){

                            }
                            if(state is EstimationError){
                              estimation_price = 0;
                            }
                            return Container(
                              decoration: BoxDecoration(
                                  color: KabaExpeditionColor.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(width: 1,color: KabaExpeditionColor.primary.withOpacity(1),)
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  state is EstimationLoading?
                                  Text('Calcul en cours...')
                                      :Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(Icons.circle,size:7,color: KabaExpeditionColor.primary,),
                                          SizedBox(width: 5,),
                                          Text("${AppLocalizations.of(context)!.translate('estimated_cost')}",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black87),),
                                          Text("${_weight.text.isNotEmpty?formatCurrency(double.parse(estimation_price.toString())):"0" } FCFA", style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: KabaExpeditionColor.primary),),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(Icons.circle,size:7,color: KabaExpeditionColor.primary,),
                                          SizedBox(width: 5,),
                                          Text("Livraison en ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black87),),
                                          Text("${_weight.text.isNotEmpty?estimation_day.toString():"0"} ${AppLocalizations.of(context)!.translate('days')}", style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: KabaExpeditionColor.primary),),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10,),
                      //Package description
                      Container(

                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10,),
                            Text("${AppLocalizations.of(context)!.translate('parcel_content')}",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black87),),
                            SizedBox(height: 10,),
                            TextFormField(
                              controller: _packageContainer,
                              maxLines: 3,
                              onChanged: (value){
                                expeditionBloc.add(ChangeDescriptionEvent(description: value, packageIndex: widget.index));
                              },
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xFFF3F3F5),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Color(0xFFF3F3F5),width: 0.5)
                                  ),
                                  border:OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Color(0xFFF3F3F5),width: 0.5)
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: KabaExpeditionColor.primary,width: 1)
                                  ),
                                  hintText: "Ex: Vêtements, chaussures, produits, cosmétiques, etc.",
                                  hintStyle: TextStyle(fontSize: 12,color: Colors.grey.shade400),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 10)
                              ),
                            ),
                            SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text("${AppLocalizations.of(context)!.translate('recipient_phone')}", style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black87),),
                            ),
                            SizedBox(height: 10,),
                            TextFormField(
                              controller: _recipientPhoneNumber,
                              onChanged: (value){
                                expeditionBloc.add(enterRecipientPhoneNumber(phoneNumber: value, packageIndex: widget.index));
                              },
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xFFF3F3F5),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Color(0xFFF3F3F5),width: 0.5)
                                  ),
                                  border:OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Color(0xFFF3F3F5),width: 0.5)
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: KabaExpeditionColor.primary,width: 1)
                                  ),
                                  hintText: "Ex : +2289999999",
                                  hintStyle: TextStyle(fontSize: 12,color: Colors.grey.shade400),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 10)
                              ),
                            ),
                          ],
                        ),
                      ),
                      //Recipient address
                      Container(
                        width: 350,
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${AppLocalizations.of(context)!.translate('recipient_address')}",style: TextStyle(fontSize: 12,color: Colors.black87,fontWeight: FontWeight.bold),),
                            SizedBox(height: 5,),
                            TextFormField(
                              maxLines: 3,
                              onChanged: (value){
                                expeditionBloc.add(ChangeRecipientStringAddressEvent(address: value, packageIndex: widget.index));
                              },
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xFFF3F3F5),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Color(0xFFF3F3F5),width: 0.5)
                                  ),
                                  border:OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Color(0xFFF3F3F5),width: 0.5)
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: KabaExpeditionColor.primary,width: 1)
                                  ),
                                  hintText: "Ex: Près de l’Hôtel Labadi Beach, en face de...",
                                  hintStyle: TextStyle(fontSize: 12,color: Colors.black87),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 10)
                              ),
                            ),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                GestureDetector(
                                  onTap: ()async{
                                    CustomerModel? customer = await CustomerUtils.getCustomer();
                                    DeliveryAddressModel address = DeliveryAddressModel(
                                      name:"",
                                      phone_number:"",
                                      user_id: customer.id.toString(),
                                      description: "",
                                      quartier: "",
                                      near: "",
                                    );
                                    var results = await Navigator.of(context).push(PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) =>
                                            PlacePicker(
                                              AppConfig.GOOGLE_MAP_API_KEY,alreadyHasLocation: true,),
                                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                          var begin = Offset(1.0, 0.0);
                                          var end = Offset.zero;
                                          var curve = Curves.ease;
                                          var tween = Tween(begin: begin, end: end);
                                          var curvedAnimation =
                                          CurvedAnimation(parent: animation, curve: curve);
                                          return SlideTransition(
                                              position: tween.animate(curvedAnimation), child: child);
                                        }));

                                    if (results != null ){
                                      AddressApiProvider address_api = AddressApiProvider();
                                      DeliveryAddressModel address = DeliveryAddressModel(
                                          name: "Addresse route ${packageModel.arrivalTown} - ${packageModel.departureTown} ${DateTime.now().toIso8601String()}",
                                          location:" ${results.latitude}:${results.longitude}" ,
                                          phone_number:customer.phone_number,
                                          description: "achat de produit",
                                          near: "Inconnu",
                                          user_id: customer.id.toString(),
                                          quartier:"Inconnu"
                                      );
                                      Map? addressRes = await address_api.updateOrCreateAddress(address, customer) as Map;
                                      packageModel.recipientAddress = addressRes['address'] as DeliveryAddressModel;
                                      expeditionBloc.add(ChangeRecipientAddressEvent(address: packageModel.recipientAddress!, packageIndex: widget.index));
                                      gpsAddressChoosed = true;
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color:gpsAddressChoosed? KabaExpeditionColor.primary:  Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: KabaExpeditionColor.primary.withOpacity(0.5),width: 0.5)
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add_circle_outline,size: 20,color:gpsAddressChoosed?Colors.white:  KabaExpeditionColor.primary,),
                                        SizedBox(width: 10,),
                                        Text("${AppLocalizations.of(context)!.translate('add_gps')}",style: TextStyle(fontSize: 11,color:gpsAddressChoosed?Colors.white: KabaExpeditionColor.primary),)
                                      ],
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  onTap: ()async{
                                    if(packageModel.departureTown!.isEmpty || packageModel.arrivalTown!.isEmpty){
                                      CherryToast.error(
                                        toastPosition:Position.center,
                                        title: Text("Choisissez votre itinéraire de livraison"),
                                      );
                                    }else{
                                      Map results = await Navigator.of(context).push(PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) =>
                                              MyAddressesPage(
                                                pick: true,
                                                address_type: 2,
                                                presenter: AddressPresenter(AddressView()),
                                              ),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            var begin = Offset(1.0, 0.0);
                                            var end = Offset.zero;
                                            var curve = Curves.ease;
                                            var tween = Tween(begin: begin, end: end);
                                            var curvedAnimation =
                                            CurvedAnimation(parent: animation, curve: curve);
                                            return SlideTransition(
                                                position: tween.animate(curvedAnimation), child: child);
                                          }));

                                      if (results != null && results.containsKey('selection')){
                                        packageModel.recipientAddress = results['selection'] as DeliveryAddressModel;
                                        expeditionBloc.add(ChangeRecipientAddressEvent(address: packageModel.recipientAddress!, packageIndex: widget.index));
                                        registeredAddressChoosed = true;
                                      }
                                    }
                                  },
                                  child: Container(

                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: registeredAddressChoosed ? KabaExpeditionColor.primary:Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: KabaExpeditionColor.primary.withOpacity(0.5),width: 0.5)
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.save_outlined,size: 20,color:registeredAddressChoosed?Colors.white: KabaExpeditionColor.primary,),
                                        SizedBox(width: 10,),
                                        Text("${AppLocalizations.of(context)!.translate('saved_addresses')}",style: TextStyle(fontSize: 11,color:registeredAddressChoosed?Colors.white: KabaExpeditionColor.primary),)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            packageModel.recipientAddress!=null?
                            Column(
                              children: [
                                SizedBox(height: 10,),
                                Container(
                                  width: 330,
                                  decoration: BoxDecoration(
                                    color: KabaExpeditionColor.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(color: KabaExpeditionColor.primary.withOpacity(1),width: .5),
                                  ),
                                  child:Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_on_outlined,size: 20,color: KabaExpeditionColor.primary,),
                                        Flexible(child: Text("${packageModel.recipientAddress!.name}",maxLines: 3,softWrap: true,overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: KabaExpeditionColor.primary))),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ):Container()
                          ],
                        ),
                      ),
                      //Package pics
                      Container(
                        padding: EdgeInsets.all(10),

                        child: Column(
                          children: [
                            Text("${AppLocalizations.of(context)!.translate('current_position')}",style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: KabaExpeditionColor.primary),),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ImageSlot(
                                  photoIndex: 0,
                                  packageIndex: widget.index,
                                  imageUrl: packageModel.images != null && packageModel.images!.isNotEmpty
                                      ? packageModel.images![0]
                                      : null,
                                  emptyLabel: firstImagePath != null && firstImagePath.isEmpty ? "Obligatoire" : "Obligatoire",
                                ),
                                ImageSlot(
                                  photoIndex: 1,
                                  packageIndex: widget.index,
                                  imageUrl: (packageModel.images != null && packageModel.images!.length > 1)
                                      ? packageModel.images![1]
                                      : null,
                                  emptyLabel: secondImagePath != null && secondImagePath.isEmpty ? "Obligatoire" : "Obligatoire",
                                ),
                                ImageSlot(
                                  packageIndex: widget.index,
                                  photoIndex: 2,
                                  imageUrl: (packageModel.images != null && packageModel.images!.length > 2)
                                      ? packageModel.images![2]
                                      : null,
                                  emptyLabel: thirdImagePath != null && thirdImagePath.isEmpty ? "Optionnel" : "Optionnel",
                                ),
                              ],
                            )

                          ],
                        ),
                      ),
                    ],
                  ):Container()
                  //continuer

                ],
              ),
            )
        );
      },
    );
  }
}

class PickUpOptions extends StatefulWidget {
  const PickUpOptions({super.key});

  @override
  State<PickUpOptions> createState() => _PickUpOptionsState();
}

class _PickUpOptionsState extends State<PickUpOptions> {
  bool kaba_fetch_the_package = false;
  bool deposit_of_the_package = false;
  bool positionChoosed=false;
  bool addressSavedChoosed=false;
  DateTime? selectedDate = null;
  bool addNewAddress = false;
  bool _loading = false;
  List<String> selectedTimes = [
    "8:00 -  10:00",
    "10:00 - 12:00",
    "12:00 - 14:00",
    "14:00 - 16:00",
  ];
  String? selectedTime = null;
  DeliveryAddressModel? addressSelected =null;
  TextEditingController _senderPhoneNumber = TextEditingController();
  @override
  void initState(){
    super.initState();
    BlocProvider.of<ExpeditionBloc>(context).add(chooseShippingMethodAddressType(method: 'POSITION'));
  }
  @override
  Widget build(BuildContext context) {
    return  //pickup options
      BlocSelector<ExpeditionBloc, ExpeditionState, ExpeditionState>(
        selector: (state) {
          return state;
        },
        builder: (context, state) {
          if(state is chooseShippingMethodState){
            if(state.method=="DOMICILE"){
              kaba_fetch_the_package = true;
              deposit_of_the_package = false;
            }else{

              kaba_fetch_the_package = false;
              deposit_of_the_package = true;
            }

          }
          if(state is chooseShippingMethodAddressTypeState){
            if(state.method=="POSITION"){
              positionChoosed = true;
              addressSavedChoosed = false;
              _loading = false;
              WidgetsBinding.instance.addPostFrameCallback((_){
                CherryToast.success(
                  toastPosition: Position.center,
                  title: Text("${AppLocalizations.of(context)!.translate('success')}"),
                  description:Text("${AppLocalizations.of(context)!.translate('current_position')}"),
                ).show(context);
              });
            }else if(state.method=="REGISTERED"){
              positionChoosed = false;
              addressSavedChoosed = true;
            }else{
              positionChoosed = false;
              addressSavedChoosed = false;
            }

          }
          if(state is chooseFetchDateState){
            selectedDate = state.date;
          }
          if(state is chooseFetchTimeState){
            selectedTime = state.hour;
          }
          return Container(
              width: 350,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, 5), )
                  ]
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${AppLocalizations.of(context)!.translate('pickup_address')}",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: KabaExpeditionColor.primary),),
                    SizedBox(height: 10),
                    Text("${AppLocalizations.of(context)!.translate('sender_phone')}",style: TextStyle(fontSize: 14,color: Colors.black87,fontWeight: FontWeight.bold),),
                    SizedBox(height: 10,),
                    TextFormField(
                      controller: _senderPhoneNumber,
                      onChanged: (value){
                        BlocProvider.of<ExpeditionBloc>(context).add(enterSendPhoneNumber(phoneNumber: value));
                      },
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFF3F3F5),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFFF3F3F5),width: 0.5)
                          ),
                          border:OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFFF3F3F5),width: 0.5)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: KabaExpeditionColor.primary,width: 1)
                          ),
                          hintText: "Ex : +2289999999",
                          hintStyle: TextStyle(fontSize: 12,color: Colors.grey.shade400),
                          contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 10)
                      ),
                    ),
                    SizedBox(height: 10,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("${AppLocalizations.of(context)!.translate('pickup_service_question')}",style: TextStyle(fontSize: 13,color: Colors.black87,fontWeight: FontWeight.bold),),
                            Text("${AppLocalizations.of(context)!.translate('home_pickup_service')}",style: TextStyle(fontSize: 13,color: Colors.black38),),
                          ],
                        ),
                        SizedBox(width: 10,),
                        //Toggle button
                        Switch(
                            thumbColor: MaterialStateProperty.all( kaba_fetch_the_package? Colors.white:Color(0xff48444e)),
                            activeTrackColor: KabaExpeditionColor.primary.withOpacity(0.3),
                            thumbIcon: MaterialStateProperty.all(Icon(Icons.circle,color: kaba_fetch_the_package?Colors.white:Color(0xff48444e),size: 15,)),
                            trackColor: MaterialStateProperty.all( kaba_fetch_the_package? KabaExpeditionColor.primary:Color(0xffe4dee7)),
                            padding: EdgeInsets.all(0),
                            value: kaba_fetch_the_package,
                            activeColor: KabaExpeditionColor.primary,
                            onChanged: (value){
                              BlocProvider.of<ExpeditionBloc>(context).add(chooseShippingMethod(method: value?"DOMICILE":"DEPOT_PARTENAIRE"));
                            })
                      ],
                    ),
                    kaba_fetch_the_package? Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: KabaExpeditionColor.primary.withOpacity(.15),
                          border: Border.all(color: KabaExpeditionColor.primary,width: 0.5)

                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("📍 Adresse de récupération",style: TextStyle(fontSize: 14,color:KabaExpeditionColor.primary,fontWeight: FontWeight.bold),),
                              ],
                            ),
                            SizedBox(height:10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      _loading = true;
                                    });
                                    BlocProvider.of<ExpeditionBloc>(context).add(chooseShippingMethodAddressType(method: "POSITION"));

                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: positionChoosed? KabaExpeditionColor.primary:Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: KabaExpeditionColor.primary.withOpacity(0.5),width: 0.5)
                                    ),
                                    child: Row(

                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.location_on_outlined,size: 20,color: !positionChoosed? KabaExpeditionColor.primary:Colors.white,),
                                        Text(_loading?"En cours..." :"Position actuelle",style: TextStyle(fontSize: 13,color:!positionChoosed? KabaExpeditionColor.primary:Colors.white),)
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10,),
                                GestureDetector(
                                  onTap: ()async{
                                    Map results = await Navigator.of(context).push(PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) =>
                                            MyAddressesPage(
                                              pick: true,
                                              presenter: AddressPresenter(AddressView()),
                                            ),
                                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                          var begin = Offset(1.0, 0.0);
                                          var end = Offset.zero;
                                          var curve = Curves.ease;
                                          var tween = Tween(begin: begin, end: end);
                                          var curvedAnimation =
                                          CurvedAnimation(parent: animation, curve: curve);
                                          return SlideTransition(
                                              position: tween.animate(curvedAnimation), child: child);
                                        }));
                                    if (results != null && results.containsKey('selection')){
                                      addressSelected = results['selection'] as DeliveryAddressModel;
                                      BlocProvider.of<ExpeditionBloc>(context).add(chooseShippingMethodAddressType(method: "REGISTERED",coords:addressSelected!.location));
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: addressSavedChoosed? KabaExpeditionColor.primary:Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: KabaExpeditionColor.primary.withOpacity(0.5),width: 0.5)
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.save_outlined,size: 20,color: !addressSavedChoosed? KabaExpeditionColor.primary:Colors.white,),
                                        Text("${AppLocalizations.of(context)!.translate('saved_addresses_alt')}",style: TextStyle(fontSize: 13,color:!addressSavedChoosed? KabaExpeditionColor.primary:Colors.white),)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height:10),
                            GestureDetector(
                              onTap: ()async{
                                CustomerModel customerModel = await CustomerUtils.getCustomer();
                                DeliveryAddressModel address = DeliveryAddressModel(
                                  name:"",
                                  phone_number:customerModel.phone_number.toString(),
                                  user_id:customerModel.id.toString(),
                                  description: "",
                                  quartier: "",
                                  near: "",
                                );
                                Map results = await Navigator.of(context).push(PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        MyAddressesPage(
                                          pick: true,
                                          address_type: 3,
                                          autoCreatAddress: address,
                                          presenter: AddressPresenter(AddressView()),
                                        ),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      var begin = Offset(1.0, 0.0);
                                      var end = Offset.zero;
                                      var curve = Curves.ease;
                                      var tween = Tween(begin: begin, end: end);
                                      var curvedAnimation =
                                      CurvedAnimation(parent: animation, curve: curve);
                                      return SlideTransition(
                                          position: tween.animate(curvedAnimation), child: child);
                                    }));
                                if (results != null && results.containsKey('selection')){
                                  addressSelected = results['selection'] as DeliveryAddressModel;
                                  setState(() {
                                    addressSelected = results['selection'] as DeliveryAddressModel;
                                  });
                                  BlocProvider.of<ExpeditionBloc>(context).add(chooseShippingMethodAddressType(method: "ADD",coords:address.location));

                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: addNewAddress? KabaExpeditionColor.primary:Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: KabaExpeditionColor.primary.withOpacity(0.5),width: 0.5)
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_circle_outline,size: 20,color: !addNewAddress? KabaExpeditionColor.primary:Colors.white,),
                                    Text("${AppLocalizations.of(context)!.translate('add_new_address')}",style: TextStyle(fontSize: 13,color:!addNewAddress? KabaExpeditionColor.primary:Colors.white),)
                                  ],
                                ),
                              ),
                            ),
                            addressSelected!=null?
                            Column(
                              children: [
                                SizedBox(height: 10,),
                                Container(
                                  width: 330,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(color: KabaExpeditionColor.primary.withOpacity(1),width: .5),
                                  ),
                                  child:Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_on_outlined,size: 20,color: KabaExpeditionColor.primary,),
                                        Flexible(child: Text("${addressSelected!.name}",maxLines: 3,softWrap: true,overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: KabaExpeditionColor.primary))),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ):Container(),
                            SizedBox(height:10),
                            Text("${AppLocalizations.of(context)!.translate('pickup_scheduling')}",style: TextStyle(fontSize: 13,color:KabaExpeditionColor.primary,fontWeight: FontWeight.bold),),
                            SizedBox(height:10),
                            Text("${AppLocalizations.of(context)!.translate('pickup_date')}",style: TextStyle(fontSize: 13,color:Colors.black87,fontWeight: FontWeight.bold),),
                            SizedBox(height:10),
                            GestureDetector(
                              onTap: ()async{
                                DateTime? result = await chooseDate(context: context);
                                if(result!=null){
                                  final now = DateTime.now();
                                  final today = DateTime(now.year, now.month, now.day);

                                  if (!result.isBefore(today)) {
                                    BlocProvider.of<ExpeditionBloc>(context).add(
                                      chooseFetchDateEvent(date: result),
                                    );
                                  }else{
                                    CherryToast.error(
                                      toastPosition: Position.center,
                                      title: Text("${AppLocalizations.of(context)!.translate('invalid_date')}"),
                                      toastDuration: Duration(seconds: 5),
                                    ).show(context);
                                  }
                                }
                              },
                              child: Container(
                                width: 350,
                                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color:selectedDate==null? Colors.white: KabaExpeditionColor.primary,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(selectedDate==null?"Sélectionnez une date":"${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",style: TextStyle(fontSize: 14,color:selectedDate==null? Colors.black54:Colors.white)),
                                    Icon(Icons.calendar_month,color:selectedDate==null? Colors.grey:Colors.white,size: 17,)
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height:10),
                            GestureDetector(
                              child: Container(
                                width: 350,
                                padding: EdgeInsets.only(left:10,right:10,top: 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color:Colors.white,
                                ),
                                child:  Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    DropdownButton(
                                        hint: Text("${AppLocalizations.of(context)!.translate('select_time_slot')}",style: TextStyle(fontSize: 13,color:selectedDate==null? Colors.black54:Colors.white),),
                                        underline: SizedBox(),
                                        value: selectedTime,
                                        padding: EdgeInsets.only(right: 90),
                                        icon: null,
                                        iconEnabledColor:selectedTimes!=null?Colors.white:null,
                                        items: selectedTimes.map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        )).toList(),
                                        onChanged: (value){
                                          BlocProvider.of<ExpeditionBloc>(context).add(chooseFetchTimeEvent(hour: value!));
                                        }),

                                    Icon(Icons.alarm,color:Colors.grey,size: 17,)
                                  ],
                                ),
                              ),
                            )
                          ]
                      ),
                    ):SizedBox(height: 0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("${AppLocalizations.of(context)!.translate('drop_off_question')}",style: TextStyle(fontSize: 13,color: Colors.black87,fontWeight: FontWeight.bold),),
                            Text("${AppLocalizations.of(context)!.translate('drop_off_office')}",style: TextStyle(fontSize: 13,color: Colors.black38),),
                          ],
                        ),
                        SizedBox(width: 10,),
                        //Toggle button
                        Switch(
                            thumbColor: MaterialStateProperty.all( deposit_of_the_package?Colors.white:Color(0xff48444e)),
                            activeTrackColor: KabaExpeditionColor.primary.withOpacity(0.3),

                            thumbIcon: MaterialStateProperty.all(Icon(Icons.circle,color: deposit_of_the_package? Colors.white:Color(0xff48444e),size: 15,)),
                            trackColor: MaterialStateProperty.all( deposit_of_the_package? KabaExpeditionColor.primary:Color(0xffe4dee7)),
                            padding: EdgeInsets.all(0),
                            value: deposit_of_the_package,
                            activeColor: KabaExpeditionColor.primary,
                            onChanged: (value){
                              BlocProvider.of<ExpeditionBloc>(context).add(chooseShippingMethod(method: value?"DEPOT_PARTENAIRE":"DOMICILE"));
                            }),
                      ],
                    ),
                    deposit_of_the_package?
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: KabaExpeditionColor.primary.withOpacity(.15),
                          border: Border.all(color: KabaExpeditionColor.primary,width: 0.5)

                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,size: 20,color: KabaExpeditionColor.primary,),
                              SizedBox(width: 10,),
                              Text("${AppLocalizations.of(context)!.translate('kaba_office')}",style: TextStyle(fontSize: 14,color: Colors.black87,fontWeight: FontWeight.bold),),

                            ],
                          ),
                          SizedBox(height: 10,),
                          Text("319 Rue AGP, Agbalépédo, Lomé TOGO",style: TextStyle(fontSize: 13,color: Colors.black54,fontWeight: FontWeight.w400),),
                          SizedBox(height: 10,),
                          MaterialButton(
                            onPressed: (){
                              Uri googleMapsUrl = Uri.parse('https://maps.app.goo.gl/NjLzrtw41wevzjneA');
                              launchUrl(googleMapsUrl);
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)
                            ),
                            elevation: 0,
                            padding: EdgeInsets.all(0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.topRight,
                                          colors: [
                                            Color(0xFFCC1E44),
                                            Color(0xFFB71B3E),
                                            Color(0xFFA11738)
                                          ]
                                      )
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.map_outlined,size: 17,color: Colors.white,),
                                      SizedBox(width: 10,),
                                      Text("Voir sur Google Maps",style: TextStyle(fontSize: 12,color: Colors.white,fontWeight: FontWeight.bold),),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //   SizedBox(width: 10,),
                          //   Text("Ouvert : Lundi - Samedi 08h-18h ",style: TextStyle(fontSize:12,color:KabaExpeditionColor.primary),),
                        ],
                      ),
                    ):SizedBox(height: 0,),
                  ]
              )
          );
        },
      );
  }
}
class PackageSelector extends StatelessWidget {
  const PackageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    ExpeditionBloc  expeditionBloc = BlocProvider.of<ExpeditionBloc>(context);
    return BlocSelector<ExpeditionBloc, ExpeditionState, int>(
      bloc: expeditionBloc,
      selector: (state) {
        // retourne le nombre de packages depuis le state
        if (state is PackagesUpdatedState) {
          return state.packagesCount;
        }
        return 1; // valeur par défaut
      },
      builder: (context, selected) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                spreadRadius: 1,
                blurRadius: 15,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE93F53), Color(0xFFD11A3F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(FontAwesomeIcons.box, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nombre de colis",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        Container(
                          width: 220,
                          child: Text(
                            "${AppLocalizations.of(context)!.translate('different_destination')}",
                            maxLines: 2,

                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Select buttons 1-4
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (i) {
                    final value = i + 1;
                    final isSelected = selected == value;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFCD1F45) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              context.read<ExpeditionBloc>().add(SetPackageCountEvent(value));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text(
                                  "$value",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                // - / number / +
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _roundButton(context, "-", () {
                      if (selected > 1) {
                        context.read<ExpeditionBloc>().add(RemovePackageEvent(count: 1));
                      }
                    }),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEFEF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "$selected",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _roundButton(context, "+", () {
                      if (selected < 20) {
                        context.read<ExpeditionBloc>().add(AddPackageEvent(count: 1));
                      }
                    }),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _roundButton(BuildContext context, String text, VoidCallback onPressed) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class ImageSlot extends StatefulWidget {
  final int photoIndex;
  final String? imageUrl;
  final String emptyLabel;
  final int packageIndex;

  const ImageSlot({
    Key? key,
    required this.photoIndex,
    required this.imageUrl,
    required this.emptyLabel,
    required this.packageIndex,
  }) : super(key: key);

  @override
  State<ImageSlot> createState() => _ImageSlotState();
}

class _ImageSlotState extends State<ImageSlot> {
  bool _isLoading = false;
  Future<void> _pickAndDispatch() async {
    setState(() => _isLoading = true);
    final expeditionBloc = BlocProvider.of<ExpeditionBloc>(context);
    try {
      if (Platform.isAndroid) {
        final value = await pickImageAndroid(context);
        if (value != null) {
          expeditionBloc.add(AddPhotoEvent(
              file: value,
              packageIndex: widget.packageIndex,
              photoIndex: widget.photoIndex));
        } else {
          CherryToast.error(
            toastPosition: Position.center,
            title: Text("${AppLocalizations.of(context)!.translate('error')}"),
            description: Text("${AppLocalizations.of(context)!.translate('no_image_or_too_large')}"),
            toastDuration: const Duration(seconds: 5),
          ).show(context);
        }
      } else {
        final granted = await requestCameraAndGalleryPermissions();
        if (granted) {
          final value = await pickImageIOS(context);
          if (value != null) {
            expeditionBloc.add(AddPhotoEvent(
                file: value,
                packageIndex: widget.packageIndex,
                photoIndex: widget.photoIndex));
          }
          CherryToast.success(
            toastPosition: Position.center,
            title: Text("${AppLocalizations.of(context)!.translate('success')}"),
            description: Text("${AppLocalizations.of(context)!.translate('camera_permission_granted')}"),
            toastDuration: const Duration(seconds: 5),
          ).show(context);
        } else {
          CherryToast.error(
            toastPosition: Position.center,
            title: Text("${AppLocalizations.of(context)!.translate('error')}"),
            description: Text("${AppLocalizations.of(context)!.translate('camera_permission_denied')}"),
            toastDuration: const Duration(seconds: 5),
          ).show(context);
        }
      }

    } catch (e) {
      debugPrint("##Error picking image## $e");
      setState(() => _isLoading = false);
    }

  }
  @override
  Widget build(BuildContext context) {
    if(widget.imageUrl!=null && widget.imageUrl!.isNotEmpty){
      setState(() => _isLoading = false);
    }
    return GestureDetector(
      onTap: _isLoading ? null : _pickAndDispatch,
      child: DottedBorder(
        options: const RoundedRectDottedBorderOptions(
          dashPattern: [10, 6],
          strokeWidth: 1,
          color: Colors.black38,
          radius: Radius.circular(10),
        ),
        child: Container(
          width: 85,
          height: 85,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return Container(
        color: Colors.grey.shade100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: 55,
              child: const Icon(Icons.logout, size: 30, color: Colors.black54),
            ),
            const SizedBox(height: 6),
            Text(
              widget.emptyLabel,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    return Image.network(
      widget.imageUrl!,
      fit: BoxFit.cover,
      width: 85,
      height: 85,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        } else {
          return Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.black38, size: 28),
          ),
        );
      },
    );
  }
}