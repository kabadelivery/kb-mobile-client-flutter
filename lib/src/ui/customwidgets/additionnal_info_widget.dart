import 'package:KABA/src/state_management/out_of_app_order/additionnal_info_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localizations/AppLocalizations.dart';

Widget AdditionnalInfo(BuildContext context, WidgetRef ref, int type, String text) {
  TextEditingController _infoController = TextEditingController();
  _infoController.text = text;
  _infoController.selection = TextSelection.fromPosition(
    TextPosition(offset:text.length),
  );
  return Consumer(
    builder: (context, ref, child) {
      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0x42d2d2d2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _infoController,
                maxLines: 4,
                onChanged: (value) {
                  if (type == 1) {
                    ref.read(additionnalInfoProvider.notifier).setAdditionnalInfo(value);
                    _infoController.text = ref.watch(additionnalInfoProvider).additionnal_info;
                  } else if (type == 2) {
                    ref.read(additionnalInfoProvider.notifier).setAdditionnalAddressInfo(value);
                    _infoController.text = ref.watch(additionnalInfoProvider).additionnal_address_info;
                  }

                  // Déplacer le curseur à la fin du texte

                },
                style: TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  labelStyle: TextStyle(fontSize: 12),
                  labelText: "${AppLocalizations.of(context).translate(
                      type == 1
                          ? 'additional_info'
                          : type == 2
                          ? 'address_additionnal_info'
                          : 'additional_info')}...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      );
    },
  );
}

