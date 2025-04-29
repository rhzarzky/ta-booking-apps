import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/home/presentation/widget/chart_status.dart';
import 'package:Appointly/module/home/presentation/widget/status_card.dart';
import 'package:Appointly/module/meetings/presentation/bloc/booking_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Appointly/module/auth/repository/auth_repository.dart';
import 'package:logger/logger.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
    context.read<BookingBloc>().add(GetBookingEvent());
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

  int calculateDifference(int currentCount) {
    return currentCount > 0 ? currentCount - 0 : 0;
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
      return BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoaded) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  StatusCard(
                    title: 'Approved Event',
                    count: state.stats['approved'] ?? 0,
                    timeRange: '30',
                    difference:
                        calculateDifference(state.stats['approved'] ?? 0),
                    startColor: ColorPallete.primary400,
                    endColor: ColorPallete.primaryDark,
                    iconAsset: 'assets/icons/calendar-check-white.svg',
                  ),
                  StatusCard(
                    iconAsset: 'assets/icons/calendar-time-white.svg',
                    title: 'Under Review',
                    count: state.stats['pending'] ?? 0,
                    timeRange: '30',
                    difference:
                        calculateDifference(state.stats['pending'] ?? 0),
                    startColor: ColorPallete.accent400,
                    endColor: ColorPallete.accentDark,
                  ),
                  StatusCard(
                    iconAsset: 'assets/icons/calendar-x-white.svg',
                    title: 'Declined Event',
                    count: state.stats['declined'] ?? 0,
                    timeRange: '30',
                    difference:
                        calculateDifference(state.stats['declined'] ?? 0),
                    startColor: ColorPallete.greySilverChalice,
                    endColor: ColorPallete.greySilverChalice950,
                  ),
                ],
              ),
            );
          } else if (state is BookingLoading) {
            return Skeletonizer(
              enabled: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                      3,
                      (index) => StatusCard(
                            title: 'Loading',
                            count: 0,
                            timeRange: '30',
                            difference: 0,
                            startColor: ColorPallete.darkGreySilver,
                            endColor: ColorPallete.greySilverChalice,
                            iconAsset: 'assets/icons/calendar-check-white.svg',
                          )),
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    Widget buildTabBarHeader() {
      return Container(
        color: Colors.white,
        child: TabBar(
          indicator: UnderlineTabIndicator(
            borderSide:
                BorderSide(color: ColorPallete.primaryColor, width: 4.0),
            borderRadius: const BorderRadius.horizontal(
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

    return Scaffold(
      backgroundColor: ColorPallete.backgroundBody,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: BlocBuilder<BookingBloc, BookingState>(
            builder: (context, state) {
              return ListView(
                children: [
                  header(),
                  const SizedBox(height: 16),
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
                      const SizedBox(width: 8.0),
                      if (state is BookingLoaded)
                        Text(
                          '${state.stats['approved'] ?? 0} Approval Event${state.stats['approved'] != 1 ? 's' : ''}',
                          style: GoogleFonts.ubuntu(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: ColorPallete.greenMalachite,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  statusCarousel(),
                  const SizedBox(height: 32),
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(16))),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
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
                          const ChartStatus(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    height: 300, // Set height for TabBarView
                    child: DefaultTabController(
                      length: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
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
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
