
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Services/ChatMessagesService.dart';
import '../../Services/NotificationService.dart';
import '../../Services/UserServices.dart';
import '../../language/BaseLanguage.dart';
import '../../model/FileModel.dart';
import '../../model/LanguageDataModel.dart';
import '../../store/AppStore.dart';
import '../Colors.dart';

AppStore appStore = AppStore();
late SharedPreferences sharedPref;
Color textPrimaryColorGlobal = textPrimaryColor;
Color textSecondaryColorGlobal = textSecondaryColor;
Color defaultLoaderBgColorGlobal = Colors.white;
List<LanguageDataModel> localeLanguageList = [];
LanguageDataModel? selectedLanguageDataModel;
late BaseLanguage language;
final GlobalKey netScreenKey = GlobalKey();
final GlobalKey locationScreenKey = GlobalKey();
// bool isCurrentlyOnNoInternet = false;
int? stutasCount = 0;

late List<FileModel> fileList = [];
bool mIsEnterKey = false;
// String mSelectedImage = "assets/default_wallpaper.png";

ChatMessageService chatMessageService = ChatMessageService();
NotificationService notificationService = NotificationService();
UserService userService = UserService();

final navigatorKey = GlobalKey<NavigatorState>();

get getContext => navigatorKey.currentState?.overlay?.context;
late LocationPermission locationPermissionHandle;
