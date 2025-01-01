import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taxi_driver/screens/DashboardScreen.dart';
import 'package:taxi_driver/screens/SignInScreen.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:upgrader/upgrader.dart';
import '../main.dart';
import '../network/RestApis.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';
import 'EditProfileScreen.dart';
import '../utils/Images.dart';
import 'WalkThroughScreen.dart';
import 'dart:io' show Platform;

class UpdateAppDialog extends StatelessWidget {
  const UpdateAppDialog({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      barrierDismissible: true,
      dialogStyle: Platform.isAndroid
          ? UpgradeDialogStyle.material
          : UpgradeDialogStyle.cupertino,
      upgrader: Upgrader(
        // debugLogging: true, // uncomment this line to see what the update process looks like
        // debugDisplayAlways: true, // uncomment this line to see what the update process looks like
        messages: UpgraderMessages(
          code: sharedPref.getString(SELECTED_LANGUAGE_CODE),
        ),
        languageCode: sharedPref.getString(SELECTED_LANGUAGE_CODE),
        countryCode: 'DZ',
      ),
      showIgnore: false,
      showLater: false,
      child: child,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkNotifyPermission();
  }

  void init() async {
    List<ConnectivityResult> b = await Connectivity().checkConnectivity();
    if (b.contains(ConnectivityResult.none)) {
      return toast(language.yourInternetIsNotWorking);
    }
    await driverDetail();

    await Future.delayed(Duration(seconds: 2));
    if (sharedPref.getBool(IS_FIRST_TIME) ?? true) {
      await Geolocator.requestPermission().then((value) async {
        launchScreen(
          context,
          UpdateAppDialog(child: WalkThroughScreen()),
          pageRouteAnimation: PageRouteAnimation.Slide,
          isNewTask: true,
        );
        Geolocator.getCurrentPosition().then((value) {
          sharedPref.setDouble(LATITUDE, value.latitude);
          sharedPref.setDouble(LONGITUDE, value.longitude);
        });
      }).catchError((e) {
        launchScreen(
          context,
          UpdateAppDialog(child: WalkThroughScreen()),
          pageRouteAnimation: PageRouteAnimation.Slide,
          isNewTask: true,
        );
      });
    } else {
      if (sharedPref.getString(CONTACT_NUMBER).validate().isEmptyOrNull &&
          appStore.isLoggedIn) {
        launchScreen(
          context,
          UpdateAppDialog(child: EditProfileScreen(isGoogle: true)),
          isNewTask: true,
          pageRouteAnimation: PageRouteAnimation.Slide,
        );
      } else if (sharedPref.getString(UID).validate().isEmptyOrNull &&
          appStore.isLoggedIn) {
        updateProfileUid().then((value) {
          if (sharedPref.getInt(IS_Verified_Driver) == 1) {
            launchScreen(
              context,
              UpdateAppDialog(child: DashboardScreen()),
              isNewTask: true,
              pageRouteAnimation: PageRouteAnimation.Slide,
            );
          } else {
            launchScreen(
              context,
              UpdateAppDialog(child: SignInScreen()),
              pageRouteAnimation: PageRouteAnimation.Slide,
              isNewTask: true,
            );
          }
        });
      } else if (sharedPref.getInt(IS_Verified_Driver) == 0 &&
          appStore.isLoggedIn) {
        launchScreen(
          context,
          UpdateAppDialog(child: SignInScreen()),
          pageRouteAnimation: PageRouteAnimation.Slide,
          isNewTask: true,
        );
      } else if (sharedPref.getInt(IS_Verified_Driver) == 1 &&
          appStore.isLoggedIn) {
        launchScreen(
          context,
          UpdateAppDialog(child: DashboardScreen()),
          pageRouteAnimation: PageRouteAnimation.SlideBottomTop,
          isNewTask: true,
        );
      } else {
        launchScreen(
          context,
          UpdateAppDialog(child: SignInScreen()),
          pageRouteAnimation: PageRouteAnimation.Slide,
          isNewTask: true,
        );
      }
    }
  }

  Future<void> driverDetail() async {
    if (appStore.isLoggedIn) {
      await getUserDetail(userId: sharedPref.getInt(USER_ID))
          .then((value) async {
        await sharedPref.setInt(IS_ONLINE, value.data!.isOnline!);
        // appStore.isAvailable = value.data!.isAvailable;
        if (value.data!.status == REJECT || value.data!.status == BANNED) {
          toast(
              '${language.yourAccountIs} ${value.data!.status}. ${language.pleaseContactSystemAdministrator}');
          logout();
        }
        appStore.setUserEmail(value.data!.email.validate());
        appStore.setUserName(value.data!.username.validate());
        appStore.setFirstName(value.data!.firstName.validate());
        appStore.setUserProfile(value.data!.profileImage.validate());

        sharedPref.setString(USER_EMAIL, value.data!.email.validate());
        sharedPref.setString(FIRST_NAME, value.data!.firstName.validate());
        sharedPref.setString(LAST_NAME, value.data!.lastName.validate());
      }).catchError((error) {});
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    const colorizeColors = [
      Color.fromARGB(255, 3, 37, 70),
      Colors.purple,
      Colors.blue,
      Colors.yellow,
      Colors.red,
    ];

    const colorizeTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32.0,
      fontFamily: 'Horizon',
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(ic_logo_white,
                fit: BoxFit.contain, height: 150, width: 150),
            AnimatedTextKit(
              animatedTexts: [
                ColorizeAnimatedText(
                  'QUICK CARGOO',
                  textStyle: colorizeTextStyle,
                  colors: colorizeColors,
                ),

                // ColorizeAnimatedText(
                //   'QUICK DRIVER',
                //   textStyle: colorizeTextStyle,
                //   colors: colorizeColors,
                // ),
                // ColorizeAnimatedText(
                //   'Steve Jobs',
                //   textStyle: colorizeTextStyle,
                //   colors: colorizeColors,
                // ),
              ],
              isRepeatingAnimation: true,
              onTap: () {
                print("Tap Event");
              },
            ),
          ],
        ),
      ),
    );
  }

  void _checkNotifyPermission() async {
    if (await Permission.notification.isGranted) {
      init();
    } else {
      await Permission.notification.request();
      init();
    }
  }
}
