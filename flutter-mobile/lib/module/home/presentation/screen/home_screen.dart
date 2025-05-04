import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/home/presentation/widget/chart_status.dart';
import 'package:Appointly/module/home/presentation/widget/recently_pending_card.dart';
import 'package:Appointly/module/home/presentation/widget/status_card.dart';
import 'package:Appointly/module/meetings/presentation/bloc/booking_bloc.dart';
import 'package:Appointly/module/meetings/presentation/screen/detail_meeting_success.dart';
import 'package:Appointly/module/auth/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';

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
                  const SizedBox(width: 12),
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
                  const SizedBox(width: 12),
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
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: StatusCard(
                        title: 'Loading',
                        count: 0,
                        timeRange: '30',
                        difference: 0,
                        startColor: ColorPallete.darkGreySilver,
                        endColor: ColorPallete.greySilverChalice,
                        iconAsset: 'assets/icons/calendar-check-white.svg',
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    Widget _builderPendingCard() {
      return BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BookingLoaded) {
            final recentPendingBookings = state.pending.length > 4
                ? state.pending.sublist(0, 4)
                : state.pending;

            if (recentPendingBookings.isEmpty) {
              return Center(
                child: Text(
                  'No pending appointments',
                  style: GoogleFonts.ubuntu(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: ColorPallete.darkGreySilver,
                  ),
                ),
              );
            }

            return ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recentPendingBookings.length,
              separatorBuilder: (context, index) => const SizedBox(width: 20),
              itemBuilder: (context, index) {
                final booking = recentPendingBookings[index];
                String formattedDate;
                try {
                  final bookingDate = DateTime.parse(booking.date);
                  formattedDate =
                      DateFormat('EEE, d MMMM yyyy').format(bookingDate);
                } catch (e) {
                  // Fallback format if parsing or formatting fails
                  formattedDate = booking.date;
                }
                return SizedBox(
                  width: 300,
                  child: RecentlyPendingCard(
                    imageCard: booking.service.image ?? "",
                    titleCard: booking.service.title,
                    descCard: booking.service.description,
                    dateCard: formattedDate,
                    locationCard: booking.option,
                    durationCard: booking.time,
                    linkCard: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailMeetingSuccess(
                            bookingId: booking.idBooking,
                          ),
                        ),
                      );
                    },
                    noteCard: booking.note ?? '',
                    statusCard: booking.status,
                  ),
                );
              },
            );
          }
          return Center(
            child: Text(
              'Could not load appointments',
              style: GoogleFonts.ubuntu(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: ColorPallete.darkGreySilver,
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: ColorPallete.backgroundBody,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: [
              header(),
              const SizedBox(height: 16),
              Text(
                'You’re back! $userName👋',
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
                  BlocBuilder<BookingBloc, BookingState>(
                    builder: (context, state) {
                      if (state is BookingLoaded) {
                        return Text(
                          '${state.stats['approved'] ?? 0} Approval Event${state.stats['approved'] != 1 ? 's' : ''}',
                          style: GoogleFonts.ubuntu(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: ColorPallete.primaryColor,
                          ),
                        );
                      }
                      return Text(
                        '0 Approval Events',
                        style: GoogleFonts.ubuntu(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: ColorPallete.primaryColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              statusCarousel(),
              const SizedBox(height: 32),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appointment Insights',
                        style: GoogleFonts.ubuntu(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: ColorPallete.darkBlack,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const ChartStatus(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0, left: 0, right: 0),
                    child: Text(
                      'Recent Appointments',
                      style: GoogleFonts.ubuntu(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: ColorPallete.darkBlack,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(
                      minHeight: 430, // Tinggi minimum
                      maxHeight: 535, // Tinggi maksimum
                    ),
                    child: _builderPendingCard(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
