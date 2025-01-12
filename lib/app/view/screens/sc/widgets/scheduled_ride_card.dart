import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:taxi_driver/app/controller/dashboard/dashboard_controller.dart';
import 'package:taxi_driver/app/utils/Extensions/AppButtonWidget.dart';

import '../../../../controller/dashboard/controller.dart';
import '../../../../model/RiderModel.dart';
import '../../../../utils/Colors.dart';
import '../../../../utils/Common.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/Extensions/app_common.dart';
import '../../../../utils/var/var_app.dart';
import 'package:taxi_driver/app/utils/Extensions/StringExtensions.dart';
import '../../RideDetailScreen.dart';
import '../../dashboard/dashboard.dart';
import 'send_offre_bottom_sheet.dart';

class ScheduledRideCard extends StatelessWidget {
  final RiderModel data;
  final  data2;
  ScheduledRideCard({required this.data, this.data2});

  @override
  Widget build(BuildContext context) {
    return inkWellWidget(
      onTap: () {
        launchScreen(context, RideDetailScreen(orderId: data.id!),
            pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: EdgeInsets.only(top: 8, bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(color: dividerColor),
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Ionicons.calendar, color: textSecondaryColorGlobal, size: 16),
                        SizedBox(width: 4),
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text('${printDate(data.createdAt.validate())}', style: primaryTextStyle(size: 14)),
                        ),
                      ],
                    ),
                    Text('${language.rideId} #${data.id}', style: boldTextStyle(size: 14)),
                  ],
                ),
                Divider(height: 20, thickness: 0.5),
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.near_me, color: Colors.green, size: 18),
                        SizedBox(width: 4),
                        Expanded(child: Text(data.startAddress.validate(), style: primaryTextStyle(size: 14), maxLines: 2)),
                      ],
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        SizedBox(width: 8),
                        SizedBox(
                          height: 34,
                          child: DottedLine(
                            direction: Axis.vertical,
                            lineLength: double.infinity,
                            lineThickness: 1,
                            dashLength: 2,
                            dashColor: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: 18),
                        SizedBox(width: 4),
                        Expanded(child: Text(data.endAddress.validate(), style: primaryTextStyle(size: 14), maxLines: 2)),
                      ],
                    ),
                    SizedBox(height: 2),
                    Divider(height: 20, thickness: 0.5),
                    Row(
                      children: [
                        Icon(Ionicons.person, color: textSecondaryColorGlobal, size: 16),
                        SizedBox(width: 4),
                        Text('${data.riderName}', style: primaryTextStyle(size: 14)),
                      ],
                    ), 
                    SizedBox(height: 2),
                    
                     Row(
                      children: [
                        Icon(Ionicons.time, color: textSecondaryColorGlobal, size: 16),
                        SizedBox(width: 4),
                        Text('${language.starttime}: ${data.startTime.validate()}', style: primaryTextStyle(size: 14)),
                      ],
                    ),
                    Divider(height: 20, thickness: 0.5),
                    AppButtonWidget(
                      width: MediaQuery.of(context).size.width,
                      child: Text((DateTime.now().isAfter(DateTime.parse(data.startTime.validate())))?language. scheduledStart : "${getTimeDifferenceAsText(data.startTime .toString())}", style: boldTextStyle(color: Colors.white)),
                      color: primaryColor,
                      onTap:()async {
                        Get.back();
                   
              //   if (DateTime.now().isAfter(DateTime.parse(data.startTime.validate()))) {
              // await SendScheduledRideOffreBottomSheet().showOffreInputDialog();   } else {
              //     toast("لا يمكنك الضغط على الزر قبل انتهاء الوقت المحدد.");
              //   }
              } ,
                    )
                  ],
                ),
              ],
            ),
      //  scheduledRideRequestView(Get.put(DashboardController()), data2) 
       
         ],
        ),
      ),
    );
    ;
  }
}
//   Widget _buildLocationRow(IconData icon, String label, String location) {
//     return Row(
//       children: [
//         Icon(icon, color: Colors.blue.shade800, size: 20),
//         const SizedBox(width: 8),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//             Text(
//               location,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

String getTimeDifferenceAsText(String startTime) {
  // تحويل النص إلى كائن DateTime
  DateTime startDate = DateTime.parse(startTime);
  DateTime now = DateTime.now();

  // حساب الفرق بين الوقتين
  Duration difference = startDate.difference(now);

  if (difference.isNegative) {
    return "الوقت المحدد قد مضى.";
  }

  // استخراج الأيام والساعات والدقائق
  int days = difference.inDays;
  int hours = difference.inHours % 24;
  int minutes = difference.inMinutes % 60;

  // إنشاء النص المناسب
  String result = "تبقى ";
  if (days > 0) result += "$days يوم${days > 1 ? '' : ''} ";
  if (hours > 0) result += "$hours ساعة${hours > 1 ? '' : ''} ";
  if (minutes > 0) result += "$minutes دقيقة${minutes > 1 ? '' : ''}";

  return result.trim();
}