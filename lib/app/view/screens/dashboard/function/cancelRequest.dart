
  import 'package:get/get.dart';
import 'package:taxi_driver/app/view/screens/dashboard/function/map/setMapPins.dart';
// Notice : This problem is on your default app also

import 'dart:async';


import 'dart:developer' as developer;

import 'package:get/get.dart';
// import 'package:just_audio/just_audio.dart';
 

import 'package:taxi_driver/app/utils/Extensions/StringExtensions.dart';




 

 

import '../../../../Services/network/RestApis.dart';
import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/Extensions/app_common.dart';
import '../../../../utils/var/var_app.dart';

Future<void> cancelRequest(String? reason) async {
DashboardController _dashboardController=  Get.put(DashboardController());

    Map req = {
      "id":_dashboardController. servicesListData!.id,
      "cancel_by": DRIVER,
      "status": CANCELED,
      "reason": reason,
    };
    print("CancelRIdeCall");
    await rideRequestUpdate(request: req, rideId:_dashboardController.servicesListData!.id).then((value) async {
      print("CancelRIdeCall2");
      print("CancelRIdeCall2CHeck::${value}");
      toast(value.message);

      chatMessageService.exportChat(
          rideId: "",
          senderId: sharedPref.getString(UID).validate(),
          receiverId:_dashboardController. riderData!.uid.validate(),
          onlyDelete: true);

      setMapPins();
    }).catchError((error) {
      setMapPins();

      try {
        chatMessageService.exportChat(
            rideId: "",
            senderId: sharedPref.getString(UID).validate(),
            receiverId:_dashboardController. riderData!.uid.validate(),
            onlyDelete: true);
      } catch (e) {
        developer.log('e.toString() $e');

        throw e;
      }

      log(error.toString());
    });
  }
