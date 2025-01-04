
  import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../Services/network/RestApis.dart';
import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/Extensions/app_common.dart';
import '../../../../utils/var/var_app.dart';
import '../../LocationPermissionScreen.dart';
import 'setMapPins.dart';
import 'setPolyLines.dart';

Future<void> startLocationTracking() async {
DashboardController _dashboardController=  Get.put(DashboardController());

     _dashboardController. polyLines.clear();

     _dashboardController. polylineCoordinates.clear();

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((value) async {
      log("=====Location:::${value.latitude}:::${value.longitude}");
      await Geolocator.isLocationServiceEnabled().then((value) async {
        log("======Location:::${value}");
        if (_dashboardController.  locationEnable) {
          final LocationSettings locationSettings =
              LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 100, timeLimit: Duration(seconds: 30));

       var   positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((event) async {
            DateTime? d = DateTime.tryParse(sharedPref.getString("UPDATE_CALL").toString());

            if (d != null && DateTime.now().difference(d).inSeconds > 30) {
              if (appStore.isLoggedIn) {
                // driverLocation = LatLng(event.latitude, event.longitude);
                 _dashboardController.emitStateLatLng( "driverLocation" , LatLng(event.latitude, event.longitude));
                Map req = {
                  "latitude":  _dashboardController.driverLocation!.latitude.toString(),
                  "longitude": _dashboardController. driverLocation!.longitude.toString(),
                };

                sharedPref.setDouble(LATITUDE,  _dashboardController.driverLocation!.latitude);

                sharedPref.setDouble(LONGITUDE, _dashboardController. driverLocation!.longitude);

                await updateStatus(req).then((value) {
                  // setState(() {});
                }).catchError((error) {
                  log(error);
                });

                stutasCount = 0;

                setMapPins();

                if (_dashboardController.servicesListData != null) setPolyLines();
              }

              sharedPref.setString("UPDATE_CALL", DateTime.now().toString());
            } else if (d == null) {
              sharedPref.setString("UPDATE_CALL", DateTime.now().toString());
            }

            
          }
          
          , onError: (error) {
           _dashboardController. positionStream.cancel();
          });
                 _dashboardController.emitStateStream( "positionStream" , positionStream);

        }
      });
    }).catchError((error) {
      Future.delayed(
        Duration(seconds: 1),
        () {
          launchScreen(navigatorKey.currentState!.overlay!.context, LocationPermissionScreen());

          // Navigator.push(context, MaterialPageRoute(builder: (_) => LocationPermissionScreen()));
        },
      );
    });
  }
