
  import 'package:get/get.dart';

import '../../../../Services/network/RestApis.dart';
import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/Extensions/app_common.dart';
import '../../../../utils/var/var_app.dart';
import '../../DetailScreen.dart';
import '../../ReviewScreen.dart';
import 'setMapPins.dart';
import 'userDetail.dart';

Future<void> getCurrentRequest( ) async {
DashboardController _dashboardController=  Get.put(DashboardController());

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

        // setState(() {});

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

            launchScreen( Get.context, ReviewScreen(rideId: value.onRideRequest!.id!, currentData: value),
                pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
          } else if (value.payment != null && value.payment!.paymentStatus == PENDING) {
            if (_dashboardController.current_screen == false) return;

            // current_screen = false;
                _dashboardController.emitStateBool( "current_screen" , false); 

            launchScreen(Get.context, DetailScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
          }
        }
      } else {
        if (value.payment != null && value.payment!.paymentStatus == PENDING) {
          if (_dashboardController.current_screen == false) return;

          // current_screen = false;
                _dashboardController.emitStateBool( "current_screen" , false); 

          launchScreen(Get.context, DetailScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
        }
      }

      // if (servicesListData != null) await rideService.updateStatusOfRide(rideID: servicesListData!.id, req: {'status': servicesListData!.status});

      // await changeStatus();
    }).catchError((error) {
      toast(error.toString());

      appStore.setLoading(false);

      // servicesListData = null;
        _dashboardController.emitStateService( "servicesListData" , null);

      // setState(() {});
    });
  }