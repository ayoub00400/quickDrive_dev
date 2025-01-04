
  import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/AlertScreen.dart';
import '../../../../components/ExtraChargesWidget.dart';
import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../model/ExtraChargeRequestModel.dart';
import '../../../../model/FRideBookingModel.dart';
import '../../../../utils/Colors.dart';
import '../../../../utils/Common.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/Extensions/AppButtonWidget.dart';
import '../../../../utils/Extensions/ConformationDialog.dart';
import '../../../../utils/Extensions/app_common.dart';
import '../../../../utils/var/var_app.dart';
import '../function/checkRideCancel.dart';
import '../function/getCurrentRequest.dart';
import '../function/getNewRideReq.dart';
import '../function/init_dashboard.dart';
import '../function/rideRequestAccept.dart';
import '../function/sendTripPrice.dart';
import 'addressDisplayWidget.dart';
// Notice : This problem is on your default app also

import 'dart:async';



import 'package:get/get.dart';
// import 'package:just_audio/just_audio.dart';


import 'package:cloud_firestore/cloud_firestore.dart';



import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:flutter_mobx/flutter_mobx.dart';

import 'package:google_places_flutter/model/prediction.dart';


// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';



import 'package:google_maps_flutter/google_maps_flutter.dart';


import 'package:taxi_driver/app/view/screens/ChatScreen.dart';



import 'package:taxi_driver/app/utils/Extensions/StringExtensions.dart';

import 'package:taxi_driver/app/utils/Extensions/app_textfield.dart';

import 'package:taxi_driver/app/utils/Extensions/context_extensions.dart';
import 'package:taxi_driver/app/view/screens/dashboard/widgets/top_widget.dart';

import 'package:url_launcher/url_launcher.dart';

import 'bookingForView.dart';
import 'buttonWidget.dart';



 
 


 

