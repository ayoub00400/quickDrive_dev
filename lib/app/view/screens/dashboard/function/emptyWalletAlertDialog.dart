
  import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/Extensions/AppButtonWidget.dart';
import '../../../../utils/Extensions/app_common.dart';
import '../../../../utils/Images.dart';
import '../../../../utils/var/var_app.dart';

Widget emptyWalletAlertDialog() {
    return AlertDialog(
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(walletGIF, height: 150, fit: BoxFit.contain),
            SizedBox(height: 8),
            Text(language.lessWalletAmountMsg, style: primaryTextStyle(), textAlign: TextAlign.justify),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AppButtonWidget(
                    padding: EdgeInsets.zero,
                    color: Colors.red,
                    text: language.no,
                    textColor: Colors.white,
                    onTap: () {
                      Navigator.pop(Get.context!,  );
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: AppButtonWidget(
                    padding: EdgeInsets.zero,
                    text: language.yes,
                    onTap: () {
                      if (appStore.mHelpAndSupport != null) {
                        Navigator.pop(Get. context!);

                        launchUrl(Uri.parse(appStore.mHelpAndSupport!));
                      } else {
                        Navigator.pop(Get. context!);
                      }
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
