
  import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:taxi_driver/app/utils/Extensions/StringExtensions.dart';

import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/Colors.dart';
import '../../../../utils/Common.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/Extensions/app_common.dart';
import '../../../../utils/var/var_app.dart';
import '../../EditProfileScreen.dart';
import '../../NotificationScreen.dart';
import '../function/map/moveMap.dart';

Widget topWidget(context ,  {scaffoldKey ,
  dynamic Function()? onTap
}) {
DashboardController _dashboardController=  Get.put(DashboardController());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            inkWellWidget(
              onTap: () => scaffoldKey.currentState!.openDrawer(),
              child: Container(
                padding: EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 4,
                      width: 24,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(defaultRadius),
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      height: 4,
                      width: 16,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(defaultRadius),
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      height: 4,
                      width: 24,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(defaultRadius),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              'Quick Cargoo , ${sharedPref.getString(FIRST_NAME).validate().capitalizeFirstLetter()}!',
              style: boldTextStyle(size: 20),
            ),
            inkWellWidget(
              onTap: () {
                launchScreen(
                  context,
                  EditProfileScreen(isGoogle: false),
                  pageRouteAnimation: PageRouteAnimation.Slide,
                );
              },
              child: ClipOval(
                child: commonCachedNetworkImage(
                  appStore.userProfile.validate(),
                  height: 55,
                  width: 55,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
       
            Spacer(),

            inkWellWidget(
              onTap: () => launchScreen(getContext, NotificationScreen()),
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: primaryColor),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Ionicons.notifications_outline,
                  color: primaryColor,
                  size: 26,
                ),
              ),
            ),

            SizedBox(width: 8),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            inkWellWidget(
              onTap:  () {
                moveMap(
                  context,
                  Prediction(
                    lat:_dashboardController. driverLocation!.latitude.toString(),
                    lng: _dashboardController. driverLocation!.longitude.toString(),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: primaryColor),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.my_location_sharp,
                  color: primaryColor,
                  size: 26,
                ),
              ),
            ),
            SizedBox(width: 8),
          ],
        ),
      ],
    );
  }



 