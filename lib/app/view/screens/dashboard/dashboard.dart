import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_driver/app/model/RiderModel.dart';
import 'package:taxi_driver/app/utils/Extensions/StringExtensions.dart';
import 'package:taxi_driver/app/utils/Extensions/context_extensions.dart';
import 'package:taxi_driver/app/view/screens/dashboard/widgets/top_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../components/AlertScreen.dart';
import '../../../components/DrawerComponent.dart';
import '../../../controller/dashboard/dashboard_controller.dart';
import '../../../model/RideDetailModel.dart';
import '../../../utils/Common.dart';
import '../../../utils/Constants.dart';
import '../../../utils/Extensions/AppButtonWidget.dart';
import '../../../utils/Extensions/app_common.dart';
import '../../../utils/var/var_app.dart';
import 'function/driverStatus.dart';
import 'function/fetchTotalEarning.dart';
import 'function/initPusher.dart';
import 'function/init_dashboard.dart';
import 'function/locationPermission.dart';
import 'widgets/MapView.dart';
import 'widgets/addressDisplayWidget.dart';
import 'widgets/fetchRideView.dart';

import 'widgets/onlineOfflineSwitch.dart';

class DashboardScreen extends StatefulWidget {
  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  DashboardController _dashboardController = Get.put(DashboardController());
  @override
  void initState() {
    super.initState();
    if (sharedPref.getInt(IS_ONLINE) == 1) {
      _dashboardController.emitStateBool("isOnLine", true);
    } else {
      _dashboardController.emitStateBool("isOnLine", false);
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
    _dashboardController.countdownTimer?.cancel(); // Clean up timer

    if (_dashboardController.timerData != null) {
      _dashboardController.timerData!.cancel();
    }

    _dashboardController.positionStream.cancel();

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
        key: Get.put(DashboardController()).scaffoldKey,
        drawer: DrawerComponent(onCall: () async {
          await driverStatus(status: 0);
        }),
        body: Stack(
          children: [
            if (sharedPref.getDouble(LATITUDE) != null && sharedPref.getDouble(LONGITUDE) != null) MapView(),
            onlineOfflineSwitch(),
            FetchRideView(
              dashboardController: _dashboardController,
            ),
            GetBuilder<DashboardController>(builder: (controller) {
              if (_dashboardController.isScheduleRideRequestShowed)
                return scheduledRideRequestView(_dashboardController, _dashboardController.scheduledRideData!);
              else
                return SizedBox.shrink();
            }),
            Positioned(
              top: context.statusBarHeight + 8,
              right: 14,
              left: 14,
              child: topWidget(context,
                  scaffoldKey: Get.put(DashboardController()).scaffoldKey,
                  onTap: () => Get.put(DashboardController()).scaffoldKey.currentState!.openDrawer()),
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

Widget scheduledRideRequestView(DashboardController controller, RideDetailModel rideData) {
  return Positioned(
    bottom: 0,
    child: Container(
      width: MediaQuery.of(getContext).size.width,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(2 * defaultRadius), topRight: Radius.circular(2 * defaultRadius)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(language.scheduledRideRequest, style: boldTextStyle(size: 18)),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(defaultRadius),
                child: commonCachedNetworkImage(rideData.data!.riderProfileImage ?? "",
                    height: 48, width: 48, fit: BoxFit.cover),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${rideData.data!.riderName}',
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: boldTextStyle(size: 18)),
                    SizedBox(height: 4),
                    Text('${rideData.data!.riderEmail}',
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: secondaryTextStyle()),
                  ],
                ),
              ),
              SizedBox(width: 8),
              inkWellWidget(
                onTap: () {
                  launchUrl(Uri.parse('tel:${rideData.data!.riderContactNumber}'),
                      mode: LaunchMode.externalApplication);
                },
                child: chatCallWidget(Icons.call),
              ),
              SizedBox(width: 8),
            ],
          ),
          Divider(
            color: Colors.grey.shade300,
            thickness: 0.7,
            height: 4,
          ),
          SizedBox(height: 8),
          addressDisplayWidget(
              endLatLong: LatLng(rideData.data!.endLatitude.toDouble(), rideData.data!.endLongitude.toDouble()),
              endAddress: rideData.data!.endAddress,
              startLatLong: LatLng(rideData.data!.startLatitude.toDouble(), rideData.data!.startLongitude.toDouble()),
              startAddress: rideData.data!.startAddress),
          SizedBox(height: 8),
          TextFormField(
            keyboardType: TextInputType.number,
            controller: controller.schedulerPriceController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: language.price,
              hintText: 'Offre Price',
            ),
          ),
          SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            AppButtonWidget(
                text: language.sendOffre,
                onTap: () {
                  controller.sendScheduledTripPrice(
                      rideId: rideData.data!.id!, price: controller.schedulerPriceController.text);
                }),
            AppButtonWidget(
                text: '${language.decline}',
                color: Colors.red,
                onTap: () {
                  controller.ignoreScheduledRide();
                })
          ])
        ],
      ),
    ),
  );
}
