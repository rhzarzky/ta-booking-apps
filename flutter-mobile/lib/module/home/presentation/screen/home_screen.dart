import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/home/presentation/screen/bookmark_screen.dart';
import 'package:Appointly/module/home/presentation/widget/chart_status_with_filter.dart';
import 'package:Appointly/module/home/presentation/widget/recently_pending_card.dart';
import 'package:Appointly/module/home/presentation/widget/status_card.dart';
import 'package:Appointly/module/meetings/presentation/bloc/booking_bloc.dart';
import 'package:Appointly/module/meetings/presentation/screen/detail_meeting_success.dart';
import 'package:Appointly/module/auth/repository/auth_repository.dart';
import 'package:Appointly/module/meetings/presentation/screen/history_meeting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final int bookingId;

  const HomeScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Logger _logger = Logger();
  final AuthRepository _authRepository = AuthRepository();
  String? userName;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    displayUserInfo();

    // Load data with current month and year
    final now = DateTime.now();
    context
        .read<BookingBloc>()
        .add(GetBookingEvent(month: now.month, year: now.year));

    // Simulate loading state for 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> displayUserInfo() async {
    final user = await _authRepository.getUserData();
    if (user != null && mounted) {
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
    // Wrap the entire content with Skeletonizer when loading
    return Scaffold(
      backgroundColor: ColorPallete.backgroundBody,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: BlocBuilder<BookingBloc, BookingState>(
            builder: (context, state) {
              final isLoadingState = state is BookingLoading || _isLoading;

              return Skeletonizer(
                enabled: isLoadingState,
                effect: ShimmerEffect(
                  baseColor: ColorPallete.greySilverChalice.withOpacity(0.2),
                  highlightColor: Colors.white,
                ),
                child: ListView(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildGreeting(),
                    _buildApprovalText(state),
                    const SizedBox(height: 16),
                    _buildStatusCarousel(state),
                    const SizedBox(height: 24),
                    _buildAppointmentInsights(),
                    const SizedBox(height: 20),
                    _buildRecentAppointments(),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookmarkScreen(),
                  ),
                );
              },
              icon: Icon(
                Icons.bookmark_outline_rounded,
                color: ColorPallete.darkBlack,
              ),
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

  Widget _buildGreeting() {
    return Text(
      'You`re back! ${userName ?? 'User'}👋',
      style: GoogleFonts.ubuntu(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ColorPallete.darkBlack,
      ),
    );
  }

  Widget _buildApprovalText(BookingState state) {
    return Row(
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
        Text(
          state is BookingLoaded
              ? '${state.stats['approved'] ?? 0} Approval Event${state.stats['approved'] != 1 ? 's' : ''}'
              : '0 Approval Events',
          style: GoogleFonts.ubuntu(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: ColorPallete.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCarousel(BookingState state) {
    if (state is BookingLoaded) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        child: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            children: [
              StatusCard(
                title: 'Approved Event',
                count: state.stats['approved'] ?? 0,
                timeRange: '30',
                difference: calculateDifference(state.stats['approved'] ?? 0),
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
                difference: calculateDifference(state.stats['pending'] ?? 0),
                startColor: ColorPallete.accent400,
                endColor: ColorPallete.accentDark,
              ),
              const SizedBox(width: 12),
              StatusCard(
                iconAsset: 'assets/icons/calendar-x-white.svg',
                title: 'Declined Event',
                count: state.stats['declined'] ?? 0,
                timeRange: '30',
                difference: calculateDifference(state.stats['declined'] ?? 0),
                startColor: ColorPallete.greySilverChalice,
                endColor: ColorPallete.greySilverChalice950,
              ),
            ],
          ),
        ),
      );
    } // Skeleton version of status cards
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
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

  Widget _buildAppointmentInsights() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: constraints.maxWidth,
              child: const ChartStatusWithFilter(),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRecentAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0.0, left: 0, right: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Appointments',
                style: GoogleFonts.ubuntu(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: ColorPallete.darkBlack,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryMeetingsWithProvider(
                        bookingId: widget.bookingId,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min, // Agar Row tidak mengambil lebar penuh
                  children: [
                    Text(
                      'See All',
                      style: GoogleFonts.ubuntu(
                        color: ColorPallete.primary400,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 4), // Jarak antara text dan icon
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: ColorPallete.primary400,
                      size: 16, // Sesuaikan ukuran icon
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 540, // Fixed height
          child: _buildPendingCards(),
        ),
      ],
    );
  }

  Widget _buildPendingCards() {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        return SizedBox(
          height: 530,
          child: _buildPendingListContent(state),
        );
      },
    );
  }

  Widget _buildPendingListContent(BookingState state) {
    if (state is BookingLoaded) {
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
            formattedDate = DateFormat('EEE, d MMMM yyyy').format(bookingDate);
          } catch (e) {
            formattedDate = booking.date;
          }
          return SizedBox(
            width: 300,
            child: RecentlyPendingCard(
              imageCard: booking.service.image ?? "",
              titleCard: booking.service.title,
              descCard: booking.service.description,
              dateCard: formattedDate,
              locationCard: booking.service.location,
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

    // Skeleton version
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 2,
      separatorBuilder: (context, index) => const SizedBox(width: 20),
      itemBuilder: (context, index) {
        return SizedBox(
          width: 300,
          child: RecentlyPendingCard(
            imageCard: "",
            titleCard: "Loading Appointment",
            descCard: "This is a placeholder description for the loading state",
            dateCard: "Mon, 1 January 2025",
            locationCard: "Location",
            durationCard: "00:00",
            linkCard: () {},
            noteCard: 'Loading notes...',
            statusCard: 'pending',
          ),
        );
      },
    );
  }
}
