import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/notification/presentation/widget/notification_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPallete.backgroundBody,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
        child: ListView.builder(
          cacheExtent: 500.0, 
          itemCount: 50, 
          itemBuilder: (context, index) {
            return NotificationItem(
              title: 'service electric 24/7',
              indicatorStatus:
                  index % 3 == 0 ? 'pending' : 'success', 
              timeStamp: '2 minutes ago',
              onTap: () {},
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      elevation: 0.0,
      title: Text(
        'Your Notifications',
        style: GoogleFonts.sourceSans3(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ColorPallete.darkBlack,
        ),
      ),
    );
  }
}
