import '../../../../components/RideForWidget.dart';
import '../../../../controller/dashboard/dashboard_controller.dart';
// Notice : This problem is on your default app also

import 'dart:async';


import 'dart:developer' as developer;

import 'package:get/get.dart';
// import 'package:just_audio/just_audio.dart';


import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:dotted_line/dotted_line.dart';


import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:flutter_mobx/flutter_mobx.dart';

import 'package:google_places_flutter/model/prediction.dart';


// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'package:geocoding/geocoding.dart';


import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:pinput/pinput.dart';

import 'package:taxi_driver/app/view/screens/ChatScreen.dart';



import 'package:taxi_driver/app/utils/Extensions/StringExtensions.dart';

import 'package:taxi_driver/app/utils/Extensions/app_textfield.dart';

import 'package:taxi_driver/app/utils/Extensions/context_extensions.dart';
import 'package:taxi_driver/app/view/screens/dashboard/widgets/top_widget.dart';

import 'package:url_launcher/url_launcher.dart';



 
 
  import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Services/bg_notification_service.dart';
import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/Colors.dart';
import '../../../../utils/Extensions/ConformationDialog.dart';
import '../../../../utils/Extensions/app_common.dart';
import '../../../../utils/var/var_app.dart';
import '../function/driverStatus.dart';
bookingForView(DashboardController controller) {
    if ( controller.servicesListData != null &&  controller.servicesListData!.otherRiderData != null) {
      return Rideforwidget(
          name:  controller.servicesListData!.otherRiderData!.name.validate(),
          contact:  controller.servicesListData!.otherRiderData!.conatctNumber.validate());
    }

    return SizedBox();
  }