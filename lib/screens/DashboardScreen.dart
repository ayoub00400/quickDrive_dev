// Notice : This problem is on your default app also

import 'dart:async';

import 'dart:convert';

import 'dart:developer' as developer;

import 'package:flutter_vector_icons/flutter_vector_icons.dart';
// import 'package:just_audio/just_audio.dart';

import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:dotted_line/dotted_line.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:flutter_mobx/flutter_mobx.dart';

import 'package:google_places_flutter/model/prediction.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';

// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'package:geocoding/geocoding.dart';

import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:pinput/pinput.dart';

import 'package:taxi_driver/screens/ChatScreen.dart';

import 'package:taxi_driver/screens/DetailScreen.dart';

import 'package:taxi_driver/screens/EditProfileScreen.dart';

import 'package:taxi_driver/screens/NotificationScreen.dart';

import 'package:taxi_driver/screens/ReviewScreen.dart';

import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';

import 'package:taxi_driver/utils/Extensions/app_textfield.dart';

import 'package:taxi_driver/utils/Extensions/context_extensions.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:audioplayers/audioplayers.dart';

import '../Services/RideService.dart';

import '../Services/bg_notification_service.dart';
import '../components/AlertScreen.dart';

import '../components/CancelOrderDialog.dart';

import '../components/DrawerComponent.dart';

import '../components/ExtraChargesWidget.dart';

import '../components/RideForWidget.dart';

import '../main.dart';

import '../model/CurrentRequestModel.dart';

import '../model/ExtraChargeRequestModel.dart';

import '../model/FRideBookingModel.dart';

import '../model/RiderModel.dart';

import '../model/UserDetailModel.dart';

import '../model/WalletDetailModel.dart';

import '../network/RestApis.dart';

import '../utils/Colors.dart';

import '../utils/Common.dart';

import '../utils/Constants.dart';

import '../utils/Extensions/AppButtonWidget.dart';

import '../utils/Extensions/ConformationDialog.dart';

import '../utils/Extensions/LiveStream.dart';

import '../utils/Extensions/app_common.dart';

import '../utils/Images.dart';

