import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi_driver/app/utils/Colors.dart';
import 'package:taxi_driver/app/utils/var/var_app.dart';

import '../../../controller/scheduled_rides/cubit/scheduled_rides_cubit.dart';
import '../../../model/RiderModel.dart';
import '../../../utils/Common.dart';
import '../../../utils/Extensions/app_common.dart';
import 'widgets/scheduled_ride_card.dart';

// class ScheduledRides extends StatelessWidget {
//   const ScheduledRides({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//           child: SingleChildScrollView(
//         child: Column(
//           children: List.generate(
//               100,
//               (index) =>
//                   ScheduledRideCard(clientName: 'Ayoub Larbaoui', from: 'Oran, Algeria', to: 'Algiers, Algeria')),
//         ),
//       )),
//     );
//   }
// }

import 'package:flutter/material.dart';

class ScheduledRides extends StatelessWidget {
  const ScheduledRides({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScheduledRidesCubit(scrollController: ScrollController())..fetchScheduledRides(),
      child: Scaffold(appBar: AppBar(
        title: BlocBuilder<ScheduledRidesCubit, ScheduledRidesState>(
          builder: (context, state) {
            return Text('scheduledRide (${context.read<ScheduledRidesCubit>().scheduledRides.length})',
                style: boldTextStyle(color: appTextPrimaryColorWhite));
          },
        ),
      ), body: SafeArea(
        child: BlocBuilder<ScheduledRidesCubit, ScheduledRidesState>(
          builder: (context, state) {
            if (state is ScheduledRidesLoading) {
              return loaderWidget();
            }
      
            if (state is ScheduledRidesLoaded && context.read<ScheduledRidesCubit>().scheduledRides.isEmpty) {
              return emptyWidget();
            }
                  if (state is ScheduledRidesLoadingFailed) {
              return emptyWidget();
            }
            return ListView(
              children: context
                  .read<ScheduledRidesCubit>()
                  .scheduledRides
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ScheduledRideCard(
                          data: RiderModel(
                            id: item.id,
                            createdAt: DateTime.now().toString(),
                            startAddress: item.startAddress,
                            endAddress: item.endAddress,
                          ),
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      )),
    );
  }
}
