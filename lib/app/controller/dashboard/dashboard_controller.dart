import 'package:get/get.dart';

class DashboardController  extends   GetxController{


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



changeStateBool(tag ,bool valu){
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

changeStateInt(tag ,  valu){
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
 }

}
}