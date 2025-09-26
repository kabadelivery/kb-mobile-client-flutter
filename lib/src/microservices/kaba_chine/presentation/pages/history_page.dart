import 'dart:async';

import 'package:KABA/src/microservices/kaba_chine/presentation/bloc/order/order_bloc.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../localizations/AppLocalizations.dart';
import '../../core/utils.dart';
import '../../data/order/delivery_model.dart';
import '../../functions/getRandomDecoys.dart';
import '../bloc/history/history_bloc.dart';
import '../widgets/package.dart';

class DeliveryHistory extends StatefulWidget {
  const DeliveryHistory({super.key});

  @override
  State<DeliveryHistory> createState() => _DeliveryHistoryState();
}

class _DeliveryHistoryState extends State<DeliveryHistory> {
  List<Delivery> deliveryHistory = [];
  bool _isLoading = true;
  bool error = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    BlocProvider.of<HistoryBloc>(context).add(GetHistoryEvent() );
    _timer = Timer.periodic(Duration(seconds: 15), (timer) {
      BlocProvider.of<HistoryBloc>(context).add(GetHistoryEvent() );
      debugPrint("XXX timer");
    });
  }
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    return BlocConsumer<HistoryBloc, HistoryState>(
  listener: (context, state) {
      if(state is GetHistoryState) {
        _isLoading = false;
        error = state.error;
        deliveryHistory = state.deliveries;
        debugPrint("Delivery History: ${error}");
      }
  },
  builder: (context, state) {
    return Column(
      children: [
        Container(
            width: size.width,
            height: 170,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  KabaChineColors.primary,
                  KabaChineColors.primary_darker,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("${AppLocalizations.of(context)!.translate("delivery_history")}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 23),),
                    SizedBox(height: 10),
                    Icon(Icons.history,color: Colors.white,size: 30,)

                  ],
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: KabaChineColors.card.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(Icons.arrow_back_sharp,size: 20,color: KabaChineColors.card,),
                  ),
                ),
              ],
            )
        ),
        SizedBox(height: 10),
        _isLoading?Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(child: MyLoadingProgressWidget(),),
          ],
        ):error?MaterialButton(
          onPressed: () {
            setState(() {
              _isLoading = true;
              error = false;
            });
            BlocProvider.of<HistoryBloc>(context).add(GetHistoryEvent());
          },
          minWidth: 100,
          height: 40,
          color: KabaChineColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "${AppLocalizations.of(context)!.translate("retry")}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ):
        Expanded(

         child:ListView.builder(
            itemCount: deliveryHistory.length==0 ? 1 : deliveryHistory.length,
            shrinkWrap: true, itemBuilder: (BuildContext context, int index)
          {
            if(deliveryHistory.isEmpty) {
              return Center(
                child: Text(
                  "${AppLocalizations.of(context)!.translate("no_delivery_found")}",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
              );
            }else{
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: PackageDeliveryWidget(
                  context: context,
                  delivery: deliveryHistory[index],
                ),
              );
            }


          },
          ),
        )
      ],
    );
  },
);
  }
}
