
  import 'dart:developer';

import 'package:get/get.dart';

import '../../../../Services/network/RestApis.dart';
import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/var/var_app.dart';
import 'getCurrentRequest.dart';
import 'setMapPins.dart';
import 'stop_audio.dart';

Future<void> rideRequestAccept({bool deCline = false}) async {
DashboardController _dashboardController=  Get.put(DashboardController());

    appStore.setLoading(true);

    Map req = {
      "id": _dashboardController.servicesListData!.id,
      if (!deCline) "driver_id": sharedPref.getInt(USER_ID),
      "is_accept": deCline ? "0" : "1",
    };

    // timeSetCalled = false;
   _dashboardController.emitStateBool( "timeSetCalled" , false); 
    await rideRequestResPond(request: req).then((value) async {
      stopAudio();
      appStore.setLoading(false);

      getCurrentRequest();

      if (deCline) {
        _dashboardController.rideService.updateStatusOfRide(rideID: _dashboardController.servicesListData!.id, req: {
          'on_stream_api_call': 0, /* 'driver_id': null*/
        });

        // sharedPref.setInt(IS_ONLINE,0);

        // isOnLine=false;

         _dashboardController.emitStateService( "servicesListData" , null);

        _dashboardController. polyLines.clear();

        sharedPref.remove(ON_RIDE_MODEL);

        sharedPref.remove(IS_TIME2);

        setMapPins();
      }
    }).catchError((error) {
      stopAudio();
      setMapPins();

      appStore.setLoading(false);

      log(error.toString());
    });
  }

