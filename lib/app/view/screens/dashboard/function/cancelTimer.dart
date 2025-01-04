  import 'package:get/get.dart';

import '../../../../controller/dashboard/dashboard_controller.dart';

void cancelTimer() {
DashboardController _dashboardController=  Get.put(DashboardController());

   _dashboardController. countdownTimer?.cancel();
    // countdown = 0;
    _dashboardController.emitStateInt( "countdown" , 0);
  }