import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/src/audioplayer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi_driver/Services/sound_service.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';

import '../../utils/constants.dart';
import '../main.dart';
import '../model/FRideBookingModel.dart';
import '../utils/FirebaseOption.dart';
import 'RideService.dart';

class NotificationWithSoundService {
  static const int notificationId = 888;
  static AudioPlayer player = AudioPlayer();

  static const String channelDescription =
      'This channel is used for important notifications';
  static const String channelId = 'high_importance_channel';
  static const String channelName = 'High Importance Notifications';

  static const String notificationIcon = '@mipmap/ic_launcher';
  static const String notificationTitle = 'Quick Ride';

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

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin()
        ..initialize(
          const InitializationSettings(
              android: AndroidInitializationSettings(notificationIcon)),
        );

  static final service = FlutterBackgroundService();

  @pragma('vm:entry-point')
  static Future<void> initializeService() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(oneNotificationChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(oneNotificationChannel1);

    await service.configure(
        iosConfiguration: IosConfiguration(),
        androidConfiguration: AndroidConfiguration(
            onStart: _onStart,
            autoStartOnBoot: true,
            autoStart: true,
            isForegroundMode: true,
            foregroundServiceNotificationId: notificationId));
  }

  @pragma('vm:entry-point')
  static Future<void> _onStart(ServiceInstance service) async {
    // Only available for flutter 3.0.0 and later
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.reload();
    String selectedLang = prefs.getString(SELECTED_LANGUAGE_CODE) ?? 'ar';
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    flutterLocalNotificationsPlugin.show(
      notificationId,
      selectedLang == 'en'
          ? 'Online'
          : selectedLang == 'fr'
              ? 'Connecter'
              : 'متصل',
      selectedLang == 'en'
          ? 'Ready for getting rides'
          : selectedLang == 'fr'
              ? 'Prêt à faire des promenades'
              : 'جاهز لاستقبال الطلبات',
      NotificationDetails(
        android: AndroidNotificationDetails(
          oneNotificationChannel1.id,
          'MY FOREGROUND SERVICE',
          icon: notificationIcon,
          ongoing: true,
        ),
      ),
    );
    getRireRequests();

    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }

  @pragma('vm:entry-point')
  static getRireRequests() async {
    RideService rideService = RideService();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.reload();
    String selectedLang = prefs.getString(SELECTED_LANGUAGE_CODE) ?? 'ar';
    Stream<QuerySnapshot<Object?>> result =
        rideService.fetchRide(userId: prefs.getInt(USER_ID));

    bool isNotificationShown =
        false; // Flag to ensure notification triggers only once

    result.listen((event) {
      List<FRideBookingModel> data = event.docs.map((e) {
        return FRideBookingModel.fromJson(e.data() as Map<String, dynamic>);
      }).toList();

      print('-----------my rider id ----------=${prefs.getInt(USER_ID)}');
      print('-----------data from firebase----------=${data}');
      if (data == [] || data.isEmpty || data.length == 0) {
        isNotificationShown = false;
        print("-----------data from firebase----------= add ");
        stopSoundnotificatiion();
      }
      if (data.isNotEmpty &&
          data[0].status == NEW_RIDE_REQUESTED &&
          !isNotificationShown) {
        // Trigger the notification and set the flag
        isNotificationShown = true;
        SoundService.audioPlayWithLimit();
        flutterLocalNotificationsPlugin.show(
          Random().nextInt(10000),
          selectedLang == 'en'
              ? 'Ride Request'
              : selectedLang == 'fr'
                  ? 'demande de trajet'
                  : "طلب توصيل بضاعة جديد", // Use a clean and concise title
          selectedLang == 'en'
              ? "Shipment pending, check now!"
              : selectedLang == 'fr'
                  ? '"Expédition en attente, vérifiez !"'
                  : "شحنة بانتظارك، تحقق من الطلب!",
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
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
        Timer(Duration(seconds: 10), () {
          isNotificationShown = false;
        });
      } else if (data.isNotEmpty && data[0].status != NEW_RIDE_REQUESTED) {
        // isNotificationShown = false;

        // Reset the flag if the ride status changes
      }
    });
  }

  static void stopAudio() async {
    await player.stop();
  }

  Future<void> audioPlayWithLimit() async {
    try {
      Timer(Duration(seconds: 20), () {
        stopAudio();
      });
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource('sounds/request_sound.aac'));
    } catch (e) {}
  }
}
