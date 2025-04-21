import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localizations/AppLocalizations.dart';
import '../../state_management/out_of_app_order/additionnal_info_state.dart';

Widget CanAddAdditionnInfo(BuildContext context,WidgetRef ref){
  return Row(

    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      GestureDetector(
        onTap: (){
          ref.watch(additionnalInfoProvider.notifier).setCan_add_address_info(true);
        },
        child: Container(
          decoration: BoxDecoration(
            color:   Colors.green.withAlpha(100),
            borderRadius: BorderRadius.circular(5),

          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text("${AppLocalizations.of(context)!.translate('yes')}",),
          ),
        ),
      ),
      SizedBox(width: 10,),
      GestureDetector(
        onTap: (){
          ref.watch(additionnalInfoProvider.notifier).setCan_add_address_info(false);
                 },
        child: Container(
          decoration: BoxDecoration(
            color: KColors.primaryColor,
            borderRadius: BorderRadius.circular(5),

          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text("${AppLocalizations.of(context)!.translate('no')}",style: TextStyle(color: Colors.white),),
          ),
        ),
      ),
    ],
  );
}

