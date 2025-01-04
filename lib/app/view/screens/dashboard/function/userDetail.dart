
  import 'package:get/get.dart';

import '../../../../Services/network/RestApis.dart';
import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/var/var_app.dart';

Future<void> userDetail({int? driverId}) async {
DashboardController _dashboardController=  Get.put(DashboardController());

    await getUserDetail(userId: driverId).then((value) {
      appStore.setLoading(false);

      // riderData = value.data!;
      _dashboardController.emitStateUser( "riderData" , value.data!);

      // setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
    });
  }