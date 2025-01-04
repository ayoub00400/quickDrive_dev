
  import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:developer' as developer;

import '../../../../Services/network/RestApis.dart';
import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/var/var_app.dart';

getSettings() async {
DashboardController _dashboardController=  Get.put(DashboardController());

    return await getAppSetting().then((value) {
      if (value.walletSetting != null) {
       log("walletSetting:::${value.walletSetting}");

        value.walletSetting!.forEach((element) {
          if (element.key == PRESENT_TOPUP_AMOUNT) {
            appStore.setWalletPresetTopUpAmount(element.value ?? PRESENT_TOP_UP_AMOUNT_CONST);
          }

          if (element.key == MIN_AMOUNT_TO_ADD) {
            if (element.value != null) appStore.setMinAmountToAdd(int.parse(element.value!));
          }

          if (element.key == MAX_AMOUNT_TO_ADD) {
            if (element.value != null) appStore.setMaxAmountToAdd(int.parse(element.value!));
          }
        });
      }

      if (value.rideSetting != null) {
    log("rideSetting:::${value.rideSetting}");

        value.rideSetting!.forEach((element) {
          if (element.key == PRESENT_TIP_AMOUNT) {
            appStore.setWalletTipAmount(element.value ?? PRESENT_TOP_UP_AMOUNT_CONST);
          }

          if (element.key == MAX_TIME_FOR_DRIVER_SECOND) {
            // startTime = int.parse(element.value ?? '60');
              _dashboardController.emitStateInt( "startTime" ,int.parse(element.value ?? '60')); 

          }

          if (element.key == APPLY_ADDITIONAL_FEE) {
            appStore.setExtraCharges(element.value ?? '0');
          }
        });
      }

      if (value.currencySetting != null) {
        developer.log("currencySetting:::${value.currencySetting}");

        appStore.setCurrencyCode(value.currencySetting!.symbol ?? currencySymbol);

        appStore.setCurrencyName(value.currencySetting!.code ?? currencyNameConst);

        appStore.setCurrencyPosition(value.currencySetting!.position ?? LEFT);
      }

      if (value.settingModel != null) {
        developer.log("settingModel:::${value.settingModel}");

        appStore.settingModel = value.settingModel!;
      }

      if (value.settingModel!.helpSupportUrl != null) {
        developer.log("settingModel:::${value.settingModel!.helpSupportUrl}");

        appStore.mHelpAndSupport = value.settingModel!.helpSupportUrl!;
      }

      if (value.privacyPolicyModel!.value != null) {
        developer.log("settingModel:::${value.privacyPolicyModel!.value}");

        appStore.privacyPolicy = value.privacyPolicyModel!.value!;
      }

      if (value.termsCondition!.value != null) {
        developer.log("settingModel:::${value.termsCondition!.value}");

        appStore.termsCondition = value.termsCondition!.value!;
      }

      if (value.walletSetting != null && value.walletSetting!.isNotEmpty) {
        developer.log("walletSetting:::${value.walletSetting}");

        appStore.setWalletPresetTopUpAmount(
            value.walletSetting!.firstWhere((element) => element.key == PRESENT_TOPUP_AMOUNT).value ??
                PRESENT_TOP_UP_AMOUNT_CONST);
      }

     _dashboardController. mapAdd(
        Marker(
          markerId: MarkerId("driver"),
          position:_dashboardController. driverLocation!,
          icon:  _dashboardController.driverIcon,
          infoWindow: InfoWindow(title: ''),
        ),
      );

      // setState(() {});
    }).catchError((error, stack) {
      FirebaseCrashlytics.instance.recordError("setting_update_issue::" + error.toString(), stack, fatal: true);

      log('${error.toString()}');
    });
  }
