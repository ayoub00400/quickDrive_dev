
  import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Services/bg_notification_service.dart';
import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/Colors.dart';
import '../../../../utils/Extensions/ConformationDialog.dart';
import '../../../../utils/Extensions/app_common.dart';
import '../../../../utils/var/var_app.dart';
import '../function/driverStatus.dart';

Widget onlineOfflineSwitch() {
DashboardController _dashboardController=  Get.put(DashboardController());

    return Positioned(
      left: 0,
      right: 0,
      bottom: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GetBuilder< DashboardController>(
              init:  DashboardController(), 
              builder: (controller) {
                return Text(
                controller.  isOnLine ? language.online : language.offLine,
                  style: boldTextStyle(
                    color: controller. isOnLine ? Colors.green : Colors.red,
                    size: 18,
                    weight: FontWeight.w700,
                  ),
                );
              }
            ),
            SizedBox(width: 8),
            GetBuilder<DashboardController>(
              init:  DashboardController(),
              builder: (controller) {
                return GestureDetector(
                  onTap: () async {
                    await showConfirmDialogCustom(
                        dialogType: DialogType.CONFIRMATION,
                        primaryColor: primaryColor,
                        title:controller. isOnLine ? language.areYouCertainOffline : language.areYouCertainOnline,
                       Get. context!, onAccept: (v) async {
                      driverStatus(status: controller. isOnLine ? 0 : 1);
                      if (controller. isOnLine) {
                        NotificationWithSoundService.service.invoke('stopService');
                      } else {
                        await NotificationWithSoundService.initializeService();
                      }

   WidgetsBinding.instance.addPostFrameCallback((_)  => _dashboardController.emitStateBool( "isOnLine" ,!controller. isOnLine) ); 

                      // isOnLine = !isOnLine;
                      // setState(() {});
                    });
                  },
                  child: GetBuilder <DashboardController>(
                    init:  DashboardController(),
                    builder: (controller) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 600),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color:controller. isOnLine ? Colors.green : Colors.red,
                          ),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Icon(
                         controller. isOnLine ? Icons.power_settings_new_outlined : Icons.power_settings_new_sharp,
                          color:controller. isOnLine ? Colors.green : Colors.red,
                          size: 32,
                        ),
                      );
                    }
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
