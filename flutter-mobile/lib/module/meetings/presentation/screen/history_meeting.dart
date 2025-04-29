// ignore_for_file: depend_on_referenced_packages

import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/model/booking_model.dart';
import 'package:Appointly/module/meetings/presentation/bloc/booking_bloc.dart';
import 'package:Appointly/module/meetings/presentation/screen/detail_meeting_success.dart';
import 'package:Appointly/module/meetings/presentation/widget/card_appointment.dart';
import 'package:Appointly/module/meetings/presentation/widget/filter_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HistoryMeetings extends StatefulWidget {
  final int bookingId;
  const HistoryMeetings({
    super.key,
    required this.bookingId,
  });

  @override
  State<HistoryMeetings> createState() => _HistoryMeetingsState();
}

class _HistoryMeetingsState extends State<HistoryMeetings> {
  @override
  void initState() {
    super.initState();
    // Fetch bookings when screen loads
    context.read<BookingBloc>().add(GetBookingEvent());

    context
        .read<BookingBloc>()
        .add(BookAppointmentByIdEvent(idBooking: widget.bookingId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPallete.backgroundBody,
      appBar: _buildAppBar(context),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BookingLoaded) {
            return _buildTabBar(
              approved: state.approved,
              pending: state.pending,
              declined: state.declined,
            );
          } else if (state is BookingFailure) {
            return Center(child: Text(state.failure));
          }
          return const Center(child: Text('No bookings found'));
        },
      ),
    );
  }

  Widget _emptyBooking({required String title, required String message}) {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/image/not-found-history.png',
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Text(
                    title,
                    textAlign: TextAlign.start,
                    style: GoogleFonts.ubuntu(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: ColorPallete.darkBlack,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    message,
                    textAlign: TextAlign.start,
                    style: GoogleFonts.ubuntu(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: ColorPallete.darkGreySilver,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(List<Booking> appointments, String tabName) {
    if (appointments.isEmpty) {
      String title;
      String message;
      switch (tabName) {
        case 'Approved':
          title = 'No Approved Meetings';
          message =
              'You don\'t have any approved meetings yet. They will appear here once approved.';
          break;
        case 'Under Review':
          title = 'No Pending Meetings';
          message =
              'You don\'t have any meetings under review. Book a meeting to get started!';
          break;
        case 'Declined':
          title = 'No Declined Meetings';
          message = 'Good news! You don\'t have any declined meetings.';
          break;
        default:
          title = 'No Meetings Found';
          message = 'No meetings found in this category.';
      }
      return _emptyBooking(title: title, message: message);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final booking = appointments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: CardAppointment(
            titleCard: booking.service.title,
            descCard: booking.service.description,
            dateCard: booking.service.day,
            locationCard: booking.service.option,
            durationCard: booking.service.time,
            linkCard: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailMeetingSuccess(
                    bookingId: booking.service.id,
                  ),
                ),
              );
            },
            noteCard: '',
            statusCard: booking.service.status,
          ),
        );
      },
    );
  }

  Widget _buildTabBar({
    required List<Booking> approved,
    required List<Booking> pending,
    required List<Booking> declined,
  }) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          _buildTabBarHeader(),
          Expanded(
            child: TabBarView(
              children: [
                _buildAppointmentList(approved, 'Approved'),
                _buildAppointmentList(pending, 'Under Review'),
                _buildAppointmentList(declined, 'Declined'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarHeader() {
    return Container(
      color: Colors.white,
      child: TabBar(
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: ColorPallete.primaryColor,
            width: 4.0,
          ),
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(2),
            right: Radius.circular(2),
          ),
        ),
        labelColor: ColorPallete.primaryColor,
        unselectedLabelColor: ColorPallete.darkGreySilver,
        tabs: const [
          Tab(text: 'Approved'),
          Tab(text: 'Under Review'),
          Tab(text: 'Declined'),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => _navigateBack(context),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: ColorPallete.darkBlack,
            ),
          ),
          Text(
            'Your Meetings',
            style: GoogleFonts.sourceSans3(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: ColorPallete.darkBlack,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              FilterBottomSheet.show(context);
            },
            icon: SvgPicture.asset(
              'assets/icons/icon-filter.svg',
              width: 24,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateBack(BuildContext context) {
    Navigator.pop(context);
  }
}
