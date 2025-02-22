import 'package:appointly/module/home/presentation/widget/chart_status.dart';
import 'package:appointly/module/home/presentation/widget/tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appointly/core/theme/color_pallete.dart';
import 'package:appointly/module/home/presentation/widget/status_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget header() {
      return Column(
        children: [
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/image/Logo.png',
              ),
              IconButton.filled(
                onPressed: () {},
                icon: SvgPicture.asset('assets/icons/icon-search.svg'),
                style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(12)),
                iconSize: 24,
                color: Colors.white,
              ),
            ],
          ),
        ],
      );
    }

    Widget statusCarousel() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            StatusCard(
              iconAsset: 'assets/icons/calendar-check-white.svg',
              title: 'Approved Event',
              count: 5,
              timeRange: '30',
              difference: 5,
              startColor: ColorPallete.primary400,
              endColor: ColorPallete.primaryDark,
            ),
            StatusCard(
              iconAsset: 'assets/icons/calendar-time-white.svg',
              title: 'Under Review',
              count: 0,
              timeRange: '30',
              difference: 0,
              startColor: ColorPallete.accent400,
              endColor: ColorPallete.accentDark,
            ),
            StatusCard(
              iconAsset: 'assets/icons/calendar-x-white.svg',
              title: 'Declined Event',
              count: 1,
              timeRange: '30',
              difference: -1,
              startColor: ColorPallete.greySilverChalice,
              endColor: ColorPallete.greySilverChalice950,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: ColorPallete.backgroundBody,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: [
              header(),
              SizedBox(height: 16),
              Text(
                'Welcome back User👋',
                style: GoogleFonts.ubuntu(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ColorPallete.darkBlack,
                ),
              ),
              Row(
                children: [
                  Text(
                    'You’ve got',
                    style: GoogleFonts.ubuntu(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: ColorPallete.darkBlack,
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    '4 Approval Event',
                    style: GoogleFonts.ubuntu(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: ColorPallete.greenMalachite,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              statusCarousel(),
              SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appointment Insights',
                        style: GoogleFonts.ubuntu(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: ColorPallete.darkBlack),
                      ),
                      ChartStatus(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              TabBarComp() // Add bottom padding if needed
            ],
          ),
        ),
      ),
    );
  }
}
