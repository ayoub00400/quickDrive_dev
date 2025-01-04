
  import 'dart:convert';

import 'package:get/get.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'dart:developer' as developer;

import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/var/var_app.dart';
import 'cancelTimer.dart';
import 'getCurrentRequest.dart';

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

  void onEvent(PusherEvent event) {
DashboardController _dashboardController=  Get.put(DashboardController());

    if (event.data != null) {
      Map<String, dynamic> data = jsonDecode(event.data.toString());
      if (data['action'] != null && data['action'] == 'acceptOffer') {
        if (data['data'] != null &&
            data['data'] != {} &&
            data['data'].isNotEmpty &&
            int.parse(data['data'][0]['driver_id'].toString()) == sharedPref.getInt(USER_ID)) getCurrentRequest();

        {
          getCurrentRequest( );
        }
      }

      if (data['action'] != null && data['action']['action'] == 'new_ride_request') {
        if (data['action']['drivers_id'] != null) {
          if ((data['action']['drivers_id'] as List).contains(sharedPref.getInt(USER_ID))) {
            developer.log('Audio play condition met.');
            // audioPlayWithLimit();
            cancelTimer();
               _dashboardController.emitStateBool( "sendPrice" , false); 
            // setState(() {});
          }
        }
      }
    } else {
      developer.log('condition false');
    }
  }