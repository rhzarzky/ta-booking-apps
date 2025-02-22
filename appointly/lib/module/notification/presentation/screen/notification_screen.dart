import 'package:appointly/core/theme/color_pallete.dart';
import 'package:appointly/module/notification/presentation/widget/empt_state.dart';
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Column(
          children: [
            Text(
              'Your Notifications',
              style: GoogleFonts.sourceSans3(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: ColorPallete.darkBlack),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          EmptyState(),
        ],
      ),
    );
  }
}
