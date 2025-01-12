
  import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_driver/app/view/screens/dashboard/function/walletCheckApi.dart';

import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/Common.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/Extensions/LiveStream.dart';
import '../../../../utils/Images.dart';
import '../../../../utils/var/var_app.dart';
import 'getCurrentRequest.dart';
import 'getSettings.dart';
import 'setSourceAndDestinationIcons.dart';
import 'startLocationTracking.dart';

void init() async {
DashboardController _dashboardController=  Get.put(DashboardController());

   var _messageSubscription =_dashboardController.messageController.stream.listen((message) {
      getCurrentRequest();
    });

        Get.put( DashboardController()).emitStateLatLng( "messageSubscription" ,_messageSubscription);


    await checkPermission();

    Geolocator.getPositionStream().listen((event) {
      // driverLocation = LatLng(event.latitude, event.longitude);
      Get.put( DashboardController()).emitStateLatLng( "driverLocation" , LatLng(event.latitude, event.longitude));
 
                  Get.put( DashboardController()).update();
    });

    LiveStream().on(CHANGE_LANGUAGE, (p0) {
                  Get.put( DashboardController()).update();
    });

    walletCheckApi(Get. context!);

  //  var _driverIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), DriverIcon);
  _dashboardController.emitStateBitmap( "driverIcon" ,  await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), DriverIcon));

    getCurrentRequest();

    // mqttForUser();

    // setTimeData();

    // polylinePoints = PolylinePoints();

      _dashboardController.emitStatePolyline( "polylinePoints" ,   PolylinePoints());


    getSettings();

    // driverIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), DriverIcon);
  _dashboardController.emitStateBitmap( "driverIcon" , await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), DriverIcon));
    // sourceIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), SourceIcon);
  _dashboardController.emitStateBitmap( "sourceIcon" , await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), SourceIcon));

    // destinationIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), DestinationIcon);
  _dashboardController.emitStateBitmap( "destinationIcon" ,  await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), DestinationIcon));

    if (appStore.isLoggedIn) {
      startLocationTracking();
    }

    setSourceAndDestinationIcons();
  }
