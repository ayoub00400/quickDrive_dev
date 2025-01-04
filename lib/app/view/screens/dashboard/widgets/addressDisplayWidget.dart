
  import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_driver/app/utils/Extensions/StringExtensions.dart';

import '../../../../utils/Colors.dart';
import '../../../../utils/Common.dart';
import '../../../../utils/Extensions/app_common.dart';

Widget addressDisplayWidget(
      {String? startAddress, String? endAddress, required LatLng startLatLong, required LatLng endLatLong}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.near_me, color: Colors.green, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text(startAddress ?? ''.validate(), style: primaryTextStyle(size: 14), maxLines: 2)),
            mapRedirectionWidget(latLong: LatLng(startLatLong.latitude.toDouble(), startLatLong.longitude.toDouble()))
          ],
        ),
        Row(
          children: [
            SizedBox(width: 8),
            SizedBox(
              height: 24,
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
        Row(
          children: [
            Icon(Icons.location_on, color: Colors.red, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text(endAddress ?? '', style: primaryTextStyle(size: 14), maxLines: 2)),
            SizedBox(width: 8),
            mapRedirectionWidget(latLong: LatLng(endLatLong.latitude.toDouble(), endLatLong.longitude.toDouble()))
          ],
        ),
      ],
    );
  }
