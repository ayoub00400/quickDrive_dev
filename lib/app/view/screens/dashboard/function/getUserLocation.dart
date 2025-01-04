
  import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

import '../../../../controller/dashboard/dashboard_controller.dart';

Future<void> getUserLocation() async {
DashboardController _dashboardController=  Get.put(DashboardController());

    List<Placemark> placemarks = await placemarkFromCoordinates( _dashboardController. driverLocation!.latitude,_dashboardController. driverLocation!.longitude);

    Placemark place = placemarks[0];

    // endLocationAddress = '${place.street},${place.subLocality},${place.thoroughfare},${place.locality}';
    _dashboardController.emitStateString( "endLocationAddress"  , '${place.street},${place.subLocality},${place.thoroughfare},${place.locality}');
  }
