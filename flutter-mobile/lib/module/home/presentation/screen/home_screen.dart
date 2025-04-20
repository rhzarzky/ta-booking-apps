import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/home/presentation/widget/chart_status.dart';
import 'package:Appointly/module/home/presentation/widget/status_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Appointly/module/auth/repository/auth_repository.dart';
import 'package:logger/logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Logger _logger = Logger();
  String? userName;
  final AuthRepository _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    displayUserInfo();
  }

  Future<void> displayUserInfo() async {
    final user = await _authRepository.getUserData();
    if (user != null) {
      setState(() {
        userName = user.name;
      });
    }
    _logger.d(userName);
  }

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

    Widget buildTabBarHeader() {
      return Container(
        color: Colors.white,
        child: TabBar(
          indicator: UnderlineTabIndicator(
            borderSide:
                BorderSide(color: ColorPallete.primaryColor, width: 4.0),
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(2),
              right: Radius.circular(2),
            ),
          ),
          labelColor: ColorPallete.primaryColor,
          unselectedLabelColor: ColorPallete.darkGreySilver,
          tabs: const [
            Tab(
              text: 'Approved',
            ),
            Tab(
              text: 'Under Review',
            ),
            Tab(
              text: 'Declined',
            ),
          ],
        ),
      );
    }

    Widget _buildApprovedTab() {
      return Center(
        child: Text(
          'Approved Events Tab',
          style: GoogleFonts.ubuntu(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: ColorPallete.darkGreySilver),
        ),
      );
    }

    Widget _buildUnderReviewTab() {
      return Center(
        child: Text(
          'Under Review Events Tab',
          style: GoogleFonts.ubuntu(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: ColorPallete.darkGreySilver),
        ),
      );
    }

    Widget _buildDeclinedTab() {
      return Center(
        child: Text(
          'Declined Events Tab',
          style: GoogleFonts.ubuntu(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: ColorPallete.darkGreySilver),
        ),
      );
    }

    Widget tabBar() {
      return DefaultTabController(
        length: 3,
        child: Column(
          children: [
            buildTabBarHeader(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildApprovedTab(),
                  _buildUnderReviewTab(),
                  _buildDeclinedTab(),
                ],
              ),
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
                'Welcome back $userName👋',
                style: GoogleFonts.ubuntu(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ColorPallete.darkBlack,
                ),
              ),
              Row(
                children: [
                  Text(
                    "You've got",
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                height: 300, // Tetapkan ketinggian untuk TabBarView
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: 16.0, bottom: 8.0, right: 16, left: 16),
                        child: Text(
                          'My Appointment',
                          style: GoogleFonts.ubuntu(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: ColorPallete.darkBlack,
                          ),
                        ),
                      ),
                      buildTabBarHeader(),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildApprovedTab(),
                            _buildUnderReviewTab(),
                            _buildDeclinedTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
