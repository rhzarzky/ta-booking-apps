// ignore_for_file: depend_on_referenced_packages

import 'package:appointly/core/theme/color_pallete.dart';
import 'package:appointly/module/meetings/presentation/screen/detail_meeting_screen.dart';
import 'package:appointly/module/meetings/presentation/screen/history_meeting.dart';
import 'package:appointly/module/meetings/presentation/widget/card_service.dart';
import 'package:appointly/module/meetings/presentation/widget/search_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  final List<Map<String, dynamic>> serviceList = List.generate(
    5,
    (index) => {
      "imageService": 'assets/image/service_dummy_card.png',
      "headService": 'Service Electric 24/7 Available',
      "descService":
          'Offering electrical services for your home, large city, and everything in between.',
      "timeService": 'Fri 07 Feb, 2025',
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPallete.backgroundBody,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        foregroundColor: Colors.white,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Meetings',
              style: GoogleFonts.sourceSans3(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ColorPallete.darkBlack,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryMeetings(),
                  ),
                );
              },
              icon: SvgPicture.asset('assets/icons/icon-history.svg'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SizedBox(height: 24),
            CustomSearchBar(),
            SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: serviceList.length,
                itemBuilder: (context, index) {
                  final service = serviceList[index];
                  return CardService(
                    imageService: service['imageService'],
                    headService: service['headService'],
                    descService: service['descService'],
                    timeService: service['timeService'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailMeetingScreen(),
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) => SizedBox(
                  height: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
