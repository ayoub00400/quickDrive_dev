
 

  import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../../utils/Constants.dart';
import '../setPolyLines.dart';

Future<void> setMapPins() async {
DashboardController _dashboardController=  Get.put(DashboardController());

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

      // setState(() {});
    } catch (e) {
      // setState(() {});
    }

    setPolyLines();
  }
 
