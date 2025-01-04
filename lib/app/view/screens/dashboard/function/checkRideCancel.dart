
  import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taxi_driver/app/view/screens/dashboard/function/stop_audio.dart';
import '../../../../controller/dashboard/dashboard_controller.dart';
// Notice : This problem is on your default app also




// import 'package:just_audio/just_audio.dart';










// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';








import 'package:taxi_driver/app/utils/Extensions/StringExtensions.dart';






 
 

import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/Extensions/app_common.dart';
import '../../../../utils/var/var_app.dart';
import '../../../../Services/network/RestApis.dart';
import '../../../../utils/Constants.dart';
import 'setMapPins.dart';
import 'triggerCanceledPopup.dart';

void checkRideCancel() async {
DashboardController _dashboardController=  Get.put(DashboardController());

    if (_dashboardController.rideCancelDetected) return;

    // rideCancelDetected = true;
             WidgetsBinding.instance.addPostFrameCallback((_)  =>    _dashboardController.emitStateBool( "rideCancelDetected" , false)  ); 

    appStore.setLoading(true);

    sharedPref.remove(ON_RIDE_MODEL);

    sharedPref.remove(IS_TIME2);

    await rideDetail(rideId:_dashboardController. servicesListData!.id).then((value) {
      appStore.setLoading(false);

      if (value.data!.status == CANCELED && value.data!.cancelBy == RIDER) {
         _dashboardController.  polyLines.clear();

        setMapPins();

        stopAudio();
       triggerCanceledPopup(reason: value.data!.reason.validate());
      }
    }).catchError((error) {
      appStore.setLoading(false);

      log(error.toString());
    });
  }