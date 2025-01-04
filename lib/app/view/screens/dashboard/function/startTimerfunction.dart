  

  import 'dart:async';

import 'package:get/get.dart';

import '../../../../Services/network/RestApis.dart';
import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/Extensions/app_common.dart';
import '../../../../utils/var/var_app.dart';
import 'setMapPins.dart';
import 'stop_audio.dart';

Future<void> startTimer({required String tag}) async {
DashboardController _dashboardController=  Get.put(DashboardController());

   _dashboardController .timerData?.cancel();
    print("timer Call :::${tag}");

    // if(timerRunning==true)return;

    // timerRunning=true;

    print("timer Call :257::${tag}");

    // await FlutterRingtonePlayer().stop();

    // await FlutterRingtonePlayer().play(
    //   fromAsset: "images/ringtone.mp3",
    //   android: AndroidSounds.notification,
    //   ios: IosSounds.triTone,
    //   looping: true,
    //   volume: 0.1,
    //   asAlarm: false,
    // );

    const oneSec = const Duration(seconds: 1);

  var  timerDataValue = new Timer.periodic(
      oneSec,
      (Timer timer) {
        // count

        // timer.tick>=duration

        // print("CheckTimerValues::duration${duration} : timer:${timer.tick}");

        if (_dashboardController.duration == 0) {
          // timerRunning=false;

          try {
           _dashboardController. timerData!.cancel();
          } catch (e) {}

          // if (duration == 0) {

          Future.delayed(Duration(seconds: 1)).then((value) {
            // duration = startTime;
               _dashboardController.emitStateInt( "duration" , _dashboardController.startTime); 

            try {
              // FlutterRingtonePlayer().stop();

              timer.cancel();
            } catch (e) {}

            // timeSetCalled = false;
                _dashboardController.emitStateBool( "timeSetCalled" , false); 

            sharedPref.remove(ON_RIDE_MODEL);

            sharedPref.remove(IS_TIME2);

            // servicesListData = null;
        _dashboardController.emitStateService( "servicesListData" , null);

            _dashboardController. polyLines.clear();

            setMapPins();

            // isOnLine=false;

            // setState(() {});
              //  _dashboardController.changeStateInt( "duration" ,_dashboardController.startTime); 

            Map req = {
              "id": _dashboardController. riderId,
              "driver_id": sharedPref.getInt(USER_ID),
              "is_accept": "0",
            };

            rideRequestResPond(request: req).then((value) {
              stopAudio();
              // rideService.updateStatusOfRide(rideID: riderId, req: {'on_stream_api_call': 0, /*'driver_id': null*/});
            }).catchError((error) {
              stopAudio();
              log(error.toString());
            });
          });
        } else {
          if (_dashboardController.timerData != null && _dashboardController.timerData!.isActive) {
        
              _dashboardController.emitStateInt( "duration" ,_dashboardController.duration-1); 
      
          }
        }
      },
    );
              _dashboardController.emitStateTime( "timerData" , timerDataValue ); 

  }
