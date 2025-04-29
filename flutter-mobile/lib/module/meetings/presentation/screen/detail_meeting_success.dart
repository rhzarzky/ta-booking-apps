import 'package:Appointly/module/meetings/presentation/widget/expanded_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/presentation/bloc/booking_bloc.dart';
import 'package:Appointly/core/common/main_tab_screen.dart';
import 'package:Appointly/module/meetings/model/booking_model.dart';
import 'package:Appointly/module/meetings/model/booking_detail_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class DetailMeetingSuccess extends StatefulWidget {
  final int bookingId;

  const DetailMeetingSuccess({
    super.key,
    required this.bookingId,
  });

  @override
  State<DetailMeetingSuccess> createState() => _DetailMeetingSuccessState();
}

class _DetailMeetingSuccessState extends State<DetailMeetingSuccess>
    with SingleTickerProviderStateMixin {
  DateTime? selectedDate;
  AnimationController? _controller;
  final TextEditingController _controllerText = TextEditingController();

  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _controller!.repeat(reverse: true);

    context
        .read<BookingBloc>()
        .add(BookAppointmentByIdEvent(idBooking: widget.bookingId));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is BookingLoaded) {
          final booking = state.bookingDetail!;
          return Scaffold(
            appBar: _buildAppBar(),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  _buildBackgroundImage(),
                  _buildContent(booking),
                ],
              ),
            ),
          );
        } else if (state is BookingFailure) {
          return Center(
            child: Text('Error: ${state.failure}'),
          );
        }
        return Center(
          child: Text('No booking details found'),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      elevation: 0.0,
      toolbarHeight: 8.0,
    );
  }

  Widget _buildBackgroundImage() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/image/service_dummy_card.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildContent(BookingDetail booking) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSection(booking),
          SizedBox(height: 24),
          _buildScheduleSection(booking),
          SizedBox(height: 16),
          _buildLocationWithStatus(booking),
          SizedBox(height: 16),
          // if (booking.service != null) _buildNoteSection(booking.note!),
          SizedBox(height: 16),
          _buildButtonSend(),
        ],
      ),
    );
  }

  Widget _buildTitleSection(BookingDetail booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          booking.service.title,
          style: GoogleFonts.ubuntu(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: ColorPallete.darkBlack,
          ),
        ),
        ExpandedText(
          text: booking.service.description,
          maxLine: 120,
        ),
      ],
    );
  }

  Widget _buildScheduleSection(BookingDetail booking) {
    String formattedDate = '';
    try {
      final date = DateTime.parse(booking.day);
      formattedDate = DateFormat('d MMMM yyyy').format(date);
    } catch (e) {
      formattedDate = 'Invalid date';
    }

    _logger.d(booking.day);
    _logger.d(booking.time);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule',
          style: GoogleFonts.ubuntu(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorPallete.darkBlack,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorPallete.concrete50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        width: 2, color: ColorPallete.backgroundBody),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/icons/icon-calendar.svg',
                          height: 20),
                      SizedBox(width: 8),
                      Text(
                        booking.day,
                        style: GoogleFonts.ubuntu(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: ColorPallete.darkBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        width: 2, color: ColorPallete.backgroundBody),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        booking.time,
                        style: GoogleFonts.ubuntu(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: ColorPallete.darkBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationWithStatus(BookingDetail booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location title
        Text(
          'Location',
          style: GoogleFonts.ubuntu(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorPallete.darkBlack,
          ),
        ),
        SizedBox(height: 8),
        // Container for both status and location
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorPallete.concrete50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Status section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      child: Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: ColorPallete.primaryColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12.0),
                            topRight: Radius.circular(12.0),
                            bottomRight: Radius.circular(0.0),
                            topLeft: Radius.circular(0.0),
                          ),
                        ),
                        child: Text(
                          booking.status,
                          style: GoogleFonts.ubuntu(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Location section
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: 12,
                  left: 12,
                  right: 12,
                  bottom: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (context) {
                            if (booking.option == 'Offline') {
                              return SvgPicture.asset(
                                'assets/icons/icon-location.svg',
                                height: 24,
                              );
                            } else if (booking.option == 'Online') {
                              return Icon(
                                Icons.wifi_tethering_rounded,
                                color: Colors.black,
                                size: 24,
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          },
                        ),
                        SizedBox(width: 8),
                        Text(
                          booking.option,
                          style: GoogleFonts.ubuntu(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: ColorPallete.darkBlack,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Container(
                        width: double.infinity,
                        height: 80,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ColorPallete.concrete50,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                final textToCopy = _controllerText.text;
                                if (textToCopy.isNotEmpty) {
                                  await Clipboard.setData(
                                      ClipboardData(text: textToCopy));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Copied!')),
                                  );
                                }
                              },
                              child: Text(
                                'Tap to copy: ${booking.option == 'Offline' ? booking.option ?? 'Online' : 'https://zoom.us/j/123456789'}',
                                style: TextStyle(
                                  color: ColorPallete.greySilverChalice,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoteSection(String note) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note',
          style: GoogleFonts.ubuntu(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorPallete.darkBlack,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorPallete.concrete50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            note,
            style: GoogleFonts.ubuntu(
              fontSize: 14,
              color: ColorPallete.darkBlack,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonSend() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
            gradient: ColorPallete.gradientPrimary,
            borderRadius: BorderRadius.circular(8)),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainTabScreen()),
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Back to Home',
            style: GoogleFonts.ubuntu(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
