
 import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi_driver/app/utils/Extensions/StringExtensions.dart';
import 'package:taxi_driver/main.dart';

 import '../../Services/bg_notification_service.dart';
import '../../model/LanguageDataModel.dart';
import '../Constants.dart';
import '../DataProvider.dart';
import '../FirebaseOption.dart';
import '../var/var_app.dart';

initConfig()async{
 WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) {
 
  });
  FlutterError.onError = (
    errorDetails,
  ) {
    FirebaseCrashlytics.instance
        .recordError(errorDetails.exception, errorDetails.stack, fatal: true);
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordFlutterError(
        FlutterErrorDetails(exception: error, stack: stack));
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  sharedPref = await SharedPreferences.getInstance();
  await initialize(aLocaleLanguageList: languageList());
  appStore.setLanguage(defaultLanguage);
 
  await appStore.setLoggedIn(sharedPref.getBool(IS_LOGGED_IN) ?? false,
      isInitializing: true);
  await appStore.setUserId(sharedPref.getInt(USER_ID) ?? 0,
      isInitializing: true);
  await appStore.setUserEmail(sharedPref.getString(USER_EMAIL).validate(),
      isInitialization: true);
  await appStore.setUserProfile(
      sharedPref.getString(USER_PROFILE_PHOTO).validate(),
      isInitialization: true);
      if (sharedPref.getInt(IS_ONLINE) == 1) {
    await NotificationWithSoundService.initializeService();
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  ChuckerFlutter.showOnRelease = false; // TODO: Set to false before release
 }



Future<void> initialize({
  double? defaultDialogBorderRadius,
  List<LanguageDataModel>? aLocaleLanguageList,
  String? defaultLanguage,
}) async {
  localeLanguageList = aLocaleLanguageList ?? [];
  selectedLanguageDataModel =
      getSelectedLanguageModel(defaultLanguage: defaultLanguage);
}
