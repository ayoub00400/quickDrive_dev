import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taxi_driver/app/utils/Colors.dart';
import 'package:taxi_driver/app/utils/var/var_app.dart';

import '../../../controller/dashboard/controller.dart';
import '../../../model/RiderModel.dart';
import '../../../utils/Common.dart';
import '../../../utils/Extensions/app_common.dart';
import 'widgets/scheduled_ride_card.dart';

class ScheduledRides extends StatefulWidget {
  const ScheduledRides({super.key});

  @override
  State<ScheduledRides> createState() => _ScheduledRidesState();
}

class _ScheduledRidesState extends State<ScheduledRides> {
    final ScheduledRidesController controller = Get.put(ScheduledRidesController(
      scrollController: ScrollController(),
    ));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.fetchScheduledRides()
;    
  }
  @override
  Widget build(BuildContext context) {
    // Initialize the controller


    return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         child: Icon(
//           Icons.add,
//           color: appTextPrimaryColorWhite,
//         ),
//         onPressed: () {
// Get.put(ScheduledRidesController(
//       scrollController: ScrollController(),
//     ).fetchScheduledRides());        },
//       ),
      appBar: AppBar(
        title: Text(
          'Scheduled Rides',
          style: boldTextStyle(color: appTextPrimaryColorWhite),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          // Show a loader while data is being fetched
          if (controller.isLoading.value) {
            return loaderWidget();
          }

          // Show an error message if fetching failed
          if (controller.hasError.value) {
            return Center(child: Text("Oops, Loading Failed"));
          }

          // Show an empty widget if no scheduled rides are available
          if (controller.scheduledRides.isEmpty) {
            return emptyWidget();
          }

          // Show the list of scheduled rides
          return ListView.builder(
            controller: controller.scrollController,
            itemCount: controller.scheduledRides.length,
            itemBuilder: (context, index) {
              final item = controller.scheduledRides[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ScheduledRideCard(
                  data: RiderModel(
                    id: item.id,
                    createdAt: DateTime.now().toString(),
                    startAddress: item.startAddress,
                    endAddress: item.endAddress,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
