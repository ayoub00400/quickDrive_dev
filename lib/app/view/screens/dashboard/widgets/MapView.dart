
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_driver/app/utils/Extensions/context_extensions.dart';

import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/var/var_app.dart';
import '../function/map/onMapCreated.dart';

class MapView extends StatelessWidget {
  const MapView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      
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
    );
  }
}
