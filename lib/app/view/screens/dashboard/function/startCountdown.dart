import 'dart:async';
import 'dart:developer' as developer;

import 'package:get/get.dart';
import 'package:taxi_driver/app/view/screens/dashboard/function/cancelRideTimeOut.dart';

import '../../../../controller/dashboard/dashboard_controller.dart';

  //  TODO remove setState
  void startCountdown() {
DashboardController _dashboardController=  Get.put(DashboardController());

    developer.log("startCountdown");
    developer.log("countdown ${_dashboardController. countdown}");
      // countdown = 60; // Start from 60 seconds
      _dashboardController.emitStateInt( "countdown" , 60); 

  _dashboardController.  countdownTimer?.cancel(); // Cancel any existing timer

  var  countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_dashboardController.countdown == 0) {
        timer.cancel();
        cancelRideTimeOut();
      } else {
        // setState(() {
          // countdown--;
          _dashboardController.emitStateInt( "countdown" , _dashboardController. countdown -1);
        // });
      }
    });

    _dashboardController.emitStateTime( "countdownTimer" , countdownTimer);
  }

