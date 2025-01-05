 
import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taxi_driver/app/utils/Extensions/context_extensions.dart';
import 'package:taxi_driver/app/view/screens/dashboard/widgets/top_widget.dart';
import '../../../components/DrawerComponent.dart';
import '../../../controller/dashboard/dashboard_controller.dart';
import '../../../utils/Common.dart';
import '../../../utils/Constants.dart';
import '../../../utils/var/var_app.dart';
import 'function/driverStatus.dart';
import 'function/fetchTotalEarning.dart';
import 'function/initPusher.dart';
import 'function/init_dashboard.dart';
import 'function/locationPermission.dart';
import 'widgets/MapView.dart';
import 'widgets/fetchRideView.dart';
import 'widgets/onlineOfflineSwitch.dart';
class DashboardScreen extends StatefulWidget {
  @override
  DashboardScreenState createState() => DashboardScreenState();
}
class DashboardScreenState extends State<DashboardScreen> {
DashboardController _dashboardController=  Get.put(DashboardController());
  @override
  void initState() {
    super.initState();
    if (sharedPref.getInt(IS_ONLINE) == 1) {
      _dashboardController.emitStateBool( "isOnLine" , true); 
    } else {
  _dashboardController.emitStateBool( "isOnLine" , false); 
    }
    locationPermission();
    fetchTotalEarning();
    initPusher();
    init();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
   _dashboardController. countdownTimer?.cancel(); // Clean up timer

    if (_dashboardController.timerData != null) {
     _dashboardController. timerData!.cancel();
    }

   _dashboardController. positionStream.cancel();
 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (v) async {
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
              statusBarColor: Colors.black38),
        ),
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: true,
        key:Get.put( DashboardController()). scaffoldKey,
        drawer: DrawerComponent(onCall: () async {
          await driverStatus(status: 0);
        }),
        body: Stack(
          children: [
            if (sharedPref.getDouble(LATITUDE) != null && sharedPref.getDouble(LONGITUDE) != null)
              MapView(),
 
            onlineOfflineSwitch(),

            FetchRideView(  dashboardController: _dashboardController,),
            Positioned(
              top: context.statusBarHeight + 8,
              right: 14,
              left: 14,
              child: topWidget( context, scaffoldKey: Get.put( DashboardController()).scaffoldKey, onTap: () => Get.put( DashboardController()).scaffoldKey.currentState!.openDrawer()),
            ),
 

            Visibility(
              visible: appStore.isLoading,
              child: loaderWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
