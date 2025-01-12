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
    final ScheduledRidesController controller2 = Get.put(ScheduledRidesController(
      scrollController: ScrollController(),
    ));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller2.fetchScheduledRides()
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
//     ).fetchScheduledRides2());        },
//       ),
      appBar: AppBar(
        title: Text(
         language.acceptedScheduledTrips,
          style: boldTextStyle(color: appTextPrimaryColorWhite),
        ),
      ),
      body: SafeArea(
        child: GetBuilder< ScheduledRidesController>(
          // init:   ScheduledRidesController( scrollController: ScrollController(),),
          builder: (controller) {
                // Show a loader while data is being fetched
              if (controller.isLoading.value) {
                return loaderWidget();
              }
            
              // Show an error message if fetching failed
              if (controller.hasError.value) {
                return Center(child: Text(language.oopsLoadingFailed));
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
                      data: item,
                      data2:controller.scheduledRides22 ,
                    ),
                  );
                },
              );
           
          }
        ),
      ),
    );
  }
}
