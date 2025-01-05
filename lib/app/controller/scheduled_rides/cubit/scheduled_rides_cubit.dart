import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:taxi_driver/app/utils/var/var_app.dart';

import '../../../Services/network/RestApis.dart';
import '../../../model/RiderModel.dart';
import '../../../utils/Constants.dart';
import '../../../view/screens/scheduled_rides/widgets/send_offre_bottom_sheet.dart';

part 'scheduled_rides_state.dart';

class ScheduledRidesCubit extends Cubit<ScheduledRidesState> {
  int currentPage = 1;
  late int maxPages;
  List<RiderModel> scheduledRides = [];
  TextEditingController OffreController = TextEditingController();
  ScrollController scrollController;
  ScheduledRidesCubit({required this.scrollController}) : super(ScheduledRidesInitial()) {
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (currentPage < maxPages) {
          currentPage++;
          fetchScheduledRides();
        }
      }
    });
  }

  void fetchScheduledRides() {
    /// Fetch Scheduled Rides
    /// This function is used to fetch the scheduled rides of the driver
    /// It will call the getRiderRequestList function from the RestApis class (all ready made by the ex dev )

    try {
      emit(ScheduledRidesLoading());
      getRiderRequestList(
        page: currentPage,
        driverId: sharedPref.getInt(USER_ID),
        status: SCHEDULED,
      ).then((value) {
        maxPages = value.pagination!.totalPages!;
        scheduledRides.addAll(value.data!);
        emit(ScheduledRidesLoaded());
      });
    } catch (e) {
      emit(ScheduledRidesLoadingFailed());
    }
  }

  sendScheduledRideOffre() async {
    await SendScheduledRideOffreBottomSheet().showOffreInputDialog();
  }
}
