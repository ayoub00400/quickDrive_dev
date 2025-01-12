import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:taxi_driver/app/view/screens/SplashScreen.dart';
import 'package:taxi_driver/app/view/screens/dashboard/dashboard.dart';
import 'dart:developer' as developer;

import '../../../../Services/bg_notification_service.dart';
import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../model/RiderModel.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/var/var_app.dart';
import 'cancelTimer.dart';
import 'getCurrentRequest.dart';
  @pragma('vm:entry-point')

@pragma('vm:entry-point')
void initPusher() async {
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  try {
    await pusher.init(
      apiKey: '5ceccff5f1a761c6b515',
      cluster: 'ap2',
      onConnectionStateChange: onConnectionStateChange,
      onError: onError,
      onSubscriptionSucceeded: onSubscriptionSucceeded,
      onEvent: onEvent,
      onSubscriptionError: onSubscriptionError,
      onDecryptionFailure: onDecryptionFailure,
      onMemberAdded: onMemberAdded,
      onMemberRemoved: onMemberRemoved,
    );

    await pusher.subscribe(channelName: 'ride');

    await pusher.connect();

    developer.log('connected');
  } catch (e) {
    developer.log("ERROR: $e");
  }
}

void onConnectionStateChange(dynamic currentState, dynamic previousState) {
  developer.log("Connection: $currentState");
}

void onError(String message, int? code, dynamic e) {
  developer.log("onError: $message code: $code exception: $e");
}

void onSubscriptionSucceeded(String channelName, dynamic data) {
  developer.log("onSubscriptionSucceeded: $channelName data: $data");
}

void onSubscriptionError(String message, dynamic e) {
  developer.log("onSubscriptionError: $message Exception: $e");
}

void onDecryptionFailure(String event, String reason) {
  developer.log("onDecryptionFailure: $event reason: $reason");
}

void onMemberAdded(String channelName, PusherMember member) {
  developer.log("onMemberAdded: $channelName member: $member");
}

void onMemberRemoved(String channelName, PusherMember member) {
  developer.log("onMemberRemoved: $channelName member: $member");
}
  @pragma('vm:entry-point')

void showTopSnackBar(
  context,
  String message, {
  Duration? duration,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      dismissDirection: DismissDirection.up,
      duration: duration ?? const Duration(seconds: 3),
      backgroundColor: Colors.black87,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 100, left: 10, right: 10),
      behavior: SnackBarBehavior.floating,
      content: Text(
        message,
        style: const TextStyle(
          fontSize: textSecondarySizeGlobal,
        ),
      ),
    ),
  );
}

@pragma('vm:entry-point')
void onEvent(PusherEvent event) {
      // showTopSnackBar(Get.context, 'you are assigne as driver for scheduled ride');



  if (event.data != null) {
    Map<String, dynamic> data = jsonDecode(event.data.toString());

     if (data['action'] != null && data['action'] == 'acceptOffer' || data['action'] == 'scheduledRideAccepted') {
      if (data['data'] != null &&
          data['data'] != {} &&
          data['data'].isNotEmpty &&
          int.parse(data['data'][0]['driver_id'].toString()) == sharedPref.getInt(USER_ID))
          
          {
        Get.to(    ScreenLaoding());
            getCurrentRequest();
          } 



    }
if (data['data'] != null && data['data']['driver_id'] == sharedPref.getInt(USER_ID)) {
    // Get.to(SplashScreen());
getCurrentRequest();
    }
   

Logger().d('karim data : $data');
    if (data['action'] != null && data['action'] == 'acceptScheduledOffer') {

      Get.off(ScreenLaoding());
      showTopSnackBar(Get.context, 'you are assigne as driver for scheduled ride');
    }

   

    if (data['action'] != null && data['action']['action'] == 'new_ride_request') {
      if (data['action']['drivers_id'] != null) {
        if ((data['action']['drivers_id'] as List).contains(sharedPref.getInt(USER_ID))) {
  DashboardController _dashboardController = Get.put(DashboardController());

          developer.log('Audio play condition met.');

          cancelTimer();
          _dashboardController.emitStateBool("sendPrice", false);
          // setState(() {});
        }
      }
    }

    if (data['action'] != null && data['action']['action'] == 'new_scheduled_ride_request') {
      if (data['action']['drivers_id'] != null) {
        if ((data['action']['drivers_id'] as List).contains(sharedPref.getInt(USER_ID))) {
  DashboardController _dashboardController = Get.put(DashboardController());

          _dashboardController.fetshScheduledRideDetails(data["rideRequestId"]);
          NotificationWithSoundService.player.stop();
          audioPlayWithLimit();
        }
      }
    }

    if (data['action'] != null && data['action']['action'] == 'acceptScheduledOffer') {
          Logger().d('karim data : $data');

      if (data['action']['drivers_id'] != null) {
        if ((data['action']['drivers_id'] as List).contains(sharedPref.getInt(USER_ID))) {

          Logger().d('karim data : +data');
  DashboardController _dashboardController = Get.put(DashboardController());

          _dashboardController.fetshScheduledRideDetails(data["rideRequestId"]);

          // Get.off(DashboardScreen());
          NotificationWithSoundService.player.stop();
          audioPlayWithLimit();
        }
      }
    }

    if (data['action'] != null && data['action'] == 'scheduledRideAccepted') {
      showTopSnackBar(Get.context, 'you are assigne as driver for scheduled ride');
    // Get.to(SplashScreen());

    }

    
    if (data['data'] != null && data['data']['driver_id'] == sharedPref.getInt(USER_ID)) {
    // Get.to(SplashScreen());

    }
  } else {
    developer.log('condition false');
  }
}

Future<void> audioPlayWithLimit() async {
  try {
    await NotificationWithSoundService.player.setReleaseMode(ReleaseMode.loop);
    await NotificationWithSoundService.player
      ..play(AssetSource('sounds/request_sound.aac'));
  } catch (e) {}
}

class ScreenLaoding extends StatefulWidget {
  const ScreenLaoding({super.key});

  @override
  State<ScreenLaoding> createState() => _ScreenLaodingState();
}

class _ScreenLaodingState extends State<ScreenLaoding> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer(Duration(seconds: 1), () {
      Get.to(DashboardScreen());
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
    
    body: Center(child: CircularProgressIndicator( ),),);
  }
}