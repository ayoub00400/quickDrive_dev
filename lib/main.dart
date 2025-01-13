
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'app/myapp.dart';
import 'app/utils/initConfig/init_main.dart';


void main() async {
 await initConfig();
   await GetStorage.init();

  runApp(MyApp());
}
// arslen
