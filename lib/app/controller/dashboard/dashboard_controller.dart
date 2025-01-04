import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:taxi_driver/app/model/CurrentRequestModel.dart';

import '../../Services/RideService.dart';
import '../../model/ExtraChargeRequestModel.dart';
import '../../model/UserDetailModel.dart';

class DashboardController  extends   GetxController{
  UserData? riderData;


  bool timeSetCalled = false;

  bool isOnLine = true;

  bool locationEnable = true;

  bool current_screen = true;
  bool rideCancelDetected = false;

  bool rideDetailsFetching = false;

  bool requestDataFetching = false;
  // bool requestDataFetching = false;

  bool sendPrice = false;


// int
 int reqCheckCounter = 0;

  int startTime = 60;

  int end = 0;

  int duration = 0;

  int count = 0;

  int riderId = 0;
  num totalEarnings = 0;
  num extraChargeAmount = 0;
  double totalDistance = 0.0;
   int countdown = 0;

// String
  String? otpCheck;

  String endLocationAddress = '';

  // AudioPlayer

  final player = AudioPlayer();


//  Timer
  Timer? timerUpdateLocation;

  Timer? timerData;
  Timer? countdownTimer;



//  LatLng
  LatLng? driverLocation;

  LatLng? sourceLocation;

  LatLng? destinationLocation;

//  BitmapDescriptor
  late BitmapDescriptor driverIcon;

  late BitmapDescriptor destinationIcon;

  late BitmapDescriptor sourceIcon;

//  PolylinePoints
    var estimatedTotalPrice;
  var estimatedDistance;
  var distance_unit;
  late PolylinePoints polylinePoints;
  Set<Polyline> polyLines = Set<Polyline>();

// Service
  RideService rideService = RideService();
  OnRideRequest? servicesListData;

// Completer
  Completer<GoogleMapController> controllerCompleter = Completer();


  // map 

final Set<Marker> markers = {};
  List<LatLng> polylineCoordinates = [];
  List<ExtraChargeRequestModel> extraChargeList = [];


mapAdd( Marker marker){

  markers.add(
    marker
  );
  update();
}

polylineCoordinatesAdd(   val){

  polylineCoordinates.add(
    val
  );
  update();
}extraChargeListChange(   val){

  extraChargeList = val;
  update();
}

//  Stream
  late StreamSubscription<Position> positionStream;
  LocationPermission? permissionData;
  late StreamSubscription messageSubscription;
  late StreamSubscription<ServiceStatus> serviceStatusStream;
  StreamController messageController = StreamController.broadcast();


  // TextEditing 

  final otpController = TextEditingController();

  final priceController = TextEditingController();


  // key

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  


emitStateBool(tag ,bool valu){
 switch(tag){
   case "timeSetCalled":
     timeSetCalled = valu;
     update();
     break;
   case "isOnLine":
     isOnLine = valu;
     update();

     break;
   case "locationEnable":
     locationEnable = valu;
     update();

     break;
   case "current_screen":
     current_screen = valu;
     update();

     break;
   case "sendPrice":
     sendPrice = valu;
     update();

     break;
   case "rideCancelDetected":
     rideCancelDetected = valu;
    //  update();



     break;

    case "rideDetailsFetching":
      rideDetailsFetching = valu;
      // update();
      break;
    case "requestDataFetching":
      requestDataFetching = valu;
      // update();
      break;
    
 }
//  update();
}

emitStateInt(tag ,  valu){
 switch(tag){
   case "reqCheckCounter":
     reqCheckCounter = valu;
    //  update();
     break;
   case "startTime":
     startTime = valu;
     update();
     break;
   case "end":
     end = valu;
     update();
     break;
   case "duration":
     duration = valu;
     update();
     break;
   case "count":
     count = valu;
     update();
     break;
   case "riderId":
     riderId = valu;
    //  update();
     break;
   case "totalEarnings":
     totalEarnings = valu;
     update();
     break;
   case "extraChargeAmount":
     extraChargeAmount = valu;
     update();
     break;
   case "totalDistance":
     totalDistance = valu;
     update();
     break;
   case "countdown":
     countdown = valu;
     update();
     break;
 
 }

}

emitStateString(tag ,  valu){
 switch(tag){
   case "otpCheck":
     otpCheck = valu;
     update();
     break;
   case "endLocationAddress":
     endLocationAddress = valu;
     update();
     break;
 }
}

emitStateLatLng(tag ,  valu){
 switch(tag){
   case "driverLocation":
     driverLocation = valu;
     update();
     break;
   case "sourceLocation":
     sourceLocation = valu;
     update();
     break;
   case "destinationLocation":
     destinationLocation = valu;
     update();
     break;
 }
}

emitStateTime(tag ,  valu){
 switch(tag){
   case "timerUpdateLocation":
     timerUpdateLocation = valu;
     update();
     break;
   case "timerData":
     timerData = valu;
     update();
     break;
   case "countdownTimer":
     countdownTimer = valu;
     update();
     break;
   
 }
}
emitStateBitmap(tag ,  valu){
 switch(tag){
   case "driverIcon":
     driverIcon = valu;
     update();
     break;
   case "destinationIcon":
     destinationIcon = valu;
     update();
     break;
   case "sourceIcon":
     sourceIcon = valu;
     update();
     break;
 }
 }
emitStatePolyline(tag ,  valu){
 switch(tag){
   case "estimatedTotalPrice":
     estimatedTotalPrice = valu;
     update();
     break;
   case "estimatedDistance":
     estimatedDistance = valu;
     update();
     break;
   case "distance_unit":
     distance_unit = valu;
     update();
     break;
      case "polylinePoints":
     polylinePoints = valu;
     update();
     break;
       case "polyLines":
     polyLines = valu;
     update();
     break;
 }
 }
emitStateStream(tag ,  valu){

 switch(tag){
   case "positionStream":
     positionStream = valu;
     update();
     break;
   case "permissionData":
     permissionData = valu;
     update();
     break;

     case "messageSubscription":
     messageSubscription = valu;
     update();
     break;

      case "messageController":
     messageController = valu;
     update();
     break;
      case "serviceStatusStream":
     serviceStatusStream = valu;
     update();
     break;
   
 }
}
 

 emitStateService( tag ,  valu){
 switch(tag){
   case "servicesListData":
     servicesListData = valu;
     update();
     break;


 }
 }

 emitStateUser( tag ,  valu){
 switch(tag){
   case "riderData":
     riderData = valu;
     update();
     break;
 }
 }
}