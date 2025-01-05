//TODO:Hossam hadi kharajha fi widgets

  import 'package:flutter/services.dart';
import 'package:get/get.dart';
// Notice : This problem is on your default app also




// import 'package:just_audio/just_audio.dart';
 

import 'package:taxi_driver/app/utils/Extensions/StringExtensions.dart';




 

 

import '../../../../controller/dashboard/dashboard_controller.dart';
import '../../../../utils/Constants.dart';
import '../../../../utils/Extensions/app_common.dart';
import '../../../../utils/var/var_app.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../../../components/CancelOrderDialog.dart';
import '../../../../components/ExtraChargesWidget.dart';
import '../../../../model/ExtraChargeRequestModel.dart';
import '../../../../utils/Colors.dart';
import '../../../../utils/Common.dart';
import '../../../../utils/Extensions/AppButtonWidget.dart';
import '../../../../utils/Extensions/ConformationDialog.dart';
import '../function/cancelRequest.dart';
import '../function/cancelTimer.dart';
import '../function/completeRideRequest.dart';
import '../function/getUserLocation.dart';
import '../function/rideRequest.dart';

Widget buttonWidget(DashboardController controller ) {
DashboardController _dashboardController=  Get.put(DashboardController());

    if ( controller.servicesListData!.status == ACCEPTED) {
      cancelTimer();
    }
    return Row(
      children: [
        if ( controller.servicesListData!.status != IN_PROGRESS)
          Expanded(
            flex: 0,
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: AppButtonWidget(
                  text: language.cancel,
                  textColor: primaryColor,
                  color: Colors.white,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultRadius), side: BorderSide(color: primaryColor)),

                  onTap: () {
                    showModalBottomSheet(
                        context:Get. context!,
                        isScrollControlled: true,
                        isDismissible: false,
                        builder: (context) {
                          return CancelOrderDialog(onCancel: (reason) async {
                            Navigator.pop(context);

                            appStore.setLoading(true);

                            await cancelRequest(reason);

                            appStore.setLoading(false);
                          });
                        });
                  }),
            ),
          ),
        if ( controller.servicesListData!.status == IN_PROGRESS)
          Expanded(
            flex: 0,
            child: Padding(
              padding: EdgeInsets.all(4),
              child: AppButtonWidget(
                  child: Row(
                    children: [
                      Icon(
                        Icons.add,
                        size: 18,
                      ),
               
                    ],
                  ),

                  // width: MediaQuery.of(context).size.width,

                  text: language.extraFees,
                  textColor: primaryColor,
                  color: Colors.white,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultRadius), side: BorderSide(color: primaryColor)),

                  // color: Colors.grey,

                  // textStyle: boldTextStyle(color: Colors.white),

                  onTap: () async {
                    List<ExtraChargeRequestModel>? extraChargeListData = await showModalBottomSheet(
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(defaultRadius), topRight: Radius.circular(defaultRadius))),
                      context: Get.context!,
                      builder: (_) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: MediaQuery.of( Get.context!).viewInsets.bottom),
                          child: ExtraChargesWidget(data: controller.extraChargeList),
                        );
                      },
                    );

                    if (extraChargeListData != null) {
                      log("extraChargeListData   $extraChargeListData");

                      // extraChargeAmount = 0;
                _dashboardController.emitStateInt( "extraChargeAmount" , 0); 

                      controller.extraChargeList.clear();

                      extraChargeListData.forEach((element) {
                        // extraChargeAmount = extraChargeAmount + element.value!;
                _dashboardController.emitStateInt( "extraChargeAmount" ,   _dashboardController.extraChargeAmount + element.value!); 

                        // extraChargeList = extraChargeListData;
                        controller.extraChargeListChange( extraChargeListData);
                      });
                    }
                  }),
            ),
          ),
        GetBuilder<DashboardController>(
          init:  DashboardController(),
          builder: (  controller) {
            return Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: AppButtonWidget(
                  // width: MediaQuery.of(context).size.width,
            
                  text: buttonText(status:  controller.servicesListData!.status),
            
                  color: primaryColor,
            
                  textStyle: boldTextStyle(color: Colors.white),
            
                  onTap: () async {
                    if (await checkPermission()) {
                      if ( controller.servicesListData!.status == ACCEPTED) {
                        showConfirmDialogCustom(
                            primaryColor: primaryColor,
                            positiveText: language.yes,
                            negativeText: language.no,
                            dialogType: DialogType.CONFIRMATION,
                            title: language.areYouSureYouWantToArriving,
                            Get.context!, onAccept: (v) {
                          rideRequest(status: ARRIVING);
                        });
                      } else if ( controller.servicesListData!.status == ARRIVING) {
                        showConfirmDialogCustom(
                            primaryColor: primaryColor,
                            positiveText: language.yes,
                            negativeText: language.no,
                            dialogType: DialogType.CONFIRMATION,
                            title: language.areYouSureYouWantToArrived,
                            Get.context!, onAccept: (v) {
                          rideRequest(status: ARRIVED);
                        });
                      } else if ( controller.servicesListData!.status == ARRIVED) {
                       _dashboardController.  otpController.clear();
            
                        showDialog(
                          context: Get.context!,
                          barrierDismissible: false,
                          builder: (_) {
                            return AlertDialog(
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.enterOtp, style: boldTextStyle(), textAlign: TextAlign.center),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: inkWellWidget(
                                          onTap: () {
                                            Navigator.pop(Get.context!);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                                            child: Icon(Icons.close, size: 20, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Text(language.startRideAskOTP,
                                      style: secondaryTextStyle(size: 12), textAlign: TextAlign.center),
                                  SizedBox(height: 16),
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Center(
                                      child: Pinput(
                                        keyboardType: TextInputType.number,
            
                                        readOnly: false,
            
                                        autofocus: true,
            
                                        length: 4,
            
                                        onTap: () {},
            
                                        // onClipboardFound: (value) {
            
                                        // otpController.text=value;
            
                                        // },
            
                                        onLongPress: () {},
            
                                        cursor: Text(
                                          "|",
                                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                                        ),
            
                                        focusedPinTheme: PinTheme(
                                          width: 40,
                                          height: 44,
                                          textStyle: TextStyle(
                                            fontSize: 18,
                                          ),
                                          decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius: BorderRadius.all(Radius.circular(8)),
                                              border: Border.all(color: primaryColor)),
                                        ),
            
                                        toolbarEnabled: true,
            
                                        useNativeKeyboard: true,
            
                                        defaultPinTheme: PinTheme(
                                          width: 40,
                                          height: 44,
                                          textStyle: TextStyle(
                                            fontSize: 18,
                                          ),
                                          decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius: BorderRadius.all(Radius.circular(8)),
                                              border: Border.all(color: dividerColor)),
                                        ),
            
                                        isCursorAnimationEnabled: true,
            
                                        showCursor: true,
            
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            
                                        closeKeyboardWhenCompleted: false,
            
                                        enableSuggestions: false,
            
                                        autofillHints: [],
            
                                        controller: _dashboardController. otpController,
            
                                        onCompleted: (val) {
                                          // otpCheck = val;
                                           _dashboardController.emitStateString( "otpCheck" , val);
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  GetBuilder<DashboardController>(
                                    init:  DashboardController(),
                                    builder: (  controller) {
                                      return AppButtonWidget(
                                        width: MediaQuery.of(Get.context!).size.width,
                                        text: language.confirm,
                                        onTap: () {
                                          if (  controller. otpCheck == null || controller. otpCheck !=  controller.servicesListData!.otp) {
                                            return toast(language.pleaseEnterValidOtp);
                                          } else {
                                            Navigator.pop(Get.context!);
                                                  
                                            rideRequest(status: IN_PROGRESS);
                                          }
                                        },
                                      );
                                    }
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      } else if ( controller.servicesListData!.status == IN_PROGRESS) {
                        showConfirmDialogCustom(
                            primaryColor: primaryColor,
                            dialogType: DialogType.ACCEPT,
                            title: language.finishMsg,
                            Get.context!,
                            positiveText: language.yes,
                            negativeText: language.no, onAccept: (v) {
                          appStore.setLoading(true);
            
                          getUserLocation().then((value2) async {
                          controller.  totalDistance = calculateDistance(
                                double.parse( controller.servicesListData!.startLatitude.validate()),
                                double.parse( controller.servicesListData!.startLongitude.validate()),
                                _dashboardController.driverLocation!.latitude,
                                _dashboardController.driverLocation!.longitude);
            
                            await completeRideRequest();
                          });
                        });
                      }
                    }
                  },
                ),
              ),
            );
          }
        ),
      ],
    );
  }