GetBuilder<DashboardController> fetchRideView(BuildContext context) {
DashboardController _dashboardController=  Get.put(DashboardController());

    return GetBuilder<DashboardController>(
            init: DashboardController(),
            builder: ( controller) {
              return StreamBuilder<QuerySnapshot>(
                stream: _dashboardController.rideService.fetchRide(userId: sharedPref.getInt(USER_ID)),
                builder: (c, snapshot) {
                  if (snapshot.hasData) {
                    List<FRideBookingModel> data = snapshot.data!.docs
                        .map((e) => FRideBookingModel.fromJson(e.data() as Map<String, dynamic>))
                        .toList();
              
                    if (data.length == 2) {
                      //here old ride of this driver remove if completed and payment is done code set
              
                      _dashboardController.rideService.removeOldRideEntry(
                        userId: sharedPref.getInt(USER_ID),
                      );
                    }
              
                    if (data.length != 0) {
                      // rideCancelDetected = false;
                           controller.emitStateBool( "rideCancelDetected" , false);      
                      if (data[0].onStreamApiCall == 0) {
                        _dashboardController.rideService.updateStatusOfRide(rideID: data[0].rideId, req: {'on_stream_api_call': 1});
                        if (data[0].status == NEW_RIDE_REQUESTED) {
                          print("TEST1");
                          getNewRideReq(data[0].rideId);
                        } else {
                          print("TEST2");
                          getCurrentRequest();
                        }
                      }
                      if (controller.servicesListData == null &&
                          data[0].status == NEW_RIDE_REQUESTED &&
                          data[0].onStreamApiCall == 1) {
                        // reqCheckCounter++;
              
             controller.emitStateInt( "reqCheckCounter"  , _dashboardController.reqCheckCounter + 1);
              
                        if (controller.reqCheckCounter < 1) {
                         _dashboardController. rideService.updateStatusOfRide(rideID: data[0].rideId, req: {'on_stream_api_call': 0});
                        }
                      }
                      if ((controller.servicesListData != null &&
                              controller.servicesListData!.status != NEW_RIDE_REQUESTED &&
                              data[0].status == NEW_RIDE_REQUESTED &&
                              data[0].onStreamApiCall == 1) ||
                          (controller.servicesListData == null &&
                              data[0].status == NEW_RIDE_REQUESTED &&
                              data[0].onStreamApiCall == 1)) {
                        if (    controller.rideDetailsFetching != true) {
                          // rideDetailsFetching = true;
                 controller.emitStateBool( "rideDetailsFetching" , true) ;
              
                         _dashboardController. rideService.updateStatusOfRide(rideID: data[0].rideId, req: {'on_stream_api_call': 0});
                        }
                      }
              
                      if (controller.servicesListData != null) {
                        return controller.servicesListData!.status != null && controller.servicesListData!.status == NEW_RIDE_REQUESTED
                              ? Builder(builder: (context) {
                                  // if (sendPrice == true && countdown == 0)
                                  //   return SizedBox();
                                  double progress = controller. countdown / 60;
              
                                  return SizedBox.expand(
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
              
                                       controller. servicesListData != null && controller. duration >= 0
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(2 * defaultRadius),
                                                          topRight: Radius.circular(2 * defaultRadius)),
                                                    ),
                                                    child: SingleChildScrollView(
                                                      // controller: scrollController,
                                            
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          
                                                          Align(
                                                            alignment: Alignment.center,
                                                            child: Container(
                                                              margin: EdgeInsets.only(top: 16),
                                                              height: 6,
                                                              width: 60,
                                                              decoration: BoxDecoration(
                                                                  color: primaryColor,
                                                                  borderRadius: BorderRadius.circular(defaultRadius)),
                                                              alignment: Alignment.center,
                                                            ),
                                                          ),
                                                          SizedBox(height: 8),
                                                          Padding(
                                                            padding: EdgeInsets.only(left: 16),
                                                            child: Text(language.requests, style: primaryTextStyle(size: 18)),
                                                          ),
                                                          SizedBox(height: 8),
                                                          Padding(
                                                            padding: EdgeInsets.all(16),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    ClipRRect(
                                                                      borderRadius: BorderRadius.circular(defaultRadius),
                                                                      child: commonCachedNetworkImage(
                                                                          controller.servicesListData!.riderProfileImage.validate(),
                                                                          height: 35,
                                                                          width: 35,
                                                                          fit: BoxFit.cover),
                                                                    ),
                                                                    SizedBox(width: 12),
                                                                    Expanded(
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                              '${controller.servicesListData!.riderName.capitalizeFirstLetter()}',
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: boldTextStyle(size: 14)),
                                                                          SizedBox(height: 4),
                                                                          Text('${controller.servicesListData!.riderEmail.validate()}',
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: secondaryTextStyle()),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    if (controller.duration > 0)
                                                                      Container(
                                                                        decoration: BoxDecoration(
                                                                            color: primaryColor,
                                                                            borderRadius:
                                                                                BorderRadius.circular(defaultRadius)),
                                                                        padding: EdgeInsets.all(6),
                                                                        
                                                                        child: Text("${controller. duration}".padLeft(2, "0"),
                                                                            style: boldTextStyle(color: Colors.white)),
                                                                      )
                                                                  ],
                                                                ),
                                                                if (controller. estimatedTotalPrice != null && controller.estimatedDistance != null)
                                                                  Container(
                                                                    padding: EdgeInsets.symmetric(vertical: 8),
                                                                    decoration: BoxDecoration(
                                                                        color: !appStore.isDarkMode
                                                                            ? scaffoldColorLight
                                                                            : scaffoldColorDark,
                                                                        borderRadius: BorderRadius.all(radiusCircular(8)),
                                                                        border: Border.all(width: 1, color: dividerColor)),
                                                                    child: Row(
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      mainAxisSize: MainAxisSize.max,
                                                                      children: [
                                                                     
                                            
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                                          mainAxisSize: MainAxisSize.max,
                                                                          children: [
                                                                            Text('${language.distance}:',
                                                                                style: secondaryTextStyle(size: 16)),
                                                                            SizedBox(width: 4),
                                                                            Text('${controller.estimatedDistance} ${controller.distance_unit}',
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: boldTextStyle(size: 14)),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    width:   MediaQuery.of(context).size.width,
                                                                  ),
                                                                addressDisplayWidget(
                                                                    endLatLong: LatLng(
                                                                        controller.servicesListData!.endLatitude.toDouble(),
                                                                       controller. servicesListData!.endLongitude.toDouble()),
                                                                    endAddress: controller.servicesListData!.endAddress,
                                                                    startLatLong: LatLng(
                                                                       controller. servicesListData!.startLatitude.toDouble(),
                                                                        controller.servicesListData!.startLongitude.toDouble()),
                                                                    startAddress:controller. servicesListData!.startAddress),
                                                                Align(
                                                                  alignment: AlignmentDirectional.centerStart,
                                                                  child: Text(
                                                                    '${language.shipmentType}: ${controller.servicesListData!.shipmentType}',
                                                                    style: primaryTextStyle(),
                                                                    textAlign: TextAlign.start,
                                                                  ),
                                                                ),
                                                                if (controller.servicesListData != null &&
                                                                   controller. servicesListData!.otherRiderData != null)
                                                                  Divider(
                                                                    color: Colors.grey.shade300,
                                                                    thickness: 0.7,
                                                                    height: 8,
                                                                  ),
                                                                bookingForView( controller ),
                                                                SizedBox(height: 8),
                                                                (controller. countdown > 0)
                                                                    ? Stack(
                                                                        alignment: Alignment.center,
                                                                        children: [
                                                                          Container(
                                                                            width: MediaQuery.of(context).size.width,
                                                                            height: 48,
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(8),
                                                                              border: Border.all(
                                                                                  color: Colors.grey.withOpacity(0.5)),
                                                                              gradient: LinearGradient(
                                                                                colors: [
                                                                                  const Color(0xFF417CFF),
                                                                                  Colors.white
                                                                                ],
                                                                                stops: [progress, progress + 0.01],
                                                                                begin: Alignment.centerLeft,
                                                                                end: Alignment.centerRight,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Center(
                                                                            child: Text(
                                                                              'تم ارسال العرض (${controller. countdown}s)',
                                                                              style: boldTextStyle(
                                                                                size: 16,
                                                                                color: Colors.black, // Ensure text contrast
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : AppTextField(
                                                                        controller: _dashboardController. priceController,
                                                                        textFieldType: TextFieldType.PHONE,
                                                                        decoration: InputDecoration(
                                                                          hintText: language.enterPrice,
                                                                          hintStyle: primaryTextStyle(),
                                                                          contentPadding:
                                                                              EdgeInsets.symmetric(horizontal: 16),
                                                                          border: OutlineInputBorder(),
                                                                        ),
                                                                        inputFormatters: [
                                                                          FilteringTextInputFormatter.digitsOnly
                                                                        ],
                                                                      ),
                                                                SizedBox(height: 8),
                                                                GetBuilder<DashboardController>(
                                                                  init: DashboardController(),
                                                                  builder: (controller) {
                                                                    return Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child: inkWellWidget(
                                                                            onTap: () {
                                                                              showConfirmDialogCustom(
                                                                                  dialogType: DialogType.DELETE,
                                                                                  primaryColor: primaryColor,
                                                                                  title: language
                                                                                      .areYouSureYouWantToCancelThisRequest,
                                                                                  positiveText: language.yes,
                                                                                  negativeText: language.no,
                                                                                  context, onAccept: (v) {
                                                                                try {
                                                                                  // FlutterRingtonePlayer()
                                                                                  // .stop();
                                                                    
                                                                                  _dashboardController.timerData!.cancel();
                                                                                } catch (e) {}
                                                                    
                                                                                sharedPref.remove(IS_TIME2);
                                                                    
                                                                                sharedPref.remove(ON_RIDE_MODEL);
                                                                    
                                                                                rideRequestAccept(deCline: true);
                                                                              }).then(
                                                                                (value) {
                                                                                  _dashboardController. polyLines.clear();
                                                                     _dashboardController. update();
                                                                                  // setState;
                                                                                },
                                                                              );
                                                                            },
                                                                            child: Container(
                                                                              padding: EdgeInsets.symmetric(
                                                                                  vertical: 10, horizontal: 8),
                                                                              decoration: BoxDecoration(
                                                                                  borderRadius:
                                                                                      BorderRadius.circular(defaultRadius),
                                                                                  border: Border.all(color: Colors.red)),
                                                                              child: Text(language.decline,
                                                                                  style: boldTextStyle(color: Colors.red),
                                                                                  textAlign: TextAlign.center),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        if (!controller.sendPrice) SizedBox(width: 16),
                                                                        if (!controller.sendPrice)
                                                                          Expanded(
                                                                            child: AppButtonWidget(
                                                                              padding: EdgeInsets.symmetric(
                                                                                  vertical: 12, horizontal: 8),
                                                                              text: language.accept,
                                                                              shapeBorder: RoundedRectangleBorder(
                                                                                  borderRadius:
                                                                                      BorderRadius.circular(defaultRadius)),
                                                                              color: primaryColor,
                                                                              textStyle: boldTextStyle(color: Colors.white),
                                                                              onTap: () {
                                                                                if (controller.sendPrice == true) return;
                                                                                showConfirmDialogCustom(
                                                                                    primaryColor: primaryColor,
                                                                                    dialogType: DialogType.ACCEPT,
                                                                                    positiveText: language.yes,
                                                                                    negativeText: language.no,
                                                                                    title: language
                                                                                        .areYouSureYouWantToAcceptThisRequest,
                                                                                    context, onAccept: (v) {
                                                                                  if (double.tryParse(_dashboardController. priceController.text) ==
                                                                                      null) {
                                                                                    toast(language.pleaseEnterValidPrice);
                                                                    
                                                                                    return;
                                                                                  } else if (int.parse(_dashboardController. priceController.text) <
                                                                                     controller. estimatedTotalPrice) {
                                                                                    toast(
                                                                                        "${language.pleaseEnterPriceGreaterThan} ${printAmount(controller.estimatedTotalPrice.toStringAsFixed(2))}");
                                                                    
                                                                                    return;
                                                                                  }
                                                                    
                                                                                  try {
                                                                              
                                                                    
                                                                                  _dashboardController.  timerData!.cancel();
                                                                                  } catch (e) {}
                                                                    
                                                                                  
                                                                    
                                                                                  sendTripPrice(
                                                                                    price: _dashboardController. priceController.text,
                                                                                    rideId: controller.servicesListData!.id.toString(),
                                                                                  );
                                                                                });
                                                                              },
                                                                            ),
                                                                          ),
                                                                      ],
                                                                    );
                                                                  }
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox(),
                                        Observer(builder: (context) {
                                          return appStore.isLoading ? loaderWidget() : SizedBox();
                                        })
                                      ],
                                    ),
                                  );
                                })
                              : Positioned(
                                  bottom: 0,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(2 * defaultRadius),
                                          topRight: Radius.circular(2 * defaultRadius)),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(defaultRadius),
                                              child: commonCachedNetworkImage(controller.servicesListData!.riderProfileImage,
                                                  height: 48, width: 48, fit: BoxFit.cover),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('${controller.servicesListData!.riderName.capitalizeFirstLetter()}',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: boldTextStyle(size: 18)),
                                                  SizedBox(height: 4),
                                                  Text('${controller.servicesListData!.riderEmail.validate()}',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: secondaryTextStyle()),
                                                ],
                                              ),
                                            ),
                                            inkWellWidget(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) {
                                                    return AlertDialog(
                                                      contentPadding: EdgeInsets.all(0),
                                                      content: AlertScreen(
                                                          rideId:controller. servicesListData!.id,
                                                          regionId:controller. servicesListData!.regionId),
                                                    );
                                                  },
                                                );
                                              },
                                              child: chatCallWidget(Icons.sos),
                                            ),
                                            SizedBox(width: 8),
                                            inkWellWidget(
                                              onTap: () {
                                                launchUrl(Uri.parse('tel:${controller.servicesListData!.riderContactNumber}'),
                                                    mode: LaunchMode.externalApplication);
                                              },
                                              child: chatCallWidget(Icons.call),
                                            ),
                                            SizedBox(width: 8),
                                            inkWellWidget(
                                              onTap: () {
                                                if (controller. riderData == null || (controller.riderData != null && controller.riderData!.uid == null)) {
                                                  init();
              
                                                  return;
                                                }
              
                                                if (controller.riderData != null) {
                                                  launchScreen(
                                                      context,
                                                      ChatScreen(
                                                        userData: controller.riderData,
                                                        ride_id: _dashboardController. riderId,
                                                      ));
                                                }
                                              },
                                              child: chatCallWidget(Icons.chat_bubble_outline, data: controller.riderData),
                                            ),
                                          ],
                                        ),
                                        if (controller.estimatedTotalPrice != null && controller.estimatedDistance != null)
                                          Container(
                                            padding: EdgeInsets.symmetric(vertical: 8),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                               
              
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: [
                                                    Text('${language.distance}:', style: secondaryTextStyle(size: 16)),
                                                    SizedBox(width: 4),
                                                    Text('${controller.estimatedDistance} ${controller.distance_unit}',
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: boldTextStyle(size: 14)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            // width: context.width(),
                                             width:  MediaQuery.of(context).size.width,
                                          ),
                                        Divider(
                                          color: Colors.grey.shade300,
                                          thickness: 0.7,
                                          height: 4,
                                        ),
                                        SizedBox(height: 8),
                                        addressDisplayWidget(
                                            endLatLong: LatLng(controller.servicesListData!.endLatitude.toDouble(),
                                               controller. servicesListData!.endLongitude.toDouble()),
                                            endAddress: controller.servicesListData!.endAddress,
                                            startLatLong: LatLng(controller.servicesListData!.startLatitude.toDouble(),
                                               controller. servicesListData!.startLongitude.toDouble()),
                                            startAddress: controller.servicesListData!.startAddress),
                                        SizedBox(height: 8),
                                       controller. servicesListData!.status != NEW_RIDE_REQUESTED
                                            ? Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: controller.servicesListData!.status == IN_PROGRESS ? 0 : 8),
                                                child: bookingForView( controller ),
                                              )
                                            : SizedBox(),
                                        if (controller.servicesListData!.status == IN_PROGRESS &&
                                            controller.servicesListData != null &&
                                           controller. servicesListData!.otherRiderData != null)
              
                                   
              
                                          SizedBox(height: 8),
                                        if (controller.servicesListData!.status == IN_PROGRESS)
                                          if (appStore.extraChargeValue != null)
                                            Observer(builder: (context) {
                                              return Visibility(
                                                visible: int.parse(appStore.extraChargeValue!) != 0,
                                                child: inkWellWidget(
                                                  onTap: () async {
                                                    List<ExtraChargeRequestModel>? extraChargeListData =
                                                        await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.only(
                                                              topLeft: Radius.circular(defaultRadius),
                                                              topRight: Radius.circular(defaultRadius))),
                                                      context: context,
                                                      builder: (_) {
                                                        return Padding(
                                                          padding: EdgeInsets.only(
                                                              bottom: MediaQuery.of(context).viewInsets.bottom),
                                                          child: ExtraChargesWidget(data:controller. extraChargeList),
                                                        );
                                                      },
                                                    );
              
                                                    if (extraChargeListData != null) {
                                                      log("extraChargeListData   $extraChargeListData");
              
                                                      // extraChargeAmount = 0;
                controller.emitStateInt( "extraChargeAmount"  , 0); 
              
                                                     controller. extraChargeList.clear();
              
                                                      extraChargeListData.forEach((element) {
                controller.emitStateInt( "extraChargeAmount"  , controller. extraChargeAmount + element.value!); 
              
                                                        // extraChargeAmount = extraChargeAmount + element.value!;
              
                                                        // extraChargeList = extraChargeListData;
                        controller.extraChargeListChange( extraChargeListData);

                                                      });
                                                    }
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.only(bottom: 8),
              
                                                         
              
                                                        child: Container(
                                                       
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.max,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                           
                                                                GetBuilder<DashboardController>(
                                                                  init:  DashboardController(),
                                                                  builder: (controller) {
                                                                    return  controller.extraChargeAmount != 0 ?  Text(
                                                                        '${language.extraCharges} ${printAmount(controller.extraChargeAmount.toString())}',
                                                                        style: secondaryTextStyle(color: Colors.green)) : SizedBox.shrink();
                                                                  }
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                        buttonWidget( controller)
                                      ],
                                    ),
                                  ),
                                );
                      } else {
                        return SizedBox();
                      }
                    } else {
                      if (data.isEmpty) {
                        try {
                          // FlutterRingtonePlayer().stop();
              
                          if (_dashboardController.timerData != null) {
                           _dashboardController. timerData!.cancel();
                          }
                        } catch (e) {}
                      }
              
                      if (controller.servicesListData != null) {
                        checkRideCancel();
                      }
              
                      if (  _dashboardController.riderId != 0) {
                        // riderId = 0;
                controller..emitStateInt( "riderId" , 0) ;
              
                        try {
                          sharedPref.remove(IS_TIME2);
              
                       _dashboardController.   timerData!.cancel();
                        } catch (e) {}
                      }
              
                     controller. servicesListData = null;
              
                    controller.  polyLines.clear();
              
                      return SizedBox();
                    }
                  } else {
                    return snapWidgetHelper(
                      snapshot,
                      loadingWidget: loaderWidget(),
                    );
                  }
                },
              );
            }
          );
  }
  