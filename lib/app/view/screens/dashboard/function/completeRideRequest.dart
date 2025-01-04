
  import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../Services/network/RestApis.dart';
import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/Extensions/app_common.dart';
import '../../../../utils/Images.dart';
import '../../../../utils/var/var_app.dart';
import 'getCurrentRequest.dart';

import 'package:taxi_driver/app/view/screens/dashboard/function/map/setMapPins.dart';
// Notice : This problem is on your default app also

import 'dart:async';


import 'dart:developer' as developer;

// import 'package:just_audio/just_audio.dart';
 

import 'package:taxi_driver/app/utils/Extensions/StringExtensions.dart';




 

 


Future<void> completeRideRequest() async {
DashboardController _dashboardController=  Get.put(DashboardController());

    appStore.setLoading(true);

    Map req = {
      "id":_dashboardController. servicesListData!.id,
      "service_id": _dashboardController.servicesListData!.serviceId,
      "end_latitude": _dashboardController. driverLocation!.latitude,
      "end_longitude": _dashboardController.driverLocation!.longitude,
      "end_address":_dashboardController. endLocationAddress,
      "distance": _dashboardController.totalDistance,
      if (_dashboardController.extraChargeList.isNotEmpty) "extra_charges": _dashboardController.extraChargeList,
      if (_dashboardController.extraChargeList.isNotEmpty) "extra_charges_amount": _dashboardController.extraChargeAmount,
    };

    log(req);

    await completeRide(request: req).then((value) async {
      chatMessageService.exportChat(
          rideId: _dashboardController.servicesListData!.id.toString(),
          senderId: sharedPref.getString(UID).validate(),
          receiverId: _dashboardController.riderData!.uid.validate());

      try {
        await _dashboardController.rideService.updateStatusOfRide(rideID: _dashboardController.servicesListData!.id, req: {'on_rider_stream_api_call': 0});
      } catch (e) {
        print("Error Found:::$e");
      }

      // sourceIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), SourceIcon);
      _dashboardController.emitStateBitmap( "sourceIcon" , await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), SourceIcon));

      appStore.setLoading(false);

      getCurrentRequest();
    }).catchError((error) {
      chatMessageService.exportChat(
          rideId: _dashboardController.servicesListData!.id.toString(),
          senderId: sharedPref.getString(UID).validate(),
          receiverId: _dashboardController.riderData!.uid.validate());

      appStore.setLoading(false);

      log(error.toString());
    });
  }
