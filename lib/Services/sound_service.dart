import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'dart:developer' as developer;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi_driver/Services/RideService.dart';
import 'package:taxi_driver/network/RestApis.dart';

import '../../utils/constants.dart';
import '../main.dart';
import '../model/RideDetailModel.dart';
import '../network/NetworkUtils.dart';
import '../utils/Common.dart';
import '../utils/Extensions/app_common.dart';

final player = AudioPlayer();

class SoundService {
  static const int notificationId = 888;

  static const String channelDescription = 'This channel is used for important notifications';
  static const String channelId = 'high_importance_channel';
  static const String channelName = 'High Importance Notifications';

  static const String notificationIcon = '@mipmap/ic_launcher';
  static const String notificationTitle = 'Hisba Makhzoun';
  static const String notificationSound = 'notification_sound';

  static const oneNotificationChannel = AndroidNotificationChannel(
    channelId,
    channelName,
    description: '$channelDescription.',
    importance: Importance.max,
    playSound: true,
  );

  static const oneNotificationChannel1 = AndroidNotificationChannel(
    '${channelId}1',
    '${channelName}1',
    description: '${channelDescription}1.',
    importance: Importance.max,
  );

  static const groupNotificationChannel = AndroidNotificationChannel(
    '${channelId}2',
    '${channelName}2',
    description: '${channelDescription}2',
    importance: Importance.max,
    playSound: true,
  );

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin()
    ..initialize(
      const InitializationSettings(android: AndroidInitializationSettings(notificationIcon)),
    );

  static Future<void> initializeService() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(oneNotificationChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(oneNotificationChannel1);
  }

  static void stopAudio() async {
    await player.stop(); // Stops the sound immediately

    // _timer?.cancel(); // Cancel the timer if it's still active
  }

  static Future<void> audioPlayWithLimit() async {
    try {
      Timer(Duration(seconds: 30), () {
        stopSound();
      });
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource('sounds/request_sound.aac'));
      developer.log('Sound playback started.');
    } catch (e) {
      developer.log('Error in audio playback: $e');
    }
    // Start playing the audio

    stopAudio();

    await player.setReleaseMode(ReleaseMode.loop);

    await player.play(AssetSource('sounds/request_sound.aac'));
  }

  static Future<void> showNotification(String message) async {
    audioPlayWithLimit();
    flutterLocalNotificationsPlugin.show(
      Random().nextInt(10000),
      'Notification Title', // Use a clean and concise title
      message,
      NotificationDetails(
        android: AndroidNotificationDetails(
          oneNotificationChannel.id,
          oneNotificationChannel.name,
          channelDescription: oneNotificationChannel.description,
          importance: Importance.high,
          priority: Priority.max,
          color: Colors.deepOrange, // Use a clean, flat color
          playSound: true,
          icon: notificationIcon,
          styleInformation: BigTextStyleInformation(
            message,
            htmlFormatContent: true,
            htmlFormatTitle: true,
          ),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}

Future<void> stopSound() async {
  await player.setReleaseMode(ReleaseMode.stop);
}
