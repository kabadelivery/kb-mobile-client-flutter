import 'package:KABA/src/microservices/expedition/data/expedition/expedition_model.dart';
import 'package:KABA/src/microservices/expedition/data/expedition/facturation.dart';
import 'package:KABA/src/microservices/expedition/presentation/bloc/expedition/expedition_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils.dart';
import '../../data/expedition/city_model.dart';
import '../../data/expedition/createdby_model.dart';
import '../../data/expedition/line_model.dart';
import '../../data/expedition/package_model.dart';
import '../widget/expedition_widget.dart';

class TrackingPackages extends StatefulWidget {
  const TrackingPackages({super.key});

  @override
  State<TrackingPackages> createState() => _TrackingPackagesState();
}

class _TrackingPackagesState extends State<TrackingPackages> {
  List<ExpeditionModel> expeditions = [
 ExpeditionModel(
  id: "EXP-2025-001",
  trackingNumber: "KABA-2025-001",
  partnerId: "PARTNER-123",
  status: "EN_COURS_EXPEDITION",
  ligneId: "LINE-001",
  adresseOrigine: "Lomé, Togo",
  adresseDestination: "Accra, Ghana",
  contactOrigine: "Kossi Agbeko",
  contactDestination: "Ama Boateng",
  telephoneOrigine: "+22890123456",
  telephoneDestination: "+233541234567",
  methodeLivraison: "Express",
  methodeCollecte: "Point relais",
  estimatedDelivery: DateTime.now().add(const Duration(days: 3)),
  actualDelivery: null,
  currentLocation: "Frontière Togo - Ghana",
  createdAt: DateTime.now().subtract(const Duration(days: 1)),
  updatedAt: DateTime.now(),
  colis: [
  PackageModel(
  id: "PKG-001",
  expeditionId: "EXP-2025-001",
  description: "5 Vêtements",
  poids: 3.5,
  adresseDestination: "Accra Mall, Accra",
  departureTown: "Lomé",
  arrivalTown: "Accra",
  recipientPhoneNumber: "+233541234567",
  ),
  PackageModel(
  id: "PKG-002",
  expeditionId: "EXP-2025-001",
  description: "10 Sacs",
  poids: 12.0,
  adresseDestination: "Osu, Accra",
  departureTown: "Lomé",
  arrivalTown: "Accra",
  recipientPhoneNumber: "+233502345678",
  ),
  ],
  ligne: LineModel(
  id: "LINE-001",
  departId: "CITY-LOME",
  arriveeId: "CITY-ACCRA",
  active: true,
  partenaireId: "PARTNER-123",
  prixParKg: 1500.0,
  dureeJours: 3,
  depart: CityModel(
  id: "CITY-LOME",
  nom: "Lomé",
  paysId: "TG",
  pays: {"code": "TG", "nom": "Togo"},
  ),
  arrivee: CityModel(
  id: "CITY-ACCRA",
  nom: "Accra",
  paysId: "GH",
  pays: {"code": "GH", "nom": "Ghana"},
  ),
  ),
  createdBy: CreatedByModel(
  id: "USER-001",
  name: "Admin KABA",
  email: "admin@kaba.com",
  ),
   colisDetail: ColisDetail(
     description: "Ordinateur portable HP",
     poids: 2.5, // en kg
     ligneId: "LIGNE-1234",
     prixParKg: 1500,
     prixBase: 2000,
     reductionAppliquee: 100,
     pourcentageReduction: 10,
     prixFinal: 3350,
   ),

 ),
 ExpeditionModel(
  id: "EXP-2025-001",
  trackingNumber: "KABA-2025-001",
  partnerId: "PARTNER-123",
  status: "EN_COURS_EXPEDITION",
  ligneId: "LINE-001",
  adresseOrigine: "Lomé, Togo",
  adresseDestination: "Accra, Ghana",
  contactOrigine: "Kossi Agbeko",
  contactDestination: "Ama Boateng",
  telephoneOrigine: "+22890123456",
  telephoneDestination: "+233541234567",
  methodeLivraison: "Express",
  methodeCollecte: "Point relais",
  estimatedDelivery: DateTime.now().add(const Duration(days: 3)),
  actualDelivery: null,
  currentLocation: "Frontière Togo - Ghana",
  createdAt: DateTime.now().subtract(const Duration(days: 1)),
  updatedAt: DateTime.now(),
  colis: [
  PackageModel(
  id: "PKG-001",
  expeditionId: "EXP-2025-001",
  description: "5 Vêtements",
  poids: 3.5,
  adresseDestination: "Accra Mall, Accra",
  departureTown: "Lomé",
  arrivalTown: "Accra",
  recipientPhoneNumber: "+233541234567",
  ),
  PackageModel(
  id: "PKG-002",
  expeditionId: "EXP-2025-001",
  description: "10 Sacs",
  poids: 12.0,
  adresseDestination: "Osu, Accra",
  departureTown: "Lomé",
  arrivalTown: "Accra",
  recipientPhoneNumber: "+233502345678",
  ),
  ],
  ligne: LineModel(
  id: "LINE-001",
  departId: "CITY-LOME",
  arriveeId: "CITY-ACCRA",
  active: true,
  partenaireId: "PARTNER-123",
  prixParKg: 1500.0,
  dureeJours: 3,
  depart: CityModel(
  id: "CITY-LOME",
  nom: "Lomé",
  paysId: "TG",
  pays: {"code": "TG", "nom": "Togo"},
  ),
  arrivee: CityModel(
  id: "CITY-ACCRA",
  nom: "Accra",
  paysId: "GH",
  pays: {"code": "GH", "nom": "Ghana"},
  ),
  ),
  createdBy: CreatedByModel(
  id: "USER-001",
  name: "Admin KABA",
  email: "admin@kaba.com",
  ),
   colisDetail: ColisDetail(
     description: "Ordinateur portable HP",
     poids: 2.5, // en kg
     ligneId: "LIGNE-1234",
     prixParKg: 1500,
     prixBase: 2000,
     reductionAppliquee: 100,
     pourcentageReduction: 10,
     prixFinal: 3350,
   ),

 ),
  ];
  ExpeditionBloc expeditionBloc = ExpeditionBloc();
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    expeditionBloc = BlocProvider.of<ExpeditionBloc>(context);
   // expeditionBloc.add(GetUserExpeditionEvent());
  }

  @override
  Widget build(BuildContext context) {
    isLoading = false;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: BlocConsumer<ExpeditionBloc, ExpeditionState>(
          listener: (context, state) {
            if(state is UserExpeditionsLoaded){
              expeditions = state.expeditions;

              isLoading = false;
            }
          },
          builder: (context, state) {
            return isLoading?CircularProgressIndicator():
            Column(
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
                     Text("Suivi du colis",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),)
                    ],
                  ),
                  ),
                ),
                Container(
                  width:size.width,
                  height: size.height-100,

                  child: ListView.builder(
                      itemCount: expeditions.length,
                      itemBuilder: (context,index){
                        return ExpeditionWidget(context:context,expedition: expeditions[index]);
                      }),
                ),
              ],
            );
          },
        )
    );
  }
}
