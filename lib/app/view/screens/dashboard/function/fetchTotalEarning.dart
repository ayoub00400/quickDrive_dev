
  import 'dart:developer';

import 'package:get/get.dart';

import '../../../../Services/network/RestApis.dart';
import '../../../../controller/dashboard/dashboard_controller.dart';

void fetchTotalEarning() async {
DashboardController _dashboardController=  Get.put(DashboardController());

    await totalEarning().then((value) {
       log('value.toString() = ${value.toString()}');

      // totalEarnings = value.totalEarnings!;
               _dashboardController.emitStateInt( "totalEarnings" , value.totalEarnings!); 

      // setState(() {});
    }).catchError((error) {
      log(error.toString());
    });
  }