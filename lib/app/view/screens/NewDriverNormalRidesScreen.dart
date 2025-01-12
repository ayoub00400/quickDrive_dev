import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Services/network/NetworkUtils.dart';
import '../../controller/NewDriverNormalRidesController.dart';
import '../../controller/dashboard/dashboard_controller.dart';
import '../../model/NewDriverScheduledRide2.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/AppButtonWidget.dart';
import '../../utils/Extensions/app_common.dart';
import '../../utils/var/var_app.dart';
import 'dashboard/dashboard.dart';
import 'dashboard/widgets/addressDisplayWidget.dart';
import 'sc/widgets/scheduled_ride_card copy.dart';
import 'package:http/http.dart' as http;

class TestScreen extends StatefulWidget {
  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
 

@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
 
    Get.delete<NewDriverNormalRidesController>();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
 
      appBar: AppBar(
        title: Text('Driver Rides' , style: TextStyle(color: Colors.white),),
        actions: [
     
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
        onRefresh: () async {
          Get.put(NewDriverNormalRidesController()).refreshRides();
        },
        child:SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                 
                  
                        GetBuilder<NewDriverNormalRidesController>(
                        init: NewDriverNormalRidesController(),
                        builder: (controller) {
                             if (controller.isLoading  ) {
                      return Center(child: CircularProgressIndicator());
                    }       if (  controller.driverRidesResponse == null) {
                      return Center(child: Text('لا رحلات جديدة'));
                    }
                          return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount:controller.driverRidesResponse!.newDriverScheduledRides.length,
                            itemBuilder: (context, index) {
                              final ride =  controller.driverRidesResponse!.newDriverScheduledRides[index] ;
                              return ScheduledRideCard2( 
                                data: controller.driverRidesResponse!.newDriverScheduledRides[index],);
                            },
                          );
                        }
                      ),
              
                  
                ],
              ),
            ),
          ),
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: GetBuilder<NewDriverNormalRidesController>(
                  builder: (controller) {
                    return    controller.selectitem != null? scheduledRideRequestView2(Get.put(DashboardController()), controller.selectitem!) :SizedBox.shrink();
                  }
                ),
      )    ],
      ),
    );
  }
}

Widget scheduledRideRequestView2(DashboardController controller, NewDriverScheduledRide rideData) {
  return Positioned(
    bottom: 0,
    child: Container(
      width: MediaQuery.of(getContext).size.width,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(2 * defaultRadius), topRight: Radius.circular(2 * defaultRadius)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Scheduled Ride Request', style: boldTextStyle(size: 18)),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(defaultRadius),
              //   child: commonCachedNetworkImage(rideData.data!.riderProfileImage ?? "",
              //       height: 48, width: 48, fit: BoxFit.cover),
              // ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text('${rideData.data!.riderName}',
                    //     maxLines: 1, overflow: TextOverflow.ellipsis, style: boldTextStyle(size: 18)),
                    // SizedBox(height: 4),
                    // Text('${rideData.data!.riderEmail}',
                    //     maxLines: 1, overflow: TextOverflow.ellipsis, style: secondaryTextStyle()),
                  ],
                ),
              ),
              SizedBox(width: 8),
            
              SizedBox(width: 8),
            ],
          ),
          Divider(
            color: Colors.grey.shade300,
            thickness: 0.7,
            height: 4,
          ),
          SizedBox(height: 8),
          addressDisplayWidget(
              endLatLong: LatLng(rideData.rideRequest.endLatitude!.toDouble(), rideData.rideRequest!.endLongitude!.toDouble()),
              endAddress: rideData.rideRequest!.endAddress,
              startLatLong: LatLng(rideData.rideRequest!.startLatitude!.toDouble(), rideData.rideRequest.startLongitude!.toDouble()),
              startAddress: rideData.rideRequest!.startAddress),
          SizedBox(height: 8),
          TextFormField(
            keyboardType: TextInputType.number,
            controller: controller.schedulerPriceController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: language.price,
              hintText: 'Offre Price',
            ),
          ),
          SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            AppButtonWidget(
                text: 'Send Offre',
                onTap: () async{
                
                   Map<String, String> req = {"ride_request_id": rideData.rideRequest.id.toString(), "offer_price": controller.schedulerPriceController.text, "type": SCHEDULED};
                   if (controller.schedulerPriceController.text.isEmpty) {
      toast('Please enter price');
      return;
    }
    if (double.parse(controller.schedulerPriceController.text.trim()) <= 0) {
      toast('Please enter price greater than 0');
      return;
    } 
    
   await sendScheduledTripPriceOffre2(request: req
                       ).then((value) async {
                       }); 
                }),
            AppButtonWidget(
                text: '${language.decline}',
                color: Colors.red,
                onTap: () {
                  Get.put(NewDriverNormalRidesController ()).updatePriceClose(  );
                })
          ])
        ],
      ),
    ),
  );
}
Future<void> sendScheduledTripPriceOffre2({required Map<String, String> request}) async {

  var headers = buildHeaderTokens();
  var url = Uri.parse(
    '${mBaseUrl}driver-offer',
  ).replace(queryParameters: request);
 
  var response = await http.post(url, headers: headers);
  Logger().e(response.body);
  if (response.statusCode == 409) {
  Get.put(NewDriverNormalRidesController()).refreshRides();

    toast("You have already made an offer for this ride request.".toString() , bgColor: Colors.red);
                          
  
}
 if (response.statusCode == 201) {
  Get.put(NewDriverNormalRidesController()).refreshRides();
    Get.put(NewDriverNormalRidesController ()).updatePriceClose(  );
    toast("send offer successfully".toString() , bgColor: Colors.green);
                          
  
}
  print(response.body);
Logger().e(response.statusCode);

  if (response.statusCode != 201 && response.statusCode != 409) {
    log('value:${response}');
    log('value.body:${response.body}');
      toast("Something went wrong".toString() , bgColor: Colors.red);
    // throw jsonDecode(response.body)['message'];
  }
}