// Notice : This problem is on your default app also

import 'dart:async';

import 'dart:convert';

import 'dart:developer' as developer;

import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
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

import 'package:taxi_driver/app/view/screens/ChatScreen.dart';

import 'package:taxi_driver/app/view/screens/DetailScreen.dart';

import 'package:taxi_driver/app/view/screens/EditProfileScreen.dart';

import 'package:taxi_driver/app/view/screens/NotificationScreen.dart';

import 'package:taxi_driver/app/view/screens/ReviewScreen.dart';

import 'package:taxi_driver/app/utils/Extensions/StringExtensions.dart';

import 'package:taxi_driver/app/utils/Extensions/app_textfield.dart';

import 'package:taxi_driver/app/utils/Extensions/context_extensions.dart';
import 'package:taxi_driver/app/view/screens/dashboard/widgets/top_widget.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:audioplayers/audioplayers.dart';

import '../../../Services/RideService.dart';

import '../../../Services/bg_notification_service.dart';
import '../../../components/AlertScreen.dart';

import '../../../components/CancelOrderDialog.dart';

import '../../../components/DrawerComponent.dart';

import '../../../components/ExtraChargesWidget.dart';

import '../../../components/RideForWidget.dart';

import '../../../controller/dashboard/dashboard_controller.dart';
import '../../../model/CurrentRequestModel.dart';

import '../../../model/ExtraChargeRequestModel.dart';

import '../../../model/FRideBookingModel.dart';

import '../../../model/RiderModel.dart';

import '../../../model/UserDetailModel.dart';

import '../../../model/WalletDetailModel.dart';

import '../../../Services/network/RestApis.dart';

import '../../../utils/Colors.dart';

import '../../../utils/Common.dart';

import '../../../utils/Constants.dart';

import '../../../utils/Extensions/AppButtonWidget.dart';

import '../../../utils/Extensions/ConformationDialog.dart';

import '../../../utils/Extensions/LiveStream.dart';

import '../../../utils/Extensions/app_common.dart';

import '../../../utils/Images.dart';

import '../../../utils/var/var_app.dart';
import '../LocationPermissionScreen.dart';
import 'function/cancelTimer.dart';
import 'function/fetchTotalEarning.dart';
import 'function/initPusher.dart';
import 'function/init_dashboard.dart';
import 'function/setPolyLines.dart';
import 'function/startLocationTracking.dart';
import 'function/stop_audio.dart';
import 'function/userDetail.dart';

class DashboardScreen extends StatefulWidget {
  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {


DashboardController _dashboardController=  Get.put(DashboardController());







 

  









   



 




 

 



  // init pusher

  
 

  @override
  void initState() {
    super.initState();

    // timerController = CountdownController(autoStart: false);

    if (sharedPref.getInt(IS_ONLINE) == 1) {
      setState(() {
               _dashboardController.emitStateBool( "isOnLine" , true); 

        // isOnLine = true;
      });
    } else {
               _dashboardController.emitStateBool( "isOnLine" , false); 

      // setState(() {
      //   isOnLine = false;
      // });
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
  

  Future<void> locationPermission() async {
    var serviceStatusStream = Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.disabled) {
        // locationEnable = false;
               _dashboardController.emitStateBool( "locationEnable" , false); 

        Future.delayed(
          Duration(seconds: 1),
          () {
            launchScreen(navigatorKey.currentState!.overlay!.context, LocationPermissionScreen());
          },
        );
      } else if (status == ServiceStatus.enabled) {
        // locationEnable = true;
                _dashboardController.emitStateBool( "locationEnable" , true); 
        startLocationTracking();

        if (locationScreenKey.currentContext != null) {
          if (Navigator.canPop(navigatorKey.currentState!.overlay!.context)) {
            Navigator.pop(navigatorKey.currentState!.overlay!.context);
          }
        }
      }
    });

      _dashboardController.emitStateStream( "serviceStatusStream" , serviceStatusStream );

  }

