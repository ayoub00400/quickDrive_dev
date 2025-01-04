
  import 'dart:developer';

import '../../../../Services/network/RestApis.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/var/var_app.dart';

Future<void> driverStatus({int? status}) async {
    appStore.setLoading(true);

    Map req = {
      // "status": "active",

      "is_online": status,
    };

    await updateStatus(req).then((value) {
      sharedPref.setInt(IS_ONLINE, status ?? 0);

      appStore.setLoading(false);
    }).catchError((error) {
      appStore.setLoading(false);

      log(error.toString());
    });
  }
