import 'package:flutter/material.dart';
import 'package:taxi_driver/main.dart';
import 'package:taxi_driver/app/utils/Common.dart';

import '../../utils/Extensions/app_common.dart';
import '../../utils/var/var_app.dart';

class WaitingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            emptyWidget(),
            SizedBox(height: 16),
            Text(
              language.userNotApproveMsg,
              style: primaryTextStyle(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
