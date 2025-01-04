
  import 'package:get/get.dart';

import '../../../../Services/network/RestApis.dart';
import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/Extensions/app_common.dart';
import '../../../../utils/var/var_app.dart';
import 'getCurrentRequest.dart';
import 'setMapPins.dart';

Future<void> rideRequest({String? status}) async {
DashboardController _dashboardController=  Get.put(DashboardController());
  
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
_dashboardController.update();
        // setState(() {});
      });
    }).catchError((error) {
      toast(error);

      appStore.setLoading(false);

      log(error.toString());
    });
  }