  cancelRideTimeOut() {
    print("CancelByApp:::187");

    Future.delayed(Duration(seconds: 1)).then((value) {
      appStore.setLoading(true);

      try {
        sharedPref.remove(ON_RIDE_MODEL);

        sharedPref.remove(IS_TIME2);

        // duration = startTime;
               _dashboardController.emitStateInt( "duration" , _dashboardController. startTime); 


     _dashboardController.emitStateBool( "timeSetCalled" , false);  

        // servicesListData = null;
        _dashboardController.emitStateService( "servicesListData" , null);

        _dashboardController. polyLines.clear();

        setMapPins();

        // sharedPref.setInt(IS_ONLINE,0);

        // isOnLine=false;

        setState(() {});

        // FlutterRingtonePlayer().stop();

        // timer.cancel();
      } catch (e) {}

      Map req = {
        "id":      _dashboardController.riderId,
        "driver_id": sharedPref.getInt(USER_ID),
        "is_accept": "0",
      };

      // duration = startTime;
               _dashboardController.emitStateInt( "duration" , _dashboardController. startTime); 

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

  Future<void> startTimer({required String tag}) async {
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

            setState(() {});
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

  onMapCreated(GoogleMapController controller) {
   _dashboardController. controllerCompleter.complete(controller);
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
        await   _dashboardController. rideService.updateStatusOfRide(rideID: value.onRideRequest!.id, req: {'on_rider_stream_api_call': 0});
      } catch (e) {
        print("Error Found:::$e");
      }

      appStore.setLoading(false);

      if (value.onRideRequest != null) {
        appStore.currentRiderRequest = value.onRideRequest;

        print("Check Estimated Price:ON-CURRENT REQ:${value.estimated_price}");

        if (value.estimated_price != null && value.estimated_price.isNotEmpty) {
          try {
            // estimatedTotalPrice = num.tryParse(value.estimated_price[0]['total_amount'].toString());
            _dashboardController.emitStatePolyline( "estimatedTotalPrice" ,num.tryParse(value.estimated_price[0]['total_amount'].toString()));

            // estimatedDistance = num.tryParse(value.estimated_price[0]['distance'].toString());
            _dashboardController.emitStatePolyline( "estimatedDistance" ,num.tryParse(value.estimated_price[0]['distance'].toString()));

            // distance_unit = value.estimated_price[0]['distance_unit'].toString();
            _dashboardController.emitStatePolyline( "distance_unit" ,value.estimated_price[0]['distance_unit'].toString());

          } catch (e) {}
        } else {
          // estimatedDistance = null;
          _dashboardController.emitStatePolyline( "estimatedDistance" ,null);

          // estimatedTotalPrice = null;
          Get. put(DashboardController()).emitStatePolyline( "estimatedTotalPrice" ,null);
        }

        // servicesListData = value.onRideRequest;
        _dashboardController.emitStateService( "servicesListData" , value.onRideRequest);

        userDetail(driverId: value.onRideRequest!.riderId);

        setState(() {});

        if (_dashboardController.servicesListData != null) {
          if (_dashboardController.servicesListData!.status != COMPLETED) {
            setMapPins();
          }

          if (_dashboardController.servicesListData!.status == COMPLETED && _dashboardController.servicesListData!.isDriverRated == 0) {
            if (_dashboardController.current_screen == false) 
            
            
            return;
 
            // current_screen = false;
                _dashboardController.emitStateBool( "current_screen" , false); 


            // value.onRideRequest.otherRiderData

            launchScreen(context, ReviewScreen(rideId: value.onRideRequest!.id!, currentData: value),
                pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
          } else if (value.payment != null && value.payment!.paymentStatus == PENDING) {
            if (_dashboardController.current_screen == false) return;

            // current_screen = false;
                _dashboardController.emitStateBool( "current_screen" , false); 

            launchScreen(context, DetailScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
          }
        }
      } else {
        if (value.payment != null && value.payment!.paymentStatus == PENDING) {
          if (_dashboardController.current_screen == false) return;

          // current_screen = false;
                _dashboardController.emitStateBool( "current_screen" , false); 

          launchScreen(context, DetailScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
        }
      }

      // if (servicesListData != null) await rideService.updateStatusOfRide(rideID: servicesListData!.id, req: {'status': servicesListData!.status});

      // await changeStatus();
    }).catchError((error) {
      toast(error.toString());

      appStore.setLoading(false);

      // servicesListData = null;
        _dashboardController.emitStateService( "servicesListData" , null);

      setState(() {});
    });
  }

  getNewRideReq(int? riderID) async {
    print("Check Function Call Count::472");

    print("TEST3::${_dashboardController. servicesListData}");
    //if (requestDataFetching == true) return;

    // requestDataFetching = true;
                _dashboardController.emitStateBool( "requestDataFetching" , true); 
    

    if (_dashboardController. servicesListData != null &&_dashboardController. servicesListData!.status == NEW_RIDE_REQUESTED) {
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
            // estimatedTotalPrice = num.tryParse(value.estimated_price[0]['total_amount'].toString());
            Get. put(DashboardController()).emitStatePolyline( "estimatedTotalPrice" ,num.tryParse(value.estimated_price[0]['total_amount'].toString()));

            // estimatedDistance = num.tryParse(value.estimated_price[0]['distance'].toString());
            Get. put(DashboardController()).emitStatePolyline( "estimatedDistance" ,num.tryParse(value.estimated_price[0]['distance'].toString()));

            // distance_unit = value.estimated_price[0]['distance_unit'].toString();
            Get. put(DashboardController()).emitStatePolyline( "distance_unit" ,value.estimated_price[0]['distance_unit'].toString());
          } catch (e) {}
        } else {
          // estimatedDistance = null;
 _dashboardController. emitStatePolyline( "estimatedDistance" ,null);
          // estimatedTotalPrice = null;
           _dashboardController. emitStatePolyline( "estimatedTotalPrice" ,null);
        }

         _dashboardController.emitStateService( "servicesListData" ,  ride);

        // rideDetailsFetching = false;
                _dashboardController.emitStateBool( "rideDetailsFetching" , false); 


        ride.otherRiderData;

        if (_dashboardController.servicesListData != null)
          await _dashboardController.rideService.updateStatusOfRide(rideID: _dashboardController.servicesListData!.id, req: {'on_rider_stream_api_call': 0});

        sharedPref.setString(ON_RIDE_MODEL, jsonEncode(_dashboardController.servicesListData));

        // riderId = servicesListData!.id!;
              _dashboardController.emitStateInt( "riderId" ,_dashboardController.servicesListData!.id!); 


        setState(() {});

        setTimeData();
      }

      // requestDataFetching = false;
                _dashboardController.emitStateBool( "requestDataFetching" , false); 

      setMapPins();
    }).catchError((error, stack) {
      print("TEST981");
      // rideDetailsFetching = false;
                _dashboardController.emitStateBool( "rideDetailsFetching" , false); 

      FirebaseCrashlytics.instance.recordError("pop_up_issue::" + error.toString(), stack, fatal: true);

      appStore.setLoading(false);

      log('error:${error.toString()}');
    });
  }

