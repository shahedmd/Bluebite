import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'Mobile Custom Object/customwidget.dart';

class BlueBiteBottomNavbar extends StatelessWidget {
  const BlueBiteBottomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final themeColor = const Color(0xFF1976D2); // Blue theme color

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue.shade700],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildLogoAndAbout(themeColor),
                SizedBox(height: 20.h),
                buildLinks(),
                SizedBox(height: 20.h),
                buildSocialIcons(themeColor),
              
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(flex: 2, child: buildLogoAndAbout(themeColor)),
                Expanded(flex: 1, child: buildLinks()),
                Expanded(flex: 1, child: buildSocialIcons(themeColor)),
              ],
            ),
    );
  }}