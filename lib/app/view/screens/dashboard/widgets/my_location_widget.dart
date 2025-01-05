
  import 'package:flutter/material.dart';

import '../../../../utils/Colors.dart';

Widget myLocationWidget({void Function()? onTap}) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 30,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 600),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: primaryColor),
                ),
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.my_location_sharp,
                  color: primaryColor,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
