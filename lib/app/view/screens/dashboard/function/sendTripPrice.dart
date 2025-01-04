
  import 'package:get/get.dart';
import 'package:taxi_driver/app/view/screens/dashboard/function/getCurrentRequest.dart';

import '../../../../Services/network/RestApis.dart';
import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/Extensions/app_common.dart';
import '../../../../utils/var/var_app.dart';
import 'startCountdown.dart';
import 'stop_audio.dart';

Future<void> sendTripPrice({
    required String price,
    required String rideId,
  }) async {
DashboardController _dashboardController=  Get.put(DashboardController());

    appStore.setLoading(true);

    Map req = {
      "ride_request_id": rideId,
      "offer_price": price,
    };

    await sendTripPriceToRider(request: req).then((value) {
      stopAudio();
      // sendPrice = true;
         _dashboardController.emitStateBool( "sendPrice" ,true); 
      // Get.put(dependency)
      startCountdown();
      appStore.setLoading(false);

      toast(language.priceSentSuccessfully);

   _dashboardController.update();

      getCurrentRequest();
    }).catchError((error) {
      stopAudio();
                _dashboardController.emitStateBool( "sendPrice" , true); 

      // sendPrice = true;
      startCountdown();
      appStore.setLoading(false);

      log(error.toString());

      toast(error.toString());
    });
  }
