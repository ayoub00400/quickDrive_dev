
  import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/Images.dart';

Future<void> setSourceAndDestinationIcons() async {
DashboardController _dashboardController=  Get.put(DashboardController());

    // driverIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), DriverIcon);
    _dashboardController.emitStateBitmap( "driverIcon" , await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), DriverIcon));

    if ( _dashboardController.servicesListData != null)
     _dashboardController. servicesListData!.status != IN_PROGRESS
          ?  _dashboardController.sourceIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), SourceIcon)
          :  _dashboardController.destinationIcon =
              await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), DestinationIcon);
  }
