 
  import 'dart:convert';
import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';

import '../../../../Services/network/RestApis.dart';
import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../model/CurrentRequestModel.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/var/var_app.dart';
import 'dart:developer' as developer;

import 'setMapPins.dart';
import 'setTimeData.dart';

getNewRideReq(int? riderID) async {
DashboardController _dashboardController=  Get.put(DashboardController());

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


        // setState(() {});

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
