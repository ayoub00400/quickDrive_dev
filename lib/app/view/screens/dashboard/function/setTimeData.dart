
  import 'dart:convert';

import 'package:get/get.dart';

import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../model/CurrentRequestModel.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/var/var_app.dart';
import 'cancelRideTimeOut.dart';
import 'startTimerfunction.dart';

Future<void> setTimeData() async {
DashboardController _dashboardController=  Get.put(DashboardController());

    if (sharedPref.getString(IS_TIME2) == null) {
      
      // duration = startTime;
               _dashboardController.emitStateInt( "duration" , _dashboardController. startTime); 

      await sharedPref.setString(IS_TIME2, DateTime.now().add(Duration(seconds:  _dashboardController.startTime)).toString());

      startTimer(tag: "line222");
    } else {
               _dashboardController.emitStateInt( "duration" ,DateTime.parse(sharedPref.getString(IS_TIME2)!).difference(DateTime.now()).inSeconds); 

      // duration = DateTime.parse(sharedPref.getString(IS_TIME2)!).difference(DateTime.now()).inSeconds;

      await sharedPref.setString(IS_TIME2, DateTime.now().add(Duration(seconds: _dashboardController. duration)).toString());

      if (_dashboardController.duration < 0) {
        await sharedPref.remove(IS_TIME2);

        sharedPref.remove(ON_RIDE_MODEL);

        if (sharedPref.getString("RIDE_ID_IS") == null || sharedPref.getString("RIDE_ID_IS") == "${_dashboardController.riderId}") {
          return cancelRideTimeOut();
        } else {
          // duration = startTime;
               _dashboardController.emitStateInt( "duration" ,_dashboardController.startTime); 

          // setState(() {});

          startTimer(tag: "line248");
        }

        // duration=startTime;

        // return cancelRideTimeOut();
      }

      sharedPref.setString("RIDE_ID_IS", "${_dashboardController.riderId}");

      if (_dashboardController.duration > 0) {
        if (sharedPref.getString(ON_RIDE_MODEL) != null) {
          // servicesListData = OnRideRequest.fromJson(jsonDecode(sharedPref.getString(ON_RIDE_MODEL)!));
        _dashboardController.emitStateService( "servicesListData" , OnRideRequest.fromJson(jsonDecode(sharedPref.getString(ON_RIDE_MODEL)!)));

          // setState(() {});
        }

        startTimer(tag: "line238");
      } else {}
    }
  }
