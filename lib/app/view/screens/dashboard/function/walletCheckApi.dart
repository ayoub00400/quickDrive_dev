
  import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taxi_driver/app/view/screens/dashboard/function/emptyWalletAlertDialog.dart';

import '../../../../Services/network/RestApis.dart';

Future<void> walletCheckApi(context) async {
    await walletDetailApi().then((value) async {
      if (value.totalAmount! >= value.minAmountToGetRide!) {
        //
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return emptyWalletAlertDialog();
          },
        );
      }
    }).catchError((e) {
      log("Error $e");
    });
  }