import 'LocationPermissionScreen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  StreamController _messageController = StreamController.broadcast();

  late StreamSubscription _messageSubscription;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  RideService rideService = RideService();

  Completer<GoogleMapController> _controller = Completer();

  // OtpFieldController otpController = OtpFieldController();

  final otpController = TextEditingController();

  final priceController = TextEditingController();

  late StreamSubscription<ServiceStatus> serviceStatusStream;

  List<RiderModel> riderList = [];

  OnRideRequest? servicesListData;

  UserData? riderData;

  WalletDetailModel? walletDetailModel;

  LatLng? userLatLong;

  final Set<Marker> markers = {};

  Set<Polyline> _polyLines = Set<Polyline>();

  late PolylinePoints polylinePoints;

  List<LatLng> polylineCoordinates = [];

  List<ExtraChargeRequestModel> extraChargeList = [];

  num extraChargeAmount = 0;

  late StreamSubscription<Position> positionStream;

  LocationPermission? permissionData;

  LatLng? driverLocation;

  LatLng? sourceLocation;

  LatLng? destinationLocation;

  // bool timerRunning = false;

  bool timeSetCalled = false;

  bool isOnLine = true;

  bool locationEnable = true;

  bool current_screen = true;

  // bool requestDataFetching = false;

  bool sendPrice = false;

  String? otpCheck;

  String endLocationAddress = '';

  double totalDistance = 0.0;

  late BitmapDescriptor driverIcon;

  late BitmapDescriptor destinationIcon;

  late BitmapDescriptor sourceIcon;

  int reqCheckCounter = 0;

  int startTime = 60;

  int end = 0;

  int duration = 0;

  int count = 0;

  int riderId = 0;

  var estimatedTotalPrice;

  var estimatedDistance;

  var distance_unit;

  // int onStreamApiCall = 0;

  Timer? timerUpdateLocation;

  Timer? timerData;

  bool rideCancelDetected = false;

  bool rideDetailsFetching = false;

  bool requestDataFetching = false;

  // CountdownController? timerController;

  final player = AudioPlayer();

  // Timer? _timer;

  Future<void> audioPlayWithLimit() async {
    try {
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

  // To stop immediately if needed

  void stopAudio() async {
    await player.stop(); // Stops the sound immediately

    // _timer?.cancel(); // Cancel the timer if it's still active
  }

  num totalEarnings = 0;

  void fetchTotalEarning() async {
    await totalEarning().then((value) {
      developer.log('value.toString() = ${value.toString()}');

      totalEarnings = value.totalEarnings!;

      setState(() {});
    }).catchError((error) {
      log(error.toString());
    });
  }

  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  // init pusher

  void initPusher() async {
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

  void onEvent(PusherEvent event) {
    if (event.data != null) {
      Map<String, dynamic> data = jsonDecode(event.data.toString());
      if (data['action'] != null && data['action'] == 'acceptOffer') {
        if (data['data'] != null &&
            data['data'] != {} &&
            data['data'].isNotEmpty &&
            int.parse(data['data'][0]['driver_id'].toString()) ==
                sharedPref.getInt(USER_ID)) getCurrentRequest();

        {
          getCurrentRequest();
        }
      }

      if (data['action'] != null &&
          data['action']['action'] == 'new_ride_request') {
        if (data['action']['drivers_id'] != null) {
          if ((data['action']['drivers_id'] as List)
              .contains(sharedPref.getInt(USER_ID))) {
            developer.log('Audio play condition met.');
            // audioPlayWithLimit();
            cancelTimer();
            sendPrice = false;
            setState(() {});
          }
        }
      }
    } else {
      developer.log('condition false');
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

  @override
  void initState() {
    super.initState();

    // timerController = CountdownController(autoStart: false);

    if (sharedPref.getInt(IS_ONLINE) == 1) {
      setState(() {
        isOnLine = true;
      });
    } else {
      setState(() {
        isOnLine = false;
      });
    }

    locationPermission();

    // Geolocator.getPositionStream().listen((event) {

    //   driverLocation = LatLng(event.latitude, event.longitude);

    //   setState(() {});

    // });

    fetchTotalEarning();

    initPusher();

    init();
  }

  void init() async {
    _messageSubscription = _messageController.stream.listen((message) {
      getCurrentRequest();
    });

    await checkPermission();

    Geolocator.getPositionStream().listen((event) {
      driverLocation = LatLng(event.latitude, event.longitude);

      setState(() {});
    });

    LiveStream().on(CHANGE_LANGUAGE, (p0) {
      setState(() {});
    });

    walletCheckApi();

    driverIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), DriverIcon);

    getCurrentRequest();

    // mqttForUser();

    // setTimeData();

    polylinePoints = PolylinePoints();

    getSettings();

    driverIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), DriverIcon);

    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), SourceIcon);

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), DestinationIcon);

    if (appStore.isLoggedIn) {
      startLocationTracking();
    }

    setSourceAndDestinationIcons();
  }

  Future<void> locationPermission() async {
    serviceStatusStream =
        Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.disabled) {
        locationEnable = false;

        Future.delayed(
          Duration(seconds: 1),
          () {
            launchScreen(navigatorKey.currentState!.overlay!.context,
                LocationPermissionScreen());
          },
        );
      } else if (status == ServiceStatus.enabled) {
        locationEnable = true;

        startLocationTracking();

        if (locationScreenKey.currentContext != null) {
          if (Navigator.canPop(navigatorKey.currentState!.overlay!.context)) {
            Navigator.pop(navigatorKey.currentState!.overlay!.context);
          }
        }
      }
    });
  }

  cancelRideTimeOut() {
    print("CancelByApp:::187");

    Future.delayed(Duration(seconds: 1)).then((value) {
      appStore.setLoading(true);

      try {
        sharedPref.remove(ON_RIDE_MODEL);

        sharedPref.remove(IS_TIME2);

        duration = startTime;

        timeSetCalled = false;

        servicesListData = null;

        _polyLines.clear();

        setMapPins();

        // sharedPref.setInt(IS_ONLINE,0);

        // isOnLine=false;

        setState(() {});

        // FlutterRingtonePlayer().stop();

        // timer.cancel();
      } catch (e) {}

      Map req = {
        "id": riderId,
        "driver_id": sharedPref.getInt(USER_ID),
        "is_accept": "0",
      };

      duration = startTime;

      rideRequestResPond(request: req).then((value) {
        stopAudio();
        appStore.setLoading(false);

        // rideService.updateStatusOfRide(rideID: riderId, req: {'on_stream_api_call': 0, /*'driver_id': null*/});
      }).catchError((error) {
        stopAudio();
        appStore.setLoading(false);

        log(error.toString());
      });
    });
  }

  Future<void> setTimeData() async {
    if (sharedPref.getString(IS_TIME2) == null) {
      duration = startTime;

      await sharedPref.setString(IS_TIME2,
          DateTime.now().add(Duration(seconds: startTime)).toString());

      startTimer(tag: "line222");
    } else {
      duration = DateTime.parse(sharedPref.getString(IS_TIME2)!)
          .difference(DateTime.now())
          .inSeconds;

      await sharedPref.setString(
          IS_TIME2, DateTime.now().add(Duration(seconds: duration)).toString());

      if (duration < 0) {
        await sharedPref.remove(IS_TIME2);

        sharedPref.remove(ON_RIDE_MODEL);

        if (sharedPref.getString("RIDE_ID_IS") == null ||
            sharedPref.getString("RIDE_ID_IS") == "$riderId") {
          return cancelRideTimeOut();
        } else {
          duration = startTime;

          // setState(() {});

          startTimer(tag: "line248");
        }

        // duration=startTime;

        // return cancelRideTimeOut();
      }

      sharedPref.setString("RIDE_ID_IS", "$riderId");

      if (duration > 0) {
        if (sharedPref.getString(ON_RIDE_MODEL) != null) {
          servicesListData = OnRideRequest.fromJson(
              jsonDecode(sharedPref.getString(ON_RIDE_MODEL)!));

          // setState(() {});
        }

        startTimer(tag: "line238");
      } else {}
    }
  }

  Future<void> startTimer({required String tag}) async {
    timerData?.cancel();
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

    timerData = new Timer.periodic(
      oneSec,
      (Timer timer) {
        // count

        // timer.tick>=duration

        print("CheckTimerValues::duration${duration} : timer:${timer.tick}");

        if (duration == 0) {
          // timerRunning=false;

          try {
            timerData!.cancel();
          } catch (e) {}

          // if (duration == 0) {

          Future.delayed(Duration(seconds: 1)).then((value) {
            duration = startTime;

            try {
              // FlutterRingtonePlayer().stop();

              timer.cancel();
            } catch (e) {}

            timeSetCalled = false;

            sharedPref.remove(ON_RIDE_MODEL);

            sharedPref.remove(IS_TIME2);

            servicesListData = null;

            _polyLines.clear();

            setMapPins();

            // isOnLine=false;

            setState(() {});

            Map req = {
              "id": riderId,
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
          if (timerData != null && timerData!.isActive) {
            setState(() {
              duration--;
            });
          }
        }
      },
    );
  }

  getSettings() async {
    return await getAppSetting().then((value) {
      if (value.walletSetting != null) {
        developer.log("walletSetting:::${value.walletSetting}");

        value.walletSetting!.forEach((element) {
          if (element.key == PRESENT_TOPUP_AMOUNT) {
            appStore.setWalletPresetTopUpAmount(
                element.value ?? PRESENT_TOP_UP_AMOUNT_CONST);
          }

          if (element.key == MIN_AMOUNT_TO_ADD) {
            if (element.value != null)
              appStore.setMinAmountToAdd(int.parse(element.value!));
          }

          if (element.key == MAX_AMOUNT_TO_ADD) {
            if (element.value != null)
              appStore.setMaxAmountToAdd(int.parse(element.value!));
          }
        });
      }

      if (value.rideSetting != null) {
        developer.log("rideSetting:::${value.rideSetting}");

        value.rideSetting!.forEach((element) {
          if (element.key == PRESENT_TIP_AMOUNT) {
            appStore.setWalletTipAmount(
                element.value ?? PRESENT_TOP_UP_AMOUNT_CONST);
          }

          if (element.key == MAX_TIME_FOR_DRIVER_SECOND) {
            startTime = int.parse(element.value ?? '60');
          }

          if (element.key == APPLY_ADDITIONAL_FEE) {
            appStore.setExtraCharges(element.value ?? '0');
          }
        });
      }

      if (value.currencySetting != null) {
        developer.log("currencySetting:::${value.currencySetting}");

        appStore
            .setCurrencyCode(value.currencySetting!.symbol ?? currencySymbol);

        appStore
            .setCurrencyName(value.currencySetting!.code ?? currencyNameConst);

        appStore.setCurrencyPosition(value.currencySetting!.position ?? LEFT);
      }

      if (value.settingModel != null) {
        developer.log("settingModel:::${value.settingModel}");

        appStore.settingModel = value.settingModel!;
      }

      if (value.settingModel!.helpSupportUrl != null) {
        developer.log("settingModel:::${value.settingModel!.helpSupportUrl}");

        appStore.mHelpAndSupport = value.settingModel!.helpSupportUrl!;
      }

      if (value.privacyPolicyModel!.value != null) {
        developer.log("settingModel:::${value.privacyPolicyModel!.value}");

        appStore.privacyPolicy = value.privacyPolicyModel!.value!;
      }

      if (value.termsCondition!.value != null) {
        developer.log("settingModel:::${value.termsCondition!.value}");

        appStore.termsCondition = value.termsCondition!.value!;
      }

      if (value.walletSetting != null && value.walletSetting!.isNotEmpty) {
        developer.log("walletSetting:::${value.walletSetting}");

        appStore.setWalletPresetTopUpAmount(value.walletSetting!
                .firstWhere((element) => element.key == PRESENT_TOPUP_AMOUNT)
                .value ??
            PRESENT_TOP_UP_AMOUNT_CONST);
      }

      markers.add(
        Marker(
          markerId: MarkerId("driver"),
          position: driverLocation!,
          icon: driverIcon,
          infoWindow: InfoWindow(title: ''),
        ),
      );

      setState(() {});
    }).catchError((error, stack) {
      FirebaseCrashlytics.instance.recordError(
          "setting_update_issue::" + error.toString(), stack,
          fatal: true);

      log('${error.toString()}');
    });
  }

  Future<void> setSourceAndDestinationIcons() async {
    driverIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), DriverIcon);

    if (servicesListData != null)
      servicesListData!.status != IN_PROGRESS
          ? sourceIcon = await BitmapDescriptor.fromAssetImage(
              ImageConfiguration(devicePixelRatio: 2.5), SourceIcon)
          : destinationIcon = await BitmapDescriptor.fromAssetImage(
              ImageConfiguration(devicePixelRatio: 2.5), DestinationIcon);
  }

  onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  Future<void> driverStatus({int? status}) async {
    appStore.setLoading(true);

    Map req = {
      // "status": "active",

      "is_online": status,
    };

    await updateStatus(req).then((value) {
      sharedPref.setInt(IS_ONLINE, status ?? 0);

      appStore.setLoading(false);
    }).catchError((error) {
      appStore.setLoading(false);

      log(error.toString());
    });
  }

  Future<void> getCurrentRequest() async {
    await getCurrentRideRequest().then((value) async {
      try {
        await rideService.updateStatusOfRide(
            rideID: value.onRideRequest!.id,
            req: {'on_rider_stream_api_call': 0});
      } catch (e) {
        print("Error Found:::$e");
      }

      appStore.setLoading(false);

      if (value.onRideRequest != null) {
        appStore.currentRiderRequest = value.onRideRequest;

        print("Check Estimated Price:ON-CURRENT REQ:${value.estimated_price}");

        if (value.estimated_price != null && value.estimated_price.isNotEmpty) {
          try {
            estimatedTotalPrice = num.tryParse(
                value.estimated_price[0]['total_amount'].toString());

            estimatedDistance =
                num.tryParse(value.estimated_price[0]['distance'].toString());

            distance_unit =
                value.estimated_price[0]['distance_unit'].toString();
          } catch (e) {}
        } else {
          estimatedDistance = null;

          estimatedTotalPrice = null;
        }

        servicesListData = value.onRideRequest;

        userDetail(driverId: value.onRideRequest!.riderId);

        setState(() {});

        if (servicesListData != null) {
          if (servicesListData!.status != COMPLETED) {
            setMapPins();
          }

          if (servicesListData!.status == COMPLETED &&
              servicesListData!.isDriverRated == 0) {
            if (current_screen == false) return;

            current_screen = false;

            // value.onRideRequest.otherRiderData

            launchScreen(
                context,
                ReviewScreen(
                    rideId: value.onRideRequest!.id!, currentData: value),
                pageRouteAnimation: PageRouteAnimation.Slide,
                isNewTask: true);
          } else if (value.payment != null &&
              value.payment!.paymentStatus == PENDING) {
            if (current_screen == false) return;

            current_screen = false;

            launchScreen(context, DetailScreen(),
                pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
          }
        }
      } else {
        if (value.payment != null && value.payment!.paymentStatus == PENDING) {
          if (current_screen == false) return;

          current_screen = false;

          launchScreen(context, DetailScreen(),
              pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
        }
      }

      // if (servicesListData != null) await rideService.updateStatusOfRide(rideID: servicesListData!.id, req: {'status': servicesListData!.status});

      // await changeStatus();
    }).catchError((error) {
      toast(error.toString());

      appStore.setLoading(false);

      servicesListData = null;

      setState(() {});
    });
  }

  getNewRideReq(int? riderID) async {
    print("Check Function Call Count::472");

    print("TEST3::${servicesListData}");
    //if (requestDataFetching == true) return;

    requestDataFetching = true;

    if (servicesListData != null &&
        servicesListData!.status == NEW_RIDE_REQUESTED) {
      return;
    }

    await rideDetail(rideId: riderID).then((value) async {
      appStore.setLoading(false);

      if (value.data!.status == NEW_RIDE_REQUESTED) {
        developer.log(" new ride requested 487");

        OnRideRequest ride = OnRideRequest();

        ride.startAddress = value.data!.startAddress;

        ride.startLatitude = value.data!.startLatitude;

        ride.startLongitude = value.data!.startLongitude;

        ride.endAddress = value.data!.endAddress;

        ride.endLongitude = value.data!.endLongitude;

        ride.endLatitude = value.data!.endLatitude;

        ride.riderName = value.data!.riderName;

        ride.riderContactNumber = value.data!.riderContactNumber;

        ride.riderProfileImage = value.data!.riderProfileImage;

        ride.riderEmail = value.data!.riderEmail;

        ride.id = value.data!.id;

        ride.status = value.data!.status;

        ride.otherRiderData = value.data!.otherRiderData;

        ride.shipmentType = value.data!.shipmentType;

        print("Check Estimated Price:ON-Ride-Details:${value.estimated_price}");

        if (value.estimated_price != null && value.estimated_price.isNotEmpty) {
          try {
            estimatedTotalPrice = num.tryParse(
                value.estimated_price[0]['total_amount'].toString());

            estimatedDistance =
                num.tryParse(value.estimated_price[0]['distance'].toString());

            distance_unit =
                value.estimated_price[0]['distance_unit'].toString();
          } catch (e) {}
        } else {
          estimatedDistance = null;

          estimatedTotalPrice = null;
        }

        servicesListData = ride;

        rideDetailsFetching = false;

        ride.otherRiderData;

        if (servicesListData != null)
          await rideService.updateStatusOfRide(
              rideID: servicesListData!.id,
              req: {'on_rider_stream_api_call': 0});

        sharedPref.setString(ON_RIDE_MODEL, jsonEncode(servicesListData));

        riderId = servicesListData!.id!;

        setState(() {});

        setTimeData();
      }

      requestDataFetching = false;

      setMapPins();
    }).catchError((error, stack) {
      print("TEST981");
      rideDetailsFetching = false;

      FirebaseCrashlytics.instance
          .recordError("pop_up_issue::" + error.toString(), stack, fatal: true);

      appStore.setLoading(false);

      log('error:${error.toString()}');
    });
  }

  Future<void> rideRequest({String? status}) async {
    appStore.setLoading(true);

    Map req = {
      "id": servicesListData!.id,
      "status": status,
    };

    await rideRequestUpdate(request: req, rideId: servicesListData!.id)
        .then((value) async {
      appStore.setLoading(false);

      getCurrentRequest().then((value) async {
        if (status == ARRIVED) {
          _polyLines.clear();

          setMapPins();
        }

        setState(() {});
      });
    }).catchError((error) {
      toast(error);

      appStore.setLoading(false);

      log(error.toString());
    });
  }

  // method to send trip price to rider

  Future<void> sendTripPrice({
    required String price,
    required String rideId,
  }) async {
    appStore.setLoading(true);

    Map req = {
      "ride_request_id": rideId,
      "offer_price": price,
    };

    await sendTripPriceToRider(request: req).then((value) {
      stopAudio();
      sendPrice = true;
      startCountdown();
      appStore.setLoading(false);

      toast(language.priceSentSuccessfully);

      setState(() {});

      getCurrentRequest();
    }).catchError((error) {
      stopAudio();
      sendPrice = true;
      startCountdown();
      appStore.setLoading(false);

      log(error.toString());

      toast(error.toString());
    });
  }

  Future<void> rideRequestAccept({bool deCline = false}) async {
    appStore.setLoading(true);

    Map req = {
      "id": servicesListData!.id,
      if (!deCline) "driver_id": sharedPref.getInt(USER_ID),
      "is_accept": deCline ? "0" : "1",
    };

    timeSetCalled = false;

    await rideRequestResPond(request: req).then((value) async {
      stopAudio();
      appStore.setLoading(false);

      getCurrentRequest();

      if (deCline) {
        rideService.updateStatusOfRide(rideID: servicesListData!.id, req: {
          'on_stream_api_call': 0, /* 'driver_id': null*/
        });

        // sharedPref.setInt(IS_ONLINE,0);

        // isOnLine=false;

        servicesListData = null;

        _polyLines.clear();

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

  Future<void> completeRideRequest() async {
    appStore.setLoading(true);

    Map req = {
      "id": servicesListData!.id,
      "service_id": servicesListData!.serviceId,
      "end_latitude": driverLocation!.latitude,
      "end_longitude": driverLocation!.longitude,
      "end_address": endLocationAddress,
      "distance": totalDistance,
      if (extraChargeList.isNotEmpty) "extra_charges": extraChargeList,
      if (extraChargeList.isNotEmpty) "extra_charges_amount": extraChargeAmount,
    };

    log(req);

    await completeRide(request: req).then((value) async {
      chatMessageService.exportChat(
          rideId: servicesListData!.id.toString(),
          senderId: sharedPref.getString(UID).validate(),
          receiverId: riderData!.uid.validate());

      try {
        await rideService.updateStatusOfRide(
            rideID: servicesListData!.id, req: {'on_rider_stream_api_call': 0});
      } catch (e) {
        print("Error Found:::$e");
      }

      sourceIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 2.5), SourceIcon);

      appStore.setLoading(false);

      getCurrentRequest();
    }).catchError((error) {
      chatMessageService.exportChat(
          rideId: servicesListData!.id.toString(),
          senderId: sharedPref.getString(UID).validate(),
          receiverId: riderData!.uid.validate());

      appStore.setLoading(false);

      log(error.toString());
    });
  }

  Future<void> setPolyLines() async {
    // if (servicesListData != null) _polyLines.clear();

    try {
      var result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: GOOGLE_MAP_API_KEY,

        request: PolylineRequest(
            origin: PointLatLng(
                driverLocation!.latitude, driverLocation!.longitude),
            destination: servicesListData!.status != IN_PROGRESS
                ? PointLatLng(
                    double.parse(servicesListData!.startLatitude.validate()),
                    double.parse(servicesListData!.startLongitude.validate()))
                : PointLatLng(
                    double.parse(servicesListData!.endLatitude.validate()),
                    double.parse(servicesListData!.endLongitude.validate())),
            mode: TravelMode.driving),

        // PointLatLng(driverLocation!.latitude, driverLocation!.longitude),

        // servicesListData!.status != IN_PROGRESS

        //     ? PointLatLng(double.parse(servicesListData!.startLatitude.validate()), double.parse(servicesListData!.startLongitude.validate()))

        //     : PointLatLng(double.parse(servicesListData!.endLatitude.validate()), double.parse(servicesListData!.endLongitude.validate())),
      );

      if (result.points.isNotEmpty) {
        polylineCoordinates.clear();

        result.points.forEach((element) {
          polylineCoordinates.add(LatLng(element.latitude, element.longitude));
        });

        _polyLines.clear();

        _polyLines.add(
          Polyline(
            visible: true,
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            polylineId: PolylineId('poly'),
            color: polyLineColor,
            points: polylineCoordinates,
          ),
        );

        setState(() {});
      }
    } catch (e) {}
  }

  Future<void> setMapPins() async {
    try {
      markers.clear();

      ///source pin

      MarkerId id = MarkerId("driver");

      markers.remove(id);

      markers.add(
        Marker(
          markerId: id,
          position: driverLocation!,
          icon: driverIcon,
          infoWindow: InfoWindow(title: ''),
        ),
      );

      if (servicesListData != null)
        servicesListData!.status != IN_PROGRESS
            ? markers.add(
                Marker(
                  markerId: MarkerId('sourceLocation'),
                  position: LatLng(
                      double.parse(servicesListData!.startLatitude!),
                      double.parse(servicesListData!.startLongitude!)),
                  icon: sourceIcon,
                  infoWindow: InfoWindow(title: servicesListData!.startAddress),
                ),
              )
            : markers.add(
                Marker(
                  markerId: MarkerId('destinationLocation'),
                  position: LatLng(double.parse(servicesListData!.endLatitude!),
                      double.parse(servicesListData!.endLongitude!)),
                  icon: destinationIcon,
                  infoWindow: InfoWindow(title: servicesListData!.endAddress),
                ),
              );

      setState(() {});
    } catch (e) {
      setState(() {});
    }

    setPolyLines();
  }

  /// Get Current Location

  Future<void> startLocationTracking() async {
    _polyLines.clear();

    polylineCoordinates.clear();

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((value) async {
      log("=====Location:::${value.latitude}:::${value.longitude}");
      await Geolocator.isLocationServiceEnabled().then((value) async {
        log("======Location:::${value}");
        if (locationEnable) {
          final LocationSettings locationSettings = LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 100,
              timeLimit: Duration(seconds: 30));

          positionStream =
              Geolocator.getPositionStream(locationSettings: locationSettings)
                  .listen((event) async {
            DateTime? d = DateTime.tryParse(
                sharedPref.getString("UPDATE_CALL").toString());

            if (d != null && DateTime.now().difference(d).inSeconds > 30) {
              if (appStore.isLoggedIn) {
                driverLocation = LatLng(event.latitude, event.longitude);

                Map req = {
                  "latitude": driverLocation!.latitude.toString(),
                  "longitude": driverLocation!.longitude.toString(),
                };

                sharedPref.setDouble(LATITUDE, driverLocation!.latitude);

                sharedPref.setDouble(LONGITUDE, driverLocation!.longitude);

                await updateStatus(req).then((value) {
                  setState(() {});
                }).catchError((error) {
                  log(error);
                });

                stutasCount = 0;

                setMapPins();

                if (servicesListData != null) setPolyLines();
              }

              sharedPref.setString("UPDATE_CALL", DateTime.now().toString());
            } else if (d == null) {
              sharedPref.setString("UPDATE_CALL", DateTime.now().toString());
            }
          }, onError: (error) {
            positionStream.cancel();
          });
        }
      });
    }).catchError((error) {
      Future.delayed(
        Duration(seconds: 1),
        () {
          launchScreen(navigatorKey.currentState!.overlay!.context,
              LocationPermissionScreen());

          // Navigator.push(context, MaterialPageRoute(builder: (_) => LocationPermissionScreen()));
        },
      );
    });
  }

  Future<void> userDetail({int? driverId}) async {
    await getUserDetail(userId: driverId).then((value) {
      appStore.setLoading(false);

      riderData = value.data!;

      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
    });
  }

  /// WalletCheck

  Future<void> walletCheckApi() async {
    await walletDetailApi().then((value) async {
      if (value.totalAmount! >= value.minAmountToGetRide!) {
        //
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return emptyWalletAlertDialog();
          },
        );
      }
    }).catchError((e) {
      log("Error $e");
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    // positionStream.cancel();

    // FlutterRingtonePlayer().stop();

    countdownTimer?.cancel(); // Clean up timer

    if (timerData != null) {
      timerData!.cancel();
    }

    positionStream.cancel();

    // if (timerData == null) {

    //   sharedPref.getString(IS_TIME2);

    // }

    super.dispose();
  }

  void moveMap(BuildContext context, Prediction prediction) async {
    final GoogleMapController controller = await _controller.future;

    controller.moveCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(double.parse(prediction.lat ?? ""),
            double.parse(prediction.lng ?? "")),
        14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (v) async {
        // Map req = {

        //   "is_available": 0,

        // };

        // updateStatus(req).then((value) {

        //   //

        // });

        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
              statusBarColor: Colors.black38),
        ),
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: true,
        key: scaffoldKey,
        drawer: DrawerComponent(onCall: () async {
          await driverStatus(status: 0);
        }),
        body: Stack(
          children: [
            if (sharedPref.getDouble(LATITUDE) != null &&
                sharedPref.getDouble(LONGITUDE) != null)
              GoogleMap(
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                myLocationEnabled: false,
                compassEnabled: false,
                padding: EdgeInsets.only(top: context.statusBarHeight + 4 + 24),
                onMapCreated: onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: driverLocation ??
                      LatLng(sharedPref.getDouble(LATITUDE)!,
                          sharedPref.getDouble(LONGITUDE)!),
                  zoom: 17.0,
                ),
                markers: markers,
                mapType: MapType.normal,
                polylines: _polyLines,
              ),

            // const Center(

            //   child: Padding(

            //     padding: EdgeInsets.only(bottom: 25.0),

            //     child: Icon(

            //       size: 50,

            //       Icons.location_pin,

            //     ),

            //   ),

            // ),

            onlineOfflineSwitch(),

            StreamBuilder<QuerySnapshot>(
              stream: rideService.fetchRide(userId: sharedPref.getInt(USER_ID)),
              builder: (c, snapshot) {
                if (snapshot.hasData) {
                  List<FRideBookingModel> data = snapshot.data!.docs
                      .map((e) => FRideBookingModel.fromJson(
                          e.data() as Map<String, dynamic>))
                      .toList();

                  if (data.length == 2) {
                    //here old ride of this driver remove if completed and payment is done code set

                    rideService.removeOldRideEntry(
                      userId: sharedPref.getInt(USER_ID),
                    );
                  }

                  if (data.length != 0) {
                    rideCancelDetected = false;
                    if (data[0].onStreamApiCall == 0) {
                      rideService.updateStatusOfRide(
                          rideID: data[0].rideId,
                          req: {'on_stream_api_call': 1});
                      if (data[0].status == NEW_RIDE_REQUESTED) {
                        print("TEST1");
                        getNewRideReq(data[0].rideId);
                      } else {
                        print("TEST2");
                        getCurrentRequest();
                      }
                    }
                    if (servicesListData == null &&
                        data[0].status == NEW_RIDE_REQUESTED &&
                        data[0].onStreamApiCall == 1) {
                      reqCheckCounter++;
                      if (reqCheckCounter < 1) {
                        rideService.updateStatusOfRide(
                            rideID: data[0].rideId,
                            req: {'on_stream_api_call': 0});
                      }
                    }
                    if ((servicesListData != null &&
                            servicesListData!.status != NEW_RIDE_REQUESTED &&
                            data[0].status == NEW_RIDE_REQUESTED &&
                            data[0].onStreamApiCall == 1) ||
                        (servicesListData == null &&
                            data[0].status == NEW_RIDE_REQUESTED &&
                            data[0].onStreamApiCall == 1)) {
                      if (rideDetailsFetching != true) {
                        rideDetailsFetching = true;
                        rideService.updateStatusOfRide(
                            rideID: data[0].rideId,
                            req: {'on_stream_api_call': 0});
                      }
                    }

                    return servicesListData != null
                        ? servicesListData!.status != null &&
                                servicesListData!.status == NEW_RIDE_REQUESTED
                            ? Builder(builder: (context) {
                                // if (sendPrice == true && countdown == 0)
                                //   return SizedBox();
                                double progress = countdown / 60;

                                return SizedBox.expand(
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      servicesListData != null && duration >= 0
                                          ? Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                        2 * defaultRadius),
                                                    topRight: Radius.circular(
                                                        2 * defaultRadius)),
                                              ),
                                              child: SingleChildScrollView(
                                                // controller: scrollController,

                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            top: 16),
                                                        height: 6,
                                                        width: 60,
                                                        decoration: BoxDecoration(
                                                            color: primaryColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        defaultRadius)),
                                                        alignment:
                                                            Alignment.center,
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 16),
                                                      child: Text(
                                                          language.requests,
                                                          style:
                                                              primaryTextStyle(
                                                                  size: 18)),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(16),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            defaultRadius),
                                                                child: commonCachedNetworkImage(
                                                                    servicesListData!
                                                                        .riderProfileImage
                                                                        .validate(),
                                                                    height: 35,
                                                                    width: 35,
                                                                    fit: BoxFit
                                                                        .cover),
                                                              ),
                                                              SizedBox(
                                                                  width: 12),
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                        '${servicesListData!.riderName.capitalizeFirstLetter()}',
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        style: boldTextStyle(
                                                                            size:
                                                                                14)),
                                                                    SizedBox(
                                                                        height:
                                                                            4),
                                                                    Text(
                                                                        '${servicesListData!.riderEmail.validate()}',
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        style:
                                                                            secondaryTextStyle()),
                                                                  ],
                                                                ),
                                                              ),
                                                              if (duration > 0)
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                      color:
                                                                          primaryColor,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              defaultRadius)),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              6),
                                                                  child: Text(
                                                                      "$duration"
                                                                          .padLeft(
                                                                              2,
                                                                              "0"),
                                                                      style: boldTextStyle(
                                                                          color:
                                                                              Colors.white)),
                                                                )
                                                            ],
                                                          ),
                                                          if (estimatedTotalPrice !=
                                                                  null &&
                                                              estimatedDistance !=
                                                                  null)
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          8),
                                                              decoration: BoxDecoration(
                                                                  color: !appStore
                                                                          .isDarkMode
                                                                      ? scaffoldColorLight
                                                                      : scaffoldColorDark,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          radiusCircular(
                                                                              8)),
                                                                  border: Border
                                                                      .all(
                                                                          width:
                                                                              1,
                                                                          color:
                                                                              dividerColor)),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  // Expanded(
                                                                  //   child: Row(
                                                                  //     children: [
                                                                  //       // Text(
                                                                  //       //     '${language.estAmount}:',
                                                                  //       //     style:
                                                                  //       //         secondaryTextStyle(size: 16)),
                                                                  //       SizedBox(
                                                                  //           width:
                                                                  //               4),
                                                                  //       Text(
                                                                  //           '${printAmount(estimatedTotalPrice.toStringAsFixed(digitAfterDecimal))}',
                                                                  //           style:
                                                                  //               boldTextStyle(size: 14)),
                                                                  //     ],
                                                                  //   ),
                                                                  // ),

                                                                  // Container(decoration:BoxDecoration(color: dividerColor),width: 1,height: 15,),

                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Text(
                                                                          '${language.distance}:',
                                                                          style:
                                                                              secondaryTextStyle(size: 16)),
                                                                      SizedBox(
                                                                          width:
                                                                              4),
                                                                      Text(
                                                                          '${estimatedDistance} ${distance_unit}',
                                                                          maxLines:
                                                                              1,
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          style:
                                                                              boldTextStyle(size: 14)),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                              width: context
                                                                  .width(),
                                                            ),
                                                          addressDisplayWidget(
                                                              endLatLong: LatLng(
                                                                  servicesListData!
                                                                      .endLatitude
                                                                      .toDouble(),
                                                                  servicesListData!
                                                                      .endLongitude
                                                                      .toDouble()),
                                                              endAddress:
                                                                  servicesListData!
                                                                      .endAddress,
                                                              startLatLong: LatLng(
                                                                  servicesListData!
                                                                      .startLatitude
                                                                      .toDouble(),
                                                                  servicesListData!
                                                                      .startLongitude
                                                                      .toDouble()),
                                                              startAddress:
                                                                  servicesListData!
                                                                      .startAddress),
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional
                                                                    .centerStart,
                                                            child: Text(
                                                              '${language.shipmentType}: ${servicesListData!.shipmentType}',
                                                              style:
                                                                  primaryTextStyle(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                            ),
                                                          ),
                                                          if (servicesListData !=
                                                                  null &&
                                                              servicesListData!
                                                                      .otherRiderData !=
                                                                  null)
                                                            Divider(
                                                              color: Colors.grey
                                                                  .shade300,
                                                              thickness: 0.7,
                                                              height: 8,
                                                            ),
                                                          _bookingForView(),
                                                          SizedBox(height: 8),
                                                          (countdown > 0)
                                                              ? Stack(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  children: [
                                                                    Container(
                                                                      width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width,
                                                                      height:
                                                                          48,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.grey.withOpacity(0.5)),
                                                                        gradient:
                                                                            LinearGradient(
                                                                          colors: [
                                                                            const Color(0xFF417CFF),
                                                                            Colors.white
                                                                          ],
                                                                          stops: [
                                                                            progress,
                                                                            progress +
                                                                                0.01
                                                                          ],
                                                                          begin:
                                                                              Alignment.centerLeft,
                                                                          end: Alignment
                                                                              .centerRight,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Center(
                                                                      child:
                                                                          Text(
                                                                        'تم ارسال العرض (${countdown}s)',
                                                                        style:
                                                                            boldTextStyle(
                                                                          size:
                                                                              16,
                                                                          color:
                                                                              Colors.black, // Ensure text contrast
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              : AppTextField(
                                                                  controller:
                                                                      priceController,
                                                                  textFieldType:
                                                                      TextFieldType
                                                                          .PHONE,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    hintText:
                                                                        language
                                                                            .enterPrice,
                                                                    hintStyle:
                                                                        primaryTextStyle(),
                                                                    contentPadding:
                                                                        EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                16),
                                                                    border:
                                                                        OutlineInputBorder(),
                                                                  ),
                                                                  inputFormatters: [
                                                                    FilteringTextInputFormatter
                                                                        .digitsOnly
                                                                  ],
                                                                ),
                                                          SizedBox(height: 8),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    inkWellWidget(
                                                                  onTap: () {
                                                                    showConfirmDialogCustom(
                                                                        dialogType:
                                                                            DialogType
                                                                                .DELETE,
                                                                        primaryColor:
                                                                            primaryColor,
                                                                        title: language
                                                                            .areYouSureYouWantToCancelThisRequest,
                                                                        positiveText:
                                                                            language
                                                                                .yes,
                                                                        negativeText:
                                                                            language
                                                                                .no,
                                                                        context,
                                                                        onAccept:
                                                                            (v) {
                                                                      try {
                                                                        // FlutterRingtonePlayer()
                                                                        // .stop();

                                                                        timerData!
                                                                            .cancel();
                                                                      } catch (e) {}

                                                                      sharedPref
                                                                          .remove(
                                                                              IS_TIME2);

                                                                      sharedPref
                                                                          .remove(
                                                                              ON_RIDE_MODEL);

                                                                      rideRequestAccept(
                                                                          deCline:
                                                                              true);
                                                                    }).then(
                                                                      (value) {
                                                                        _polyLines
                                                                            .clear();

                                                                        setState;
                                                                      },
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            8),
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                defaultRadius),
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.red)),
                                                                    child: Text(
                                                                        language
                                                                            .decline,
                                                                        style: boldTextStyle(
                                                                            color: Colors
                                                                                .red),
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                ),
                                                              ),
                                                              if (!sendPrice)
                                                                SizedBox(
                                                                    width: 16),
                                                              if (!sendPrice)
                                                                Expanded(
                                                                  child:
                                                                      AppButtonWidget(
                                                                    padding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            12,
                                                                        horizontal:
                                                                            8),
                                                                    text: language
                                                                        .accept,
                                                                    shapeBorder:
                                                                        RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(defaultRadius)),
                                                                    color:
                                                                        primaryColor,
                                                                    textStyle: boldTextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                    onTap: () {
                                                                      if (sendPrice ==
                                                                          true)
                                                                        return;
                                                                      showConfirmDialogCustom(
                                                                          primaryColor:
                                                                              primaryColor,
                                                                          dialogType: DialogType
                                                                              .ACCEPT,
                                                                          positiveText: language
                                                                              .yes,
                                                                          negativeText: language
                                                                              .no,
                                                                          title: language
                                                                              .areYouSureYouWantToAcceptThisRequest,
                                                                          context,
                                                                          onAccept:
                                                                              (v) {
                                                                        if (double.tryParse(priceController.text) ==
                                                                            null) {
                                                                          toast(
                                                                              language.pleaseEnterValidPrice);

                                                                          return;
                                                                        } else if (int.parse(priceController.text) <
                                                                            estimatedTotalPrice) {
                                                                          toast(
                                                                              "${language.pleaseEnterPriceGreaterThan} ${printAmount(estimatedTotalPrice.toStringAsFixed(2))}");

                                                                          return;
                                                                        }

                                                                        try {
                                                                          // FlutterRingtonePlayer()
                                                                          //     .stop();

                                                                          timerData!
                                                                              .cancel();
                                                                        } catch (e) {}

                                                                        // sharedPref

                                                                        //     .remove(

                                                                        //         IS_TIME2);

                                                                        // sharedPref

                                                                        //     .remove(

                                                                        //         ON_RIDE_MODEL);

                                                                        sendTripPrice(
                                                                          price:
                                                                              priceController.text,
                                                                          rideId: servicesListData!
                                                                              .id
                                                                              .toString(),
                                                                        );
                                                                      });
                                                                    },
                                                                  ),
                                                                ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : SizedBox(),
                                      Observer(builder: (context) {
                                        return appStore.isLoading
                                            ? loaderWidget()
                                            : SizedBox();
                                      })
                                    ],
                                  ),
                                );
                              })
                            : Positioned(
                                bottom: 0,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                        topLeft:
                                            Radius.circular(2 * defaultRadius),
                                        topRight:
                                            Radius.circular(2 * defaultRadius)),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                defaultRadius),
                                            child: commonCachedNetworkImage(
                                                servicesListData!
                                                    .riderProfileImage,
                                                height: 48,
                                                width: 48,
                                                fit: BoxFit.cover),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    '${servicesListData!.riderName.capitalizeFirstLetter()}',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: boldTextStyle(
                                                        size: 18)),
                                                SizedBox(height: 4),
                                                Text(
                                                    '${servicesListData!.riderEmail.validate()}',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        secondaryTextStyle()),
                                              ],
                                            ),
                                          ),
                                          inkWellWidget(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) {
                                                  return AlertDialog(
                                                    contentPadding:
                                                        EdgeInsets.all(0),
                                                    content: AlertScreen(
                                                        rideId:
                                                            servicesListData!
                                                                .id,
                                                        regionId:
                                                            servicesListData!
                                                                .regionId),
                                                  );
                                                },
                                              );
                                            },
                                            child: chatCallWidget(Icons.sos),
                                          ),
                                          SizedBox(width: 8),
                                          inkWellWidget(
                                            onTap: () {
                                              launchUrl(
                                                  Uri.parse(
                                                      'tel:${servicesListData!.riderContactNumber}'),
                                                  mode: LaunchMode
                                                      .externalApplication);
                                            },
                                            child: chatCallWidget(Icons.call),
                                          ),
                                          SizedBox(width: 8),
                                          inkWellWidget(
                                            onTap: () {
                                              if (riderData == null ||
                                                  (riderData != null &&
                                                      riderData!.uid == null)) {
                                                init();

                                                return;
                                              }

                                              if (riderData != null) {
                                                launchScreen(
                                                    context,
                                                    ChatScreen(
                                                      userData: riderData,
                                                      ride_id: riderId,
                                                    ));
                                              }
                                            },
                                            child: chatCallWidget(
                                                Icons.chat_bubble_outline,
                                                data: riderData),
                                          ),
                                        ],
                                      ),
                                      if (estimatedTotalPrice != null &&
                                          estimatedDistance != null)
                                        Container(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 8),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              // Expanded(
                                              //   child: Row(
                                              //     children: [
                                              //       Text(
                                              //           '${language.estAmount}:',
                                              //           style:
                                              //               secondaryTextStyle(
                                              //                   size: 16)),
                                              //       SizedBox(width: 4),
                                              //       Text(
                                              //           '${printAmount(estimatedTotalPrice.toStringAsFixed(2))}',
                                              //           style: boldTextStyle(
                                              //               size: 14)),
                                              //     ],
                                              //   ),
                                              // ),

                                              // Container(decoration:BoxDecoration(color: dividerColor),width: 1,height: 15,),

                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Text('${language.distance}:',
                                                      style: secondaryTextStyle(
                                                          size: 16)),
                                                  SizedBox(width: 4),
                                                  Text(
                                                      '${estimatedDistance} ${distance_unit}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: boldTextStyle(
                                                          size: 14)),
                                                ],
                                              ),
                                            ],
                                          ),
                                          width: context.width(),
                                        ),
                                      Divider(
                                        color: Colors.grey.shade300,
                                        thickness: 0.7,
                                        height: 4,
                                      ),
                                      SizedBox(height: 8),
                                      addressDisplayWidget(
                                          endLatLong: LatLng(
                                              servicesListData!.endLatitude
                                                  .toDouble(),
                                              servicesListData!.endLongitude
                                                  .toDouble()),
                                          endAddress:
                                              servicesListData!.endAddress,
                                          startLatLong: LatLng(
                                              servicesListData!.startLatitude
                                                  .toDouble(),
                                              servicesListData!.startLongitude
                                                  .toDouble()),
                                          startAddress:
                                              servicesListData!.startAddress),
                                      SizedBox(height: 8),
                                      servicesListData!.status !=
                                              NEW_RIDE_REQUESTED
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: servicesListData!
                                                              .status ==
                                                          IN_PROGRESS
                                                      ? 0
                                                      : 8),
                                              child: _bookingForView(),
                                            )
                                          : SizedBox(),
                                      if (servicesListData!.status ==
                                              IN_PROGRESS &&
                                          servicesListData != null &&
                                          servicesListData!.otherRiderData !=
                                              null)

                                        // Divider(color: Colors.grey.shade300,thickness: 0.7,height: 8,),

                                        SizedBox(height: 8),
                                      if (servicesListData!.status ==
                                          IN_PROGRESS)
                                        if (appStore.extraChargeValue != null)
                                          Observer(builder: (context) {
                                            return Visibility(
                                              visible: int.parse(appStore
                                                      .extraChargeValue!) !=
                                                  0,
                                              child: inkWellWidget(
                                                onTap: () async {
                                                  List<ExtraChargeRequestModel>?
                                                      extraChargeListData =
                                                      await showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    defaultRadius),
                                                            topRight:
                                                                Radius.circular(
                                                                    defaultRadius))),
                                                    context: context,
                                                    builder: (_) {
                                                      return Padding(
                                                        padding: EdgeInsets.only(
                                                            bottom:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .viewInsets
                                                                    .bottom),
                                                        child: ExtraChargesWidget(
                                                            data:
                                                                extraChargeList),
                                                      );
                                                    },
                                                  );

                                                  if (extraChargeListData !=
                                                      null) {
                                                    log("extraChargeListData   $extraChargeListData");

                                                    extraChargeAmount = 0;

                                                    extraChargeList.clear();

                                                    extraChargeListData
                                                        .forEach((element) {
                                                      extraChargeAmount =
                                                          extraChargeAmount +
                                                              element.value!;

                                                      extraChargeList =
                                                          extraChargeListData;
                                                    });
                                                  }
                                                },
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 8),

                                                      // padding: EdgeInsets.symmetric(vertical: 8),

                                                      child: Container(
                                                        // decoration: BoxDecoration(

                                                        //   borderRadius: BorderRadius.circular(defaultRadius),

                                                        //   color: Colors.white,

                                                        //   border: Border.all(color: primaryColor.withOpacity(0.3),width: 1,strokeAlign: BorderSide.strokeAlignInside)

                                                        // ),

                                                        // padding: EdgeInsets.all(4),

                                                        // color: Colors.red,

                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            // Row(

                                                            //   mainAxisSize: MainAxisSize.min,

                                                            //   mainAxisAlignment: MainAxisAlignment.start,

                                                            //   children: [

                                                            //     Icon(Icons.add, size: 22),

                                                            //     SizedBox(width: 4),

                                                            //     Text(language.extraFees, style: boldTextStyle()),

                                                            //   ],

                                                            // ),

                                                            if (extraChargeAmount !=
                                                                0)
                                                              Text(
                                                                  '${language.extraCharges} ${printAmount(extraChargeAmount.toString())}',
                                                                  style: secondaryTextStyle(
                                                                      color: Colors
                                                                          .green)),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                      buttonWidget()
                                    ],
                                  ),
                                ),
                              )
                        : SizedBox();
                  } else {
                    if (data.isEmpty) {
                      try {
                        // FlutterRingtonePlayer().stop();

                        if (timerData != null) {
                          timerData!.cancel();
                        }
                      } catch (e) {}
                    }

                    if (servicesListData != null) {
                      checkRideCancel();
                    }

                    if (riderId != 0) {
                      riderId = 0;

                      try {
                        sharedPref.remove(IS_TIME2);

                        timerData!.cancel();
                      } catch (e) {}
                    }

                    servicesListData = null;

                    _polyLines.clear();

                    return SizedBox();
                  }
                } else {
                  return snapWidgetHelper(
                    snapshot,
                    loadingWidget: loaderWidget(),
                  );
                }
              },
            ),

            Positioned(
              top: context.statusBarHeight + 8,
              right: 14,
              left: 14,
              child: topWidget(),
            ),

            // myLocationWidget(),

            Visibility(
              visible: appStore.isLoading,
              child: loaderWidget(),
            ),
          ],
        ),
      ),
    );
  }

  int countdown = 0;
  Timer? countdownTimer;

  // Method to start the countdown
  void startCountdown() {
    developer.log("startCountdown");
    developer.log("countdown $countdown");
    setState(() {
      countdown = 60; // Start from 60 seconds
    });

    countdownTimer?.cancel(); // Cancel any existing timer

    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown == 0) {
        timer.cancel();
        cancelRideTimeOut();
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }

  void cancelTimer() {
    countdownTimer?.cancel();
    countdown = 0;
  }

  Future<void> getUserLocation() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        driverLocation!.latitude, driverLocation!.longitude);

    Placemark place = placemarks[0];

    endLocationAddress =
        '${place.street},${place.subLocality},${place.thoroughfare},${place.locality}';
  }

  Widget topWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            inkWellWidget(
              onTap: () => scaffoldKey.currentState!.openDrawer(),
              child: Container(
                padding: EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 4,
                      width: 24,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(defaultRadius),
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      height: 4,
                      width: 16,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(defaultRadius),
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      height: 4,
                      width: 24,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(defaultRadius),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              'Quick Cargoo , ${sharedPref.getString(FIRST_NAME).validate().capitalizeFirstLetter()}!',
              style: boldTextStyle(size: 20),
            ),
            inkWellWidget(
              onTap: () {
                launchScreen(
                  context,
                  EditProfileScreen(isGoogle: false),
                  pageRouteAnimation: PageRouteAnimation.Slide,
                );
              },
              child: ClipOval(
                child: commonCachedNetworkImage(
                  appStore.userProfile.validate(),
                  height: 55,
                  width: 55,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            // HNA TA3 EARNING

            // inkWellWidget(

            //   onTap: () => launchScreen(getContext, EarningScreen()),

            //   child: Container(

            //     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),

            //     decoration: BoxDecoration(

            //       color: Colors.white,

            //       border: Border.all(color: primaryColor),

            //       borderRadius: BorderRadius.circular(50),

            //       boxShadow: defaultBoxShadow(),

            //     ),

            //     child: Text(

            //       printAmount(totalEarnings.toString()),

            //       textAlign: TextAlign.center,

            //       style: boldTextStyle(size: 16, color: primaryColor),

            //     ),

            //   ),

            // ),

            Spacer(),

            inkWellWidget(
              onTap: () => launchScreen(getContext, NotificationScreen()),
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: primaryColor),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Ionicons.notifications_outline,
                  color: primaryColor,
                  size: 26,
                ),
              ),
            ),

            SizedBox(width: 8),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            inkWellWidget(
              onTap: () {
                moveMap(
                  context,
                  Prediction(
                    lat: driverLocation!.latitude.toString(),
                    lng: driverLocation!.longitude.toString(),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: primaryColor),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.my_location_sharp,
                  color: primaryColor,
                  size: 26,
                ),
              ),
            ),
            SizedBox(width: 8),
          ],
        ),
      ],
    );
  }

  Widget myLocationWidget() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 30,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                moveMap(
                  context,
                  Prediction(
                    lat: driverLocation!.latitude.toString(),
                    lng: driverLocation!.longitude.toString(),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 600),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: primaryColor),
                ),
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.my_location_sharp,
                  color: primaryColor,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget onlineOfflineSwitch() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isOnLine ? language.online : language.offLine,
              style: boldTextStyle(
                color: isOnLine ? Colors.green : Colors.red,
                size: 18,
                weight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                await showConfirmDialogCustom(
                    dialogType: DialogType.CONFIRMATION,
                    primaryColor: primaryColor,
                    title: isOnLine
                        ? language.areYouCertainOffline
                        : language.areYouCertainOnline,
                    context, onAccept: (v) async {
                  driverStatus(status: isOnLine ? 0 : 1);
                  if (isOnLine) {
                    NotificationWithSoundService.service.invoke('stopService');
                  } else {
                    await NotificationWithSoundService.initializeService();
                  }
                  isOnLine = !isOnLine;

                  setState(() {});
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 600),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: isOnLine ? Colors.green : Colors.red,
                  ),
                ),
                padding: EdgeInsets.all(8),
                child: Icon(
                  isOnLine
                      ? Icons.power_settings_new_outlined
                      : Icons.power_settings_new_sharp,
                  color: isOnLine ? Colors.green : Colors.red,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buttonWidget() {
    if (servicesListData!.status == ACCEPTED) {
      cancelTimer();
    }
    return Row(
      children: [
        if (servicesListData!.status != IN_PROGRESS)
          Expanded(
            flex: 0,
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: AppButtonWidget(

                  // width: MediaQuery.of(context).size.width,

                  text: language.cancel,
                  textColor: primaryColor,
                  color: Colors.white,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultRadius),
                      side: BorderSide(color: primaryColor)),

                  // color: Colors.grey,

                  // textStyle: boldTextStyle(color: Colors.white),

                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: false,
                        builder: (context) {
                          return CancelOrderDialog(onCancel: (reason) async {
                            Navigator.pop(context);

                            appStore.setLoading(true);

                            await cancelRequest(reason);

                            appStore.setLoading(false);
                          });
                        });
                  }),
            ),
          ),
        if (servicesListData!.status == IN_PROGRESS)
          Expanded(
            flex: 0,
            child: Padding(
              padding: EdgeInsets.all(4),
              child: AppButtonWidget(
                  child: Row(
                    children: [
                      Icon(
                        Icons.add,
                        size: 18,
                      ),
                      // SizedBox(width: 0),
                      // Text(
                      //   language.extraFees,
                      //   style: boldTextStyle(
                      //     color: primaryColor,
                      //   ),
                      // )
                    ],
                  ),

                  // width: MediaQuery.of(context).size.width,

                  text: language.extraFees,
                  textColor: primaryColor,
                  color: Colors.white,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultRadius),
                      side: BorderSide(color: primaryColor)),

                  // color: Colors.grey,

                  // textStyle: boldTextStyle(color: Colors.white),

                  onTap: () async {
                    List<ExtraChargeRequestModel>? extraChargeListData =
                        await showModalBottomSheet(
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(defaultRadius),
                              topRight: Radius.circular(defaultRadius))),
                      context: context,
                      builder: (_) {
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: ExtraChargesWidget(data: extraChargeList),
                        );
                      },
                    );

                    if (extraChargeListData != null) {
                      log("extraChargeListData   $extraChargeListData");

                      extraChargeAmount = 0;

                      extraChargeList.clear();

                      extraChargeListData.forEach((element) {
                        extraChargeAmount = extraChargeAmount + element.value!;

                        extraChargeList = extraChargeListData;
                      });
                    }
                  }),
            ),
          ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: AppButtonWidget(
              // width: MediaQuery.of(context).size.width,

              text: buttonText(status: servicesListData!.status),

              color: primaryColor,

              textStyle: boldTextStyle(color: Colors.white),

              onTap: () async {
                if (await checkPermission()) {
                  if (servicesListData!.status == ACCEPTED) {
                    showConfirmDialogCustom(
                        primaryColor: primaryColor,
                        positiveText: language.yes,
                        negativeText: language.no,
                        dialogType: DialogType.CONFIRMATION,
                        title: language.areYouSureYouWantToArriving,
                        context, onAccept: (v) {
                      rideRequest(status: ARRIVING);
                    });
                  } else if (servicesListData!.status == ARRIVING) {
                    showConfirmDialogCustom(
                        primaryColor: primaryColor,
                        positiveText: language.yes,
                        negativeText: language.no,
                        dialogType: DialogType.CONFIRMATION,
                        title: language.areYouSureYouWantToArrived,
                        context, onAccept: (v) {
                      rideRequest(status: ARRIVED);
                    });
                  } else if (servicesListData!.status == ARRIVED) {
                    otpController.clear();

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) {
                        return AlertDialog(
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(language.enterOtp,
                                      style: boldTextStyle(),
                                      textAlign: TextAlign.center),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: inkWellWidget(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                            color: primaryColor,
                                            shape: BoxShape.circle),
                                        child: Icon(Icons.close,
                                            size: 20, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(language.startRideAskOTP,
                                  style: secondaryTextStyle(size: 12),
                                  textAlign: TextAlign.center),
                              SizedBox(height: 16),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Center(
                                  child: Pinput(
                                    keyboardType: TextInputType.number,

                                    readOnly: false,

                                    autofocus: true,

                                    length: 4,

                                    onTap: () {},

                                    // onClipboardFound: (value) {

                                    // otpController.text=value;

                                    // },

                                    onLongPress: () {},

                                    cursor: Text(
                                      "|",
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w500),
                                    ),

                                    focusedPinTheme: PinTheme(
                                      width: 40,
                                      height: 44,
                                      textStyle: TextStyle(
                                        fontSize: 18,
                                      ),
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                          border:
                                              Border.all(color: primaryColor)),
                                    ),

                                    toolbarEnabled: true,

                                    useNativeKeyboard: true,

                                    defaultPinTheme: PinTheme(
                                      width: 40,
                                      height: 44,
                                      textStyle: TextStyle(
                                        fontSize: 18,
                                      ),
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                          border:
                                              Border.all(color: dividerColor)),
                                    ),

                                    isCursorAnimationEnabled: true,

                                    showCursor: true,

                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],

                                    closeKeyboardWhenCompleted: false,

                                    enableSuggestions: false,

                                    autofillHints: [],

                                    controller: otpController,

                                    onCompleted: (val) {
                                      otpCheck = val;
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              AppButtonWidget(
                                width: MediaQuery.of(context).size.width,
                                text: language.confirm,
                                onTap: () {
                                  if (otpCheck == null ||
                                      otpCheck != servicesListData!.otp) {
                                    return toast(language.pleaseEnterValidOtp);
                                  } else {
                                    Navigator.pop(context);

                                    rideRequest(status: IN_PROGRESS);
                                  }
                                },
                              )
                            ],
                          ),
                        );
                      },
                    );
                  } else if (servicesListData!.status == IN_PROGRESS) {
                    showConfirmDialogCustom(
                        primaryColor: primaryColor,
                        dialogType: DialogType.ACCEPT,
                        title: language.finishMsg,
                        context,
                        positiveText: language.yes,
                        negativeText: language.no, onAccept: (v) {
                      appStore.setLoading(true);

                      getUserLocation().then((value2) async {
                        totalDistance = calculateDistance(
                            double.parse(
                                servicesListData!.startLatitude.validate()),
                            double.parse(
                                servicesListData!.startLongitude.validate()),
                            driverLocation!.latitude,
                            driverLocation!.longitude);

                        await completeRideRequest();
                      });
                    });
                  }
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget addressDisplayWidget(
      {String? startAddress,
      String? endAddress,
      required LatLng startLatLong,
      required LatLng endLatLong}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.near_me, color: Colors.green, size: 18),
            SizedBox(width: 8),
            Expanded(
                child: Text(startAddress ?? ''.validate(),
                    style: primaryTextStyle(size: 14), maxLines: 2)),
            mapRedirectionWidget(
                latLong: LatLng(startLatLong.latitude.toDouble(),
                    startLatLong.longitude.toDouble()))
          ],
        ),
        Row(
          children: [
            SizedBox(width: 8),
            SizedBox(
              height: 24,
              child: DottedLine(
                direction: Axis.vertical,
                lineLength: double.infinity,
                lineThickness: 1,
                dashLength: 2,
                dashColor: primaryColor,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Icon(Icons.location_on, color: Colors.red, size: 18),
            SizedBox(width: 8),
            Expanded(
                child: Text(endAddress ?? '',
                    style: primaryTextStyle(size: 14), maxLines: 2)),
            SizedBox(width: 8),
            mapRedirectionWidget(
                latLong: LatLng(endLatLong.latitude.toDouble(),
                    endLatLong.longitude.toDouble()))
          ],
        ),
      ],
    );
  }

  Widget emptyWalletAlertDialog() {
    return AlertDialog(
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(walletGIF, height: 150, fit: BoxFit.contain),
            SizedBox(height: 8),
            Text(language.lessWalletAmountMsg,
                style: primaryTextStyle(), textAlign: TextAlign.justify),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AppButtonWidget(
                    padding: EdgeInsets.zero,
                    color: Colors.red,
                    text: language.no,
                    textColor: Colors.white,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: AppButtonWidget(
                    padding: EdgeInsets.zero,
                    text: language.yes,
                    onTap: () {
                      if (appStore.mHelpAndSupport != null) {
                        Navigator.pop(context);

                        launchUrl(Uri.parse(appStore.mHelpAndSupport!));
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  _bookingForView() {
    if (servicesListData != null && servicesListData!.otherRiderData != null) {
      return Rideforwidget(
          name: servicesListData!.otherRiderData!.name.validate(),
          contact: servicesListData!.otherRiderData!.conatctNumber.validate());
    }

    return SizedBox();
  }

  Future<void> cancelRequest(String? reason) async {
    Map req = {
      "id": servicesListData!.id,
      "cancel_by": DRIVER,
      "status": CANCELED,
      "reason": reason,
    };
    print("CancelRIdeCall");
    await rideRequestUpdate(request: req, rideId: servicesListData!.id)
        .then((value) async {
      print("CancelRIdeCall2");
      print("CancelRIdeCall2CHeck::${value}");
      toast(value.message);

      chatMessageService.exportChat(
          rideId: "",
          senderId: sharedPref.getString(UID).validate(),
          receiverId: riderData!.uid.validate(),
          onlyDelete: true);

      setMapPins();
    }).catchError((error) {
      setMapPins();

      try {
        chatMessageService.exportChat(
            rideId: "",
            senderId: sharedPref.getString(UID).validate(),
            receiverId: riderData!.uid.validate(),
            onlyDelete: true);
      } catch (e) {
        developer.log('e.toString() $e');

        throw e;
      }

      log(error.toString());
    });
  }

  void checkRideCancel() async {
    if (rideCancelDetected) return;

    rideCancelDetected = true;

    appStore.setLoading(true);

    sharedPref.remove(ON_RIDE_MODEL);

    sharedPref.remove(IS_TIME2);

    await rideDetail(rideId: servicesListData!.id).then((value) {
      appStore.setLoading(false);

      if (value.data!.status == CANCELED && value.data!.cancelBy == RIDER) {
        _polyLines.clear();

        setMapPins();

        stopAudio();
        _triggerCanceledPopup(reason: value.data!.reason.validate());
      }
    }).catchError((error) {
      appStore.setLoading(false);

      log(error.toString());
    });
  }

  void _triggerCanceledPopup({required String reason}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Text(
                language.rideCanceledByDriver,
                maxLines: 2,
                style: boldTextStyle(),
              )),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.clear),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                language.cancelReason,
                style: secondaryTextStyle(),
              ),
              Text(
                reason,
                style: primaryTextStyle(),
              ),
            ],
          ),
        );
      },
    );
  }
}
