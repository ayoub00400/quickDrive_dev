 import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Notice : This problem is on your default app also

import 'dart:async';

import 'dart:convert';

import 'dart:developer' as developer;
 
// import 'package:just_audio/just_audio.dart';

 

// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
 

import 'package:taxi_driver/app/utils/Extensions/StringExtensions.dart';
 

 

 

 
import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/Colors.dart';
import '../../../../utils/Constants.dart';

Future<void> setPolyLines() async {
    // if (servicesListData != null) _polyLines.clear();
DashboardController _dashboardController=  Get.put(DashboardController());

    try {
      var result = await  _dashboardController.polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: GOOGLE_MAP_API_KEY,

        request: PolylineRequest(
            origin: PointLatLng(_dashboardController.driverLocation!.latitude, _dashboardController.driverLocation!.longitude),
            destination:_dashboardController. servicesListData!.status != IN_PROGRESS
                ? PointLatLng(double.parse(_dashboardController.servicesListData!.startLatitude.validate()),
                    double.parse(_dashboardController.servicesListData!.startLongitude.validate()))
                : PointLatLng(double.parse(_dashboardController.servicesListData!.endLatitude.validate()),
                    double.parse(_dashboardController.servicesListData!.endLongitude.validate())),
            mode: TravelMode.driving),
 
      );

      if (result.points.isNotEmpty) {
     _dashboardController.   polylineCoordinates.clear();

        result.points.forEach((element) {
        _dashboardController.  polylineCoordinatesAdd(LatLng(element.latitude, element.longitude));
        });

       _dashboardController.  polyLines.clear();

       _dashboardController.  polyLines.add(
          Polyline(
            visible: true,
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            polylineId: PolylineId('poly'),
            color: polyLineColor,
            points:   _dashboardController.polylineCoordinates,
          ),
        );
         _dashboardController. update();

        // setState(() {});
      }
    } catch (e) {}
  }