import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:taxi_driver/app/utils/var/var_app.dart';

import '../../Services/network/RestApis.dart';
import '../../model/RiderModel.dart';
import '../../utils/Constants.dart';
import '../../view/screens/sc/widgets/send_offre_bottom_sheet.dart';

 

class ScheduledRidesController extends GetxController {
  int currentPage = 1;
  late int maxPages;
  RxList<RiderModel> scheduledRides = <RiderModel>[].obs;
  TextEditingController offreController = TextEditingController();
  ScrollController scrollController;

  ScheduledRidesController({required this.scrollController}) {
    // Listener for pagination
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (currentPage < maxPages) {
          currentPage++;
          fetchScheduledRides();
        }
      }
    });
  }

  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;

  void fetchScheduledRides() async {
    /// Fetch Scheduled Rides
    /// This function is used to fetch the scheduled rides of the driver
    /// It will call the getRiderRequestList function from the RestApis class (already made by the ex-dev)
print("fetchScheduledRides");
    try {
      isLoading.value = true;
      hasError.value = false;
      var response = await getRiderRequestList(
        page: currentPage,
        driverId: sharedPref.getInt(USER_ID),
        status: SCHEDULED,
      );
      Logger().d(response.data!.length);
      maxPages = response.pagination!.totalPages!;
      scheduledRides.addAll(response.data!);
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendScheduledRideOffre() async {
    await SendScheduledRideOffreBottomSheet().showOffreInputDialog();
  }
}