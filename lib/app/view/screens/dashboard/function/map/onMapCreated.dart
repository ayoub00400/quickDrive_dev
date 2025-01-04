
  import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../controller/dashboard/dashboard_controller.dart';

onMapCreated(GoogleMapController controller) {
DashboardController _dashboardController=  Get.put(DashboardController());

   _dashboardController. controllerCompleter.complete(controller);
  }
