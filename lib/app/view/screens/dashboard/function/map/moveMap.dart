
  import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

import '../../../../../controller/dashboard/dashboard_controller.dart';

void moveMap(BuildContext context, Prediction prediction) async {
DashboardController _dashboardController=  Get.put(DashboardController());

    final GoogleMapController controller = await    _dashboardController.controllerCompleter.future;

    controller.moveCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(double.parse(prediction.lat ?? ""), double.parse(prediction.lng ?? "")),
        14,
      ),
    );
  }