  Future<void> rideRequest({String? status}) async {
    appStore.setLoading(true);

    Map req = {
      "id":_dashboardController. servicesListData!.id,
      "status": status,
    };

    await rideRequestUpdate(request: req, rideId: _dashboardController.servicesListData!.id).then((value) async {
      appStore.setLoading(false);

      getCurrentRequest().then((value) async {
        if (status == ARRIVED) {
          _dashboardController. polyLines.clear();

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
      // sendPrice = true;
         _dashboardController.emitStateBool( "sendPrice" ,true); 
      // Get.put(dependency)
      startCountdown();
      appStore.setLoading(false);

      toast(language.priceSentSuccessfully);

      setState(() {});

      getCurrentRequest();
    }).catchError((error) {
      stopAudio();
                _dashboardController.emitStateBool( "sendPrice" , true); 

      // sendPrice = true;
      startCountdown();
      appStore.setLoading(false);

      log(error.toString());

      toast(error.toString());
    });
  }

  Future<void> rideRequestAccept({bool deCline = false}) async {
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

  Future<void> completeRideRequest() async {
    appStore.setLoading(true);

    Map req = {
      "id":_dashboardController. servicesListData!.id,
      "service_id": _dashboardController.servicesListData!.serviceId,
      "end_latitude": _dashboardController. driverLocation!.latitude,
      "end_longitude": _dashboardController.driverLocation!.longitude,
      "end_address":_dashboardController. endLocationAddress,
      "distance": _dashboardController.totalDistance,
      if (_dashboardController.extraChargeList.isNotEmpty) "extra_charges": _dashboardController.extraChargeList,
      if (_dashboardController.extraChargeList.isNotEmpty) "extra_charges_amount": _dashboardController.extraChargeAmount,
    };

    log(req);

    await completeRide(request: req).then((value) async {
      chatMessageService.exportChat(
          rideId: _dashboardController.servicesListData!.id.toString(),
          senderId: sharedPref.getString(UID).validate(),
          receiverId: _dashboardController.riderData!.uid.validate());

      try {
        await _dashboardController.rideService.updateStatusOfRide(rideID: _dashboardController.servicesListData!.id, req: {'on_rider_stream_api_call': 0});
      } catch (e) {
        print("Error Found:::$e");
      }

      // sourceIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), SourceIcon);
      _dashboardController.emitStateBitmap( "sourceIcon" , await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), SourceIcon));

      appStore.setLoading(false);

      getCurrentRequest();
    }).catchError((error) {
      chatMessageService.exportChat(
          rideId: _dashboardController.servicesListData!.id.toString(),
          senderId: sharedPref.getString(UID).validate(),
          receiverId: _dashboardController.riderData!.uid.validate());

      appStore.setLoading(false);

      log(error.toString());
    });
  }

 

  Future<void> setMapPins() async {
    try {
      _dashboardController.   markers.clear();

      ///source pin

      MarkerId id = MarkerId("driver");

     _dashboardController.   markers.remove(id);

      // markers.add(
      //   Marker(
      //     markerId: id,
      //     position: _dashboardController.driverLocation!,
      //     icon: Get.put( DashboardController()). driverIcon,
      //     infoWindow: InfoWindow(title: ''),
      //   ),
      // );

 _dashboardController. mapAdd( Marker(
          markerId: id,
          position: _dashboardController.driverLocation!,
          icon: Get.put( DashboardController()). driverIcon,
          infoWindow: InfoWindow(title: ''),
        ),);
      if (_dashboardController.servicesListData != null)
        _dashboardController.servicesListData!.status != IN_PROGRESS
            ? _dashboardController. mapAdd(
                Marker(
                  markerId: MarkerId('sourceLocation'),
                  position: LatLng(
                      double.parse(_dashboardController.servicesListData!.startLatitude!), double.parse(_dashboardController.servicesListData!.startLongitude!)),
                  icon: Get.put( DashboardController()).sourceIcon,
                  infoWindow: InfoWindow(title:_dashboardController. servicesListData!.startAddress),
                ),
              )
            : _dashboardController. mapAdd(
                Marker(
                  markerId: MarkerId('destinationLocation'),
                  position: LatLng(
                      double.parse(_dashboardController.servicesListData!.endLatitude!), double.parse(_dashboardController.servicesListData!.endLongitude!)),
                  icon: Get.put( DashboardController()).destinationIcon,
                  infoWindow: InfoWindow(title: _dashboardController.servicesListData!.endAddress),
                ),
              );

      setState(() {});
    } catch (e) {
      setState(() {});
    }

    setPolyLines();
  }

  /// Get Current Location


  /// WalletCheck


  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    // positionStream.cancel();

    // FlutterRingtonePlayer().stop();

   _dashboardController. countdownTimer?.cancel(); // Clean up timer

    if (_dashboardController.timerData != null) {
     _dashboardController. timerData!.cancel();
    }

   _dashboardController. positionStream.cancel();

    // if (timerData == null) {

    //   sharedPref.getString(IS_TIME2);

    // }

    super.dispose();
  }

  void moveMap(BuildContext context, Prediction prediction) async {
    final GoogleMapController controller = await    _dashboardController.controllerCompleter.future;

    controller.moveCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(double.parse(prediction.lat ?? ""), double.parse(prediction.lng ?? "")),
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
        key:Get.put( DashboardController()). scaffoldKey,
        drawer: DrawerComponent(onCall: () async {
          await driverStatus(status: 0);
        }),
        body: Stack(
          children: [
            if (sharedPref.getDouble(LATITUDE) != null && sharedPref.getDouble(LONGITUDE) != null)
              GetBuilder<DashboardController>(
                
                builder: ( controller) {
                  return GoogleMap(
                    mapToolbarEnabled: false,
                    zoomControlsEnabled: false,
                    myLocationEnabled: false,
                    compassEnabled: false,
                    padding: EdgeInsets.only(top: context.statusBarHeight + 4 + 24),
                    onMapCreated: onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: controller.driverLocation ?? LatLng(sharedPref.getDouble(LATITUDE)!, sharedPref.getDouble(LONGITUDE)!),
                      zoom: 17.0,
                    ),
                    markers: controller. markers,
                    mapType: MapType.normal,
                    polylines:controller. polyLines,
                  );
                }
              ),
 
            onlineOfflineSwitch(),

            newMethod(context),

            Positioned(
              top: context.statusBarHeight + 8,
              right: 14,
              left: 14,
              child: topWidget( context, scaffoldKey: Get.put( DashboardController()).scaffoldKey, onTap: () => Get.put( DashboardController()).scaffoldKey.currentState!.openDrawer()),
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

  GetBuilder<DashboardController> newMethod(BuildContext context) {
    return GetBuilder<DashboardController>(
            init: DashboardController(),
            builder: ( controller) {
              return StreamBuilder<QuerySnapshot>(
                stream: _dashboardController.rideService.fetchRide(userId: sharedPref.getInt(USER_ID)),
                builder: (c, snapshot) {
                  if (snapshot.hasData) {
                    List<FRideBookingModel> data = snapshot.data!.docs
                        .map((e) => FRideBookingModel.fromJson(e.data() as Map<String, dynamic>))
                        .toList();
              
                    if (data.length == 2) {
                      //here old ride of this driver remove if completed and payment is done code set
              
                      _dashboardController.rideService.removeOldRideEntry(
                        userId: sharedPref.getInt(USER_ID),
                      );
                    }
              
                    if (data.length != 0) {
                      // rideCancelDetected = false;
                           controller.emitStateBool( "rideCancelDetected" , false);      
                      if (data[0].onStreamApiCall == 0) {
                        _dashboardController.rideService.updateStatusOfRide(rideID: data[0].rideId, req: {'on_stream_api_call': 1});
                        if (data[0].status == NEW_RIDE_REQUESTED) {
                          print("TEST1");
                          getNewRideReq(data[0].rideId);
                        } else {
                          print("TEST2");
                          getCurrentRequest();
                        }
                      }
                      if (controller.servicesListData == null &&
                          data[0].status == NEW_RIDE_REQUESTED &&
                          data[0].onStreamApiCall == 1) {
                        // reqCheckCounter++;
              
             controller.emitStateInt( "reqCheckCounter"  , _dashboardController.reqCheckCounter + 1);
              
                        if (controller.reqCheckCounter < 1) {
                         _dashboardController. rideService.updateStatusOfRide(rideID: data[0].rideId, req: {'on_stream_api_call': 0});
                        }
                      }
                      if ((controller.servicesListData != null &&
                              controller.servicesListData!.status != NEW_RIDE_REQUESTED &&
                              data[0].status == NEW_RIDE_REQUESTED &&
                              data[0].onStreamApiCall == 1) ||
                          (controller.servicesListData == null &&
                              data[0].status == NEW_RIDE_REQUESTED &&
                              data[0].onStreamApiCall == 1)) {
                        if (    controller.rideDetailsFetching != true) {
                          // rideDetailsFetching = true;
                 controller.emitStateBool( "rideDetailsFetching" , true) ;
              
                         _dashboardController. rideService.updateStatusOfRide(rideID: data[0].rideId, req: {'on_stream_api_call': 0});
                        }
                      }
              
                      if (controller.servicesListData != null) {
                        return controller.servicesListData!.status != null && controller.servicesListData!.status == NEW_RIDE_REQUESTED
                              ? Builder(builder: (context) {
                                  // if (sendPrice == true && countdown == 0)
                                  //   return SizedBox();
                                  double progress = controller. countdown / 60;
              
                                  return SizedBox.expand(
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
              
                                       controller. servicesListData != null && controller. duration >= 0
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(2 * defaultRadius),
                                                          topRight: Radius.circular(2 * defaultRadius)),
                                                    ),
                                                    child: SingleChildScrollView(
                                                      // controller: scrollController,
                                            
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Align(
                                                            alignment: Alignment.center,
                                                            child: Container(
                                                              margin: EdgeInsets.only(top: 16),
                                                              height: 6,
                                                              width: 60,
                                                              decoration: BoxDecoration(
                                                                  color: primaryColor,
                                                                  borderRadius: BorderRadius.circular(defaultRadius)),
                                                              alignment: Alignment.center,
                                                            ),
                                                          ),
                                                          SizedBox(height: 8),
                                                          Padding(
                                                            padding: EdgeInsets.only(left: 16),
                                                            child: Text(language.requests, style: primaryTextStyle(size: 18)),
                                                          ),
                                                          SizedBox(height: 8),
                                                          Padding(
                                                            padding: EdgeInsets.all(16),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    ClipRRect(
                                                                      borderRadius: BorderRadius.circular(defaultRadius),
                                                                      child: commonCachedNetworkImage(
                                                                          controller.servicesListData!.riderProfileImage.validate(),
                                                                          height: 35,
                                                                          width: 35,
                                                                          fit: BoxFit.cover),
                                                                    ),
                                                                    SizedBox(width: 12),
                                                                    Expanded(
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                              '${controller.servicesListData!.riderName.capitalizeFirstLetter()}',
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: boldTextStyle(size: 14)),
                                                                          SizedBox(height: 4),
                                                                          Text('${controller.servicesListData!.riderEmail.validate()}',
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: secondaryTextStyle()),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    if (controller.duration > 0)
                                                                      Container(
                                                                        decoration: BoxDecoration(
                                                                            color: primaryColor,
                                                                            borderRadius:
                                                                                BorderRadius.circular(defaultRadius)),
                                                                        padding: EdgeInsets.all(6),
                                                                        
                                                                        child: Text("${controller. duration}".padLeft(2, "0"),
                                                                            style: boldTextStyle(color: Colors.white)),
                                                                      )
                                                                  ],
                                                                ),
                                                                if (controller. estimatedTotalPrice != null && controller.estimatedDistance != null)
                                                                  Container(
                                                                    padding: EdgeInsets.symmetric(vertical: 8),
                                                                    decoration: BoxDecoration(
                                                                        color: !appStore.isDarkMode
                                                                            ? scaffoldColorLight
                                                                            : scaffoldColorDark,
                                                                        borderRadius: BorderRadius.all(radiusCircular(8)),
                                                                        border: Border.all(width: 1, color: dividerColor)),
                                                                    child: Row(
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      mainAxisSize: MainAxisSize.max,
                                                                      children: [
                                                                     
                                            
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                                          mainAxisSize: MainAxisSize.max,
                                                                          children: [
                                                                            Text('${language.distance}:',
                                                                                style: secondaryTextStyle(size: 16)),
                                                                            SizedBox(width: 4),
                                                                            Text('${controller.estimatedDistance} ${controller.distance_unit}',
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: boldTextStyle(size: 14)),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    width:   MediaQuery.of(context).size.width,
                                                                  ),
                                                                addressDisplayWidget(
                                                                    endLatLong: LatLng(
                                                                        controller.servicesListData!.endLatitude.toDouble(),
                                                                       controller. servicesListData!.endLongitude.toDouble()),
                                                                    endAddress: controller.servicesListData!.endAddress,
                                                                    startLatLong: LatLng(
                                                                       controller. servicesListData!.startLatitude.toDouble(),
                                                                        controller.servicesListData!.startLongitude.toDouble()),
                                                                    startAddress:controller. servicesListData!.startAddress),
                                                                Align(
                                                                  alignment: AlignmentDirectional.centerStart,
                                                                  child: Text(
                                                                    '${language.shipmentType}: ${controller.servicesListData!.shipmentType}',
                                                                    style: primaryTextStyle(),
                                                                    textAlign: TextAlign.start,
                                                                  ),
                                                                ),
                                                                if (controller.servicesListData != null &&
                                                                   controller. servicesListData!.otherRiderData != null)
                                                                  Divider(
                                                                    color: Colors.grey.shade300,
                                                                    thickness: 0.7,
                                                                    height: 8,
                                                                  ),
                                                                _bookingForView( controller ),
                                                                SizedBox(height: 8),
                                                                (controller. countdown > 0)
                                                                    ? Stack(
                                                                        alignment: Alignment.center,
                                                                        children: [
                                                                          Container(
                                                                            width: MediaQuery.of(context).size.width,
                                                                            height: 48,
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(8),
                                                                              border: Border.all(
                                                                                  color: Colors.grey.withOpacity(0.5)),
                                                                              gradient: LinearGradient(
                                                                                colors: [
                                                                                  const Color(0xFF417CFF),
                                                                                  Colors.white
                                                                                ],
                                                                                stops: [progress, progress + 0.01],
                                                                                begin: Alignment.centerLeft,
                                                                                end: Alignment.centerRight,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Center(
                                                                            child: Text(
                                                                              'تم ارسال العرض (${controller. countdown}s)',
                                                                              style: boldTextStyle(
                                                                                size: 16,
                                                                                color: Colors.black, // Ensure text contrast
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : AppTextField(
                                                                        controller: _dashboardController. priceController,
                                                                        textFieldType: TextFieldType.PHONE,
                                                                        decoration: InputDecoration(
                                                                          hintText: language.enterPrice,
                                                                          hintStyle: primaryTextStyle(),
                                                                          contentPadding:
                                                                              EdgeInsets.symmetric(horizontal: 16),
                                                                          border: OutlineInputBorder(),
                                                                        ),
                                                                        inputFormatters: [
                                                                          FilteringTextInputFormatter.digitsOnly
                                                                        ],
                                                                      ),
                                                                SizedBox(height: 8),
                                                                GetBuilder<DashboardController>(
                                                                  init: DashboardController(),
                                                                  builder: (controller) {
                                                                    return Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child: inkWellWidget(
                                                                            onTap: () {
                                                                              showConfirmDialogCustom(
                                                                                  dialogType: DialogType.DELETE,
                                                                                  primaryColor: primaryColor,
                                                                                  title: language
                                                                                      .areYouSureYouWantToCancelThisRequest,
                                                                                  positiveText: language.yes,
                                                                                  negativeText: language.no,
                                                                                  context, onAccept: (v) {
                                                                                try {
                                                                                  // FlutterRingtonePlayer()
                                                                                  // .stop();
                                                                    
                                                                                  _dashboardController.timerData!.cancel();
                                                                                } catch (e) {}
                                                                    
                                                                                sharedPref.remove(IS_TIME2);
                                                                    
                                                                                sharedPref.remove(ON_RIDE_MODEL);
                                                                    
                                                                                rideRequestAccept(deCline: true);
                                                                              }).then(
                                                                                (value) {
                                                                                  _dashboardController. polyLines.clear();
                                                                    
                                                                                  setState;
                                                                                },
                                                                              );
                                                                            },
                                                                            child: Container(
                                                                              padding: EdgeInsets.symmetric(
                                                                                  vertical: 10, horizontal: 8),
                                                                              decoration: BoxDecoration(
                                                                                  borderRadius:
                                                                                      BorderRadius.circular(defaultRadius),
                                                                                  border: Border.all(color: Colors.red)),
                                                                              child: Text(language.decline,
                                                                                  style: boldTextStyle(color: Colors.red),
                                                                                  textAlign: TextAlign.center),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        if (!controller.sendPrice) SizedBox(width: 16),
                                                                        if (!controller.sendPrice)
                                                                          Expanded(
                                                                            child: AppButtonWidget(
                                                                              padding: EdgeInsets.symmetric(
                                                                                  vertical: 12, horizontal: 8),
                                                                              text: language.accept,
                                                                              shapeBorder: RoundedRectangleBorder(
                                                                                  borderRadius:
                                                                                      BorderRadius.circular(defaultRadius)),
                                                                              color: primaryColor,
                                                                              textStyle: boldTextStyle(color: Colors.white),
                                                                              onTap: () {
                                                                                if (controller.sendPrice == true) return;
                                                                                showConfirmDialogCustom(
                                                                                    primaryColor: primaryColor,
                                                                                    dialogType: DialogType.ACCEPT,
                                                                                    positiveText: language.yes,
                                                                                    negativeText: language.no,
                                                                                    title: language
                                                                                        .areYouSureYouWantToAcceptThisRequest,
                                                                                    context, onAccept: (v) {
                                                                                  if (double.tryParse(_dashboardController. priceController.text) ==
                                                                                      null) {
                                                                                    toast(language.pleaseEnterValidPrice);
                                                                    
                                                                                    return;
                                                                                  } else if (int.parse(_dashboardController. priceController.text) <
                                                                                     controller. estimatedTotalPrice) {
                                                                                    toast(
                                                                                        "${language.pleaseEnterPriceGreaterThan} ${printAmount(controller.estimatedTotalPrice.toStringAsFixed(2))}");
                                                                    
                                                                                    return;
                                                                                  }
                                                                    
                                                                                  try {
                                                                              
                                                                    
                                                                                  _dashboardController.  timerData!.cancel();
                                                                                  } catch (e) {}
                                                                    
                                                                                  
                                                                    
                                                                                  sendTripPrice(
                                                                                    price: _dashboardController. priceController.text,
                                                                                    rideId: controller.servicesListData!.id.toString(),
                                                                                  );
                                                                                });
                                                                              },
                                                                            ),
                                                                          ),
                                                                      ],
                                                                    );
                                                                  }
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
                                          return appStore.isLoading ? loaderWidget() : SizedBox();
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
                                          topLeft: Radius.circular(2 * defaultRadius),
                                          topRight: Radius.circular(2 * defaultRadius)),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(defaultRadius),
                                              child: commonCachedNetworkImage(controller.servicesListData!.riderProfileImage,
                                                  height: 48, width: 48, fit: BoxFit.cover),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('${controller.servicesListData!.riderName.capitalizeFirstLetter()}',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: boldTextStyle(size: 18)),
                                                  SizedBox(height: 4),
                                                  Text('${controller.servicesListData!.riderEmail.validate()}',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: secondaryTextStyle()),
                                                ],
                                              ),
                                            ),
                                            inkWellWidget(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) {
                                                    return AlertDialog(
                                                      contentPadding: EdgeInsets.all(0),
                                                      content: AlertScreen(
                                                          rideId:controller. servicesListData!.id,
                                                          regionId:controller. servicesListData!.regionId),
                                                    );
                                                  },
                                                );
                                              },
                                              child: chatCallWidget(Icons.sos),
                                            ),
                                            SizedBox(width: 8),
                                            inkWellWidget(
                                              onTap: () {
                                                launchUrl(Uri.parse('tel:${controller.servicesListData!.riderContactNumber}'),
                                                    mode: LaunchMode.externalApplication);
                                              },
                                              child: chatCallWidget(Icons.call),
                                            ),
                                            SizedBox(width: 8),
                                            inkWellWidget(
                                              onTap: () {
                                                if (controller. riderData == null || (controller.riderData != null && controller.riderData!.uid == null)) {
                                                  init();
              
                                                  return;
                                                }
              
                                                if (controller.riderData != null) {
                                                  launchScreen(
                                                      context,
                                                      ChatScreen(
                                                        userData: controller.riderData,
                                                        ride_id: _dashboardController. riderId,
                                                      ));
                                                }
                                              },
                                              child: chatCallWidget(Icons.chat_bubble_outline, data: controller.riderData),
                                            ),
                                          ],
                                        ),
                                        if (controller.estimatedTotalPrice != null && controller.estimatedDistance != null)
                                          Container(
                                            padding: EdgeInsets.symmetric(vertical: 8),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                               
              
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: [
                                                    Text('${language.distance}:', style: secondaryTextStyle(size: 16)),
                                                    SizedBox(width: 4),
                                                    Text('${controller.estimatedDistance} ${controller.distance_unit}',
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: boldTextStyle(size: 14)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            // width: context.width(),
                                             width:  MediaQuery.of(context).size.width,
                                          ),
                                        Divider(
                                          color: Colors.grey.shade300,
                                          thickness: 0.7,
                                          height: 4,
                                        ),
                                        SizedBox(height: 8),
                                        addressDisplayWidget(
                                            endLatLong: LatLng(controller.servicesListData!.endLatitude.toDouble(),
                                               controller. servicesListData!.endLongitude.toDouble()),
                                            endAddress: controller.servicesListData!.endAddress,
                                            startLatLong: LatLng(controller.servicesListData!.startLatitude.toDouble(),
                                               controller. servicesListData!.startLongitude.toDouble()),
                                            startAddress: controller.servicesListData!.startAddress),
                                        SizedBox(height: 8),
                                       controller. servicesListData!.status != NEW_RIDE_REQUESTED
                                            ? Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: controller.servicesListData!.status == IN_PROGRESS ? 0 : 8),
                                                child: _bookingForView( controller ),
                                              )
                                            : SizedBox(),
                                        if (controller.servicesListData!.status == IN_PROGRESS &&
                                            controller.servicesListData != null &&
                                           controller. servicesListData!.otherRiderData != null)
              
                                   
              
                                          SizedBox(height: 8),
                                        if (controller.servicesListData!.status == IN_PROGRESS)
                                          if (appStore.extraChargeValue != null)
                                            Observer(builder: (context) {
                                              return Visibility(
                                                visible: int.parse(appStore.extraChargeValue!) != 0,
                                                child: inkWellWidget(
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
                                                          child: ExtraChargesWidget(data:controller. extraChargeList),
                                                        );
                                                      },
                                                    );
              
                                                    if (extraChargeListData != null) {
                                                      log("extraChargeListData   $extraChargeListData");
              
                                                      // extraChargeAmount = 0;
                controller.emitStateInt( "extraChargeAmount"  , 0); 
              
                                                     controller. extraChargeList.clear();
              
                                                      extraChargeListData.forEach((element) {
                controller.emitStateInt( "extraChargeAmount"  , controller. extraChargeAmount + element.value!); 
              
                                                        // extraChargeAmount = extraChargeAmount + element.value!;
              
                                                        // extraChargeList = extraChargeListData;
                        controller.extraChargeListChange( extraChargeListData);

                                                      });
                                                    }
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.only(bottom: 8),
              
                                                         
              
                                                        child: Container(
                                                       
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.max,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                           
                                                                GetBuilder<DashboardController>(
                                                                  init:  DashboardController(),
                                                                  builder: (controller) {
                                                                    return  controller.extraChargeAmount != 0 ?  Text(
                                                                        '${language.extraCharges} ${printAmount(controller.extraChargeAmount.toString())}',
                                                                        style: secondaryTextStyle(color: Colors.green)) : SizedBox.shrink();
                                                                  }
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                        buttonWidget( controller)
                                      ],
                                    ),
                                  ),
                                );
                      } else {
                        return SizedBox();
                      }
                    } else {
                      if (data.isEmpty) {
                        try {
                          // FlutterRingtonePlayer().stop();
              
                          if (_dashboardController.timerData != null) {
                           _dashboardController. timerData!.cancel();
                          }
                        } catch (e) {}
                      }
              
                      if (controller.servicesListData != null) {
                        checkRideCancel();
                      }
              
                      if (  _dashboardController.riderId != 0) {
                        // riderId = 0;
                controller..emitStateInt( "riderId" , 0) ;
              
                        try {
                          sharedPref.remove(IS_TIME2);
              
                       _dashboardController.   timerData!.cancel();
                        } catch (e) {}
                      }
              
                     controller. servicesListData = null;
              
                    controller.  polyLines.clear();
              
                      return SizedBox();
                    }
                  } else {
                    return snapWidgetHelper(
                      snapshot,
                      loadingWidget: loaderWidget(),
                    );
                  }
                },
              );
            }
          );
  }

 
  // Method to start the countdown


  //  TODO remove setState
  void startCountdown() {
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



  Future<void> getUserLocation() async {
    List<Placemark> placemarks = await placemarkFromCoordinates( _dashboardController. driverLocation!.latitude,_dashboardController. driverLocation!.longitude);

    Placemark place = placemarks[0];

    // endLocationAddress = '${place.street},${place.subLocality},${place.thoroughfare},${place.locality}';
    _dashboardController.emitStateString( "endLocationAddress"  , '${place.street},${place.subLocality},${place.thoroughfare},${place.locality}');
  }

//TODO:Hossam hadi kharajha fi widgets
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
            GetBuilder< DashboardController>(
              init:  DashboardController(), 
              builder: (controller) {
                return Text(
                controller.  isOnLine ? language.online : language.offLine,
                  style: boldTextStyle(
                    color: controller. isOnLine ? Colors.green : Colors.red,
                    size: 18,
                    weight: FontWeight.w700,
                  ),
                );
              }
            ),
            SizedBox(width: 8),
            GetBuilder<DashboardController>(
              init:  DashboardController(),
              builder: (controller) {
                return GestureDetector(
                  onTap: () async {
                    await showConfirmDialogCustom(
                        dialogType: DialogType.CONFIRMATION,
                        primaryColor: primaryColor,
                        title:controller. isOnLine ? language.areYouCertainOffline : language.areYouCertainOnline,
                        context, onAccept: (v) async {
                      driverStatus(status: controller. isOnLine ? 0 : 1);
                      if (controller. isOnLine) {
                        NotificationWithSoundService.service.invoke('stopService');
                      } else {
                        await NotificationWithSoundService.initializeService();
                      }

   WidgetsBinding.instance.addPostFrameCallback((_)  => _dashboardController.emitStateBool( "isOnLine" ,!controller. isOnLine) ); 

                      // isOnLine = !isOnLine;
                      setState(() {});
                    });
                  },
                  child: GetBuilder <DashboardController>(
                    init:  DashboardController(),
                    builder: (controller) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 600),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color:controller. isOnLine ? Colors.green : Colors.red,
                          ),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Icon(
                         controller. isOnLine ? Icons.power_settings_new_outlined : Icons.power_settings_new_sharp,
                          color:controller. isOnLine ? Colors.green : Colors.red,
                          size: 32,
                        ),
                      );
                    }
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

//TODO:Hossam hadi kharajha fi widgets
  Widget buttonWidget(DashboardController controller ) {
    if ( controller.servicesListData!.status == ACCEPTED) {
      cancelTimer();
    }
    return Row(
      children: [
        if ( controller.servicesListData!.status != IN_PROGRESS)
          Expanded(
            flex: 0,
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: AppButtonWidget(
                  text: language.cancel,
                  textColor: primaryColor,
                  color: Colors.white,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultRadius), side: BorderSide(color: primaryColor)),

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
        if ( controller.servicesListData!.status == IN_PROGRESS)
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
               
                    ],
                  ),

                  // width: MediaQuery.of(context).size.width,

                  text: language.extraFees,
                  textColor: primaryColor,
                  color: Colors.white,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultRadius), side: BorderSide(color: primaryColor)),

                  // color: Colors.grey,

                  // textStyle: boldTextStyle(color: Colors.white),

                  onTap: () async {
                    List<ExtraChargeRequestModel>? extraChargeListData = await showModalBottomSheet(
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(defaultRadius), topRight: Radius.circular(defaultRadius))),
                      context: context,
                      builder: (_) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: ExtraChargesWidget(data: controller.extraChargeList),
                        );
                      },
                    );

                    if (extraChargeListData != null) {
                      log("extraChargeListData   $extraChargeListData");

                      // extraChargeAmount = 0;
                _dashboardController.emitStateInt( "extraChargeAmount" , 0); 

                      controller.extraChargeList.clear();

                      extraChargeListData.forEach((element) {
                        // extraChargeAmount = extraChargeAmount + element.value!;
                _dashboardController.emitStateInt( "extraChargeAmount" ,   _dashboardController.extraChargeAmount + element.value!); 

                        // extraChargeList = extraChargeListData;
                        controller.extraChargeListChange( extraChargeListData);
                      });
                    }
                  }),
            ),
          ),
        GetBuilder<DashboardController>(
          init:  DashboardController(),
          builder: (  controller) {
            return Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: AppButtonWidget(
                  // width: MediaQuery.of(context).size.width,
            
                  text: buttonText(status:  controller.servicesListData!.status),
            
                  color: primaryColor,
            
                  textStyle: boldTextStyle(color: Colors.white),
            
                  onTap: () async {
                    if (await checkPermission()) {
                      if ( controller.servicesListData!.status == ACCEPTED) {
                        showConfirmDialogCustom(
                            primaryColor: primaryColor,
                            positiveText: language.yes,
                            negativeText: language.no,
                            dialogType: DialogType.CONFIRMATION,
                            title: language.areYouSureYouWantToArriving,
                            context, onAccept: (v) {
                          rideRequest(status: ARRIVING);
                        });
                      } else if ( controller.servicesListData!.status == ARRIVING) {
                        showConfirmDialogCustom(
                            primaryColor: primaryColor,
                            positiveText: language.yes,
                            negativeText: language.no,
                            dialogType: DialogType.CONFIRMATION,
                            title: language.areYouSureYouWantToArrived,
                            context, onAccept: (v) {
                          rideRequest(status: ARRIVED);
                        });
                      } else if ( controller.servicesListData!.status == ARRIVED) {
                       _dashboardController.  otpController.clear();
            
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.enterOtp, style: boldTextStyle(), textAlign: TextAlign.center),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: inkWellWidget(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                                            child: Icon(Icons.close, size: 20, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Text(language.startRideAskOTP,
                                      style: secondaryTextStyle(size: 12), textAlign: TextAlign.center),
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
                                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                                        ),
            
                                        focusedPinTheme: PinTheme(
                                          width: 40,
                                          height: 44,
                                          textStyle: TextStyle(
                                            fontSize: 18,
                                          ),
                                          decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius: BorderRadius.all(Radius.circular(8)),
                                              border: Border.all(color: primaryColor)),
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
                                              borderRadius: BorderRadius.all(Radius.circular(8)),
                                              border: Border.all(color: dividerColor)),
                                        ),
            
                                        isCursorAnimationEnabled: true,
            
                                        showCursor: true,
            
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            
                                        closeKeyboardWhenCompleted: false,
            
                                        enableSuggestions: false,
            
                                        autofillHints: [],
            
                                        controller: _dashboardController. otpController,
            
                                        onCompleted: (val) {
                                          // otpCheck = val;
                                           _dashboardController.emitStateInt( "otpCheck" , val);
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  GetBuilder<DashboardController>(
                                    init:  DashboardController(),
                                    builder: (  controller) {
                                      return AppButtonWidget(
                                        width: MediaQuery.of(context).size.width,
                                        text: language.confirm,
                                        onTap: () {
                                          if (  controller. otpCheck == null || controller. otpCheck !=  controller.servicesListData!.otp) {
                                            return toast(language.pleaseEnterValidOtp);
                                          } else {
                                            Navigator.pop(context);
                                                  
                                            rideRequest(status: IN_PROGRESS);
                                          }
                                        },
                                      );
                                    }
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      } else if ( controller.servicesListData!.status == IN_PROGRESS) {
                        showConfirmDialogCustom(
                            primaryColor: primaryColor,
                            dialogType: DialogType.ACCEPT,
                            title: language.finishMsg,
                            context,
                            positiveText: language.yes,
                            negativeText: language.no, onAccept: (v) {
                          appStore.setLoading(true);
            
                          getUserLocation().then((value2) async {
                          controller.  totalDistance = calculateDistance(
                                double.parse( controller.servicesListData!.startLatitude.validate()),
                                double.parse( controller.servicesListData!.startLongitude.validate()),
                                _dashboardController.driverLocation!.latitude,
                                _dashboardController.driverLocation!.longitude);
            
                            await completeRideRequest();
                          });
                        });
                      }
                    }
                  },
                ),
              ),
            );
          }
        ),
      ],
    );
  }

  Widget addressDisplayWidget(
      {String? startAddress, String? endAddress, required LatLng startLatLong, required LatLng endLatLong}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.near_me, color: Colors.green, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text(startAddress ?? ''.validate(), style: primaryTextStyle(size: 14), maxLines: 2)),
            mapRedirectionWidget(latLong: LatLng(startLatLong.latitude.toDouble(), startLatLong.longitude.toDouble()))
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
            Expanded(child: Text(endAddress ?? '', style: primaryTextStyle(size: 14), maxLines: 2)),
            SizedBox(width: 8),
            mapRedirectionWidget(latLong: LatLng(endLatLong.latitude.toDouble(), endLatLong.longitude.toDouble()))
          ],
        ),
      ],
    );
  }

  _bookingForView(DashboardController controller) {
    if ( controller.servicesListData != null &&  controller.servicesListData!.otherRiderData != null) {
      return Rideforwidget(
          name:  controller.servicesListData!.otherRiderData!.name.validate(),
          contact:  controller.servicesListData!.otherRiderData!.conatctNumber.validate());
    }

    return SizedBox();
  }

  Future<void> cancelRequest(String? reason) async {
    Map req = {
      "id":_dashboardController. servicesListData!.id,
      "cancel_by": DRIVER,
      "status": CANCELED,
      "reason": reason,
    };
    print("CancelRIdeCall");
    await rideRequestUpdate(request: req, rideId:_dashboardController.servicesListData!.id).then((value) async {
      print("CancelRIdeCall2");
      print("CancelRIdeCall2CHeck::${value}");
      toast(value.message);

      chatMessageService.exportChat(
          rideId: "",
          senderId: sharedPref.getString(UID).validate(),
          receiverId:_dashboardController. riderData!.uid.validate(),
          onlyDelete: true);

      setMapPins();
    }).catchError((error) {
      setMapPins();

      try {
        chatMessageService.exportChat(
            rideId: "",
            senderId: sharedPref.getString(UID).validate(),
            receiverId:_dashboardController. riderData!.uid.validate(),
            onlyDelete: true);
      } catch (e) {
        developer.log('e.toString() $e');

        throw e;
      }

      log(error.toString());
    });
  }

  void checkRideCancel() async {
    if (_dashboardController.rideCancelDetected) return;

    // rideCancelDetected = true;
             WidgetsBinding.instance.addPostFrameCallback((_)  =>    _dashboardController.emitStateBool( "rideCancelDetected" , false)  ); 

    appStore.setLoading(true);

    sharedPref.remove(ON_RIDE_MODEL);

    sharedPref.remove(IS_TIME2);

    await rideDetail(rideId:_dashboardController. servicesListData!.id).then((value) {
      appStore.setLoading(false);

      if (value.data!.status == CANCELED && value.data!.cancelBy == RIDER) {
         _dashboardController.  polyLines.clear();

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
