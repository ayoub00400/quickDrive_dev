 import 'package:get/get.dart';

import '../../../../controller/dashboard/dashboard_controller.dart';

void stopAudio() async {
DashboardController _dashboardController=  Get.put(DashboardController());

    await  _dashboardController.player.stop(); // Stops the sound immediately
 
  }
