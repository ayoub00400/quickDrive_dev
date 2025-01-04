
  import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/Extensions/app_common.dart';
import '../../../../utils/var/var_app.dart';
import '../../LocationPermissionScreen.dart';
import 'startLocationTracking.dart';

Future<void> locationPermission() async {
DashboardController _dashboardController=  Get.put(DashboardController());

    var serviceStatusStream = Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.disabled) {
        // locationEnable = false;
               _dashboardController.emitStateBool( "locationEnable" , false); 

        Future.delayed(
          Duration(seconds: 1),
          () {
            launchScreen(navigatorKey.currentState!.overlay!.context, LocationPermissionScreen());
          },
        );
      } else if (status == ServiceStatus.enabled) {
        // locationEnable = true;
                _dashboardController.emitStateBool( "locationEnable" , true); 
        startLocationTracking();

        if (locationScreenKey.currentContext != null) {
          if (Navigator.canPop(navigatorKey.currentState!.overlay!.context)) {
            Navigator.pop(navigatorKey.currentState!.overlay!.context);
          }
        }
      }
    });

      _dashboardController.emitStateStream( "serviceStatusStream" , serviceStatusStream );

  }
