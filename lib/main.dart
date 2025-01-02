import 'dart:async';
import 'dart:ui';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi_driver/app/myapp.dart';
import 'package:taxi_driver/app/view/screens/SplashScreen.dart';
import 'package:taxi_driver/app/store/AppStore.dart';
import 'package:taxi_driver/app/utils/Colors.dart';
import 'package:taxi_driver/app/utils/Common.dart';
import 'package:taxi_driver/app/utils/Constants.dart';
import 'package:taxi_driver/app/utils/DataProvider.dart';
import 'package:taxi_driver/app/utils/Extensions/StringExtensions.dart';
import 'package:taxi_driver/app/utils/FirebaseOption.dart';
import 'app/utils/AppTheme.dart';
import 'app/Services/ChatMessagesService.dart';
import 'app/Services/NotificationService.dart';
import 'app/Services/UserServices.dart';
import 'app/Services/bg_notification_service.dart';
import 'app/Services/sound_service.dart';
import 'app/language/AppLocalizations.dart';
import 'app/language/BaseLanguage.dart';
import 'app/model/FileModel.dart';
import 'app/model/LanguageDataModel.dart';
import 'app/utils/initConfig/init_main.dart';
import 'app/view/screens/NoInternetScreen.dart';
import 'app/utils/Extensions/app_common.dart';

void main() async {
 await initConfig();
  runApp(MyApp());
}

