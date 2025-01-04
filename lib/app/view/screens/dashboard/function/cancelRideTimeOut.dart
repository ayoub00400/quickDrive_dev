
  import 'dart:developer';

import 'package:get/get.dart';

import '../../../../Services/network/RestApis.dart';
import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/var/var_app.dart';
import 'setMapPins.dart';
import 'stop_audio.dart';

cancelRideTimeOut() {
DashboardController _dashboardController=  Get.put(DashboardController());

    print("CancelByApp:::187");

    Future.delayed(Duration(seconds: 1)).then((value) {
      appStore.setLoading(true);

      try {
        sharedPref.remove(ON_RIDE_MODEL);

        sharedPref.remove(IS_TIME2);

               _dashboardController.emitStateInt( "duration" , _dashboardController. startTime); 
     _dashboardController.emitStateBool( "timeSetCalled" , false);  

        _dashboardController.emitStateService( "servicesListData" , null);

        _dashboardController. polyLines.clear();

        setMapPins();


        // setState(() {});


      } catch (e) {}

      Map req = {
        "id":      _dashboardController.riderId,
        "driver_id": sharedPref.getInt(USER_ID),
        "is_accept": "0",
      };

               _dashboardController.emitStateInt( "duration" , _dashboardController. startTime); 

      rideRequestResPond(request: req).then((value) {
        stopAudio();
        appStore.setLoading(false);
      }).catchError((error) {
        stopAudio();
        appStore.setLoading(false);

        log(error.toString());
      });
    });
  }
