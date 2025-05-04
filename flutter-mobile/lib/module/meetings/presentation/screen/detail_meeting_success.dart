import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/presentation/bloc/booking_bloc.dart';
import 'package:Appointly/core/common/main_tab_screen.dart';
import 'package:Appointly/module/meetings/model/booking_detail_model.dart';
import 'package:Appointly/module/meetings/presentation/widget/expanded_text.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:Appointly/module/meetings/model/booking_detail_model.dart';

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
      duration: const Duration(milliseconds: 1000),
    );

    _controller!.repeat(reverse: true);

    // Delay the API call slightly to ensure the widget is fully mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<BookingBloc>()
          .add(BookAppointmentByIdEvent(idBooking: widget.bookingId));
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.white,
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return _buildSkeletonLoader();
          } else if (state is BookingLoaded && state.bookingDetail != null) {
            final booking = state.bookingDetail!;
            _logger.t(booking);
            return _buildContentWithData(booking);
          } else if (state is BookingFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load booking details : ${state.failure}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BookingBloc>().add(BookAppointmentByIdEvent(
                          idBooking: widget.bookingId, ));
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          // Default loading state when we don't have data yet
          return _buildSkeletonLoader();
        },
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    // Create a dummy booking detail for the skeleton
    final dummyBooking = BookingDetail(
      service: Service(
        id: 0,
        title: 'Loading...',
        description: 'Loading...',
        image: '',
        location: 'Loading...',
      ),
      option: 'Loading...',
      date: 'Loading...',
      time: 'Loading...',
      note: 'Loading...',
      status: 'Loading...',
    );

    // Return the same UI but wrapped in Skeletonizer
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
      ),
      child: _buildContentWithData(dummyBooking),
    );
  }

  Widget _buildContentWithData(BookingDetail booking) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildBackgroundImage(booking),
          _buildContent(booking),
        ],
      ),
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

  Widget _buildBackgroundImage(BookingDetail booking) {
    // Add null safety checks
    final hasImage =
        booking.service.image != null && booking.service.image!.isNotEmpty;

    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        image: hasImage
            ? DecorationImage(
                image: booking.service.image!.startsWith('http')
                    ? NetworkImage(booking.service.image!) as ImageProvider
                    : AssetImage(booking.service.image!) as ImageProvider,
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: (!hasImage)
          ? Image.asset(
              'assets/image/404page.png',
              fit: BoxFit.contain,
            )
          : null,
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
          // Add null safety check for note
          _buildNoteSection(booking.note ?? ''),
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
    _logger.d(booking.date);
    _logger.d(booking.time);

    // Add error handling for date parsing
    String formattedDate;
    try {
      final DateTime bookingDate = DateTime.parse(booking.date);
      formattedDate = DateFormat('EEE, d MMMM yyyy').format(bookingDate);
    } catch (e) {
      _logger.e("Error parsing date: ${booking.date}, $e");
      formattedDate = booking.date; // Fallback to raw date
    }

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
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      width: 2,
                      color: ColorPallete.backgroundBody,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/icons/icon-calendar.svg',
                          height: 20),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          formattedDate,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ubuntu(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: ColorPallete.darkBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      width: 2,
                      color: ColorPallete.backgroundBody,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time_rounded, size: 20),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          booking.time,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ubuntu(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: ColorPallete.darkBlack,
                          ),
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
    // Set text to copy based on location type
    final textToCopy = booking.option == 'Offline'
        ? booking.option ?? 'No location provided'
        : 'https://zoom.us/j/123456789';

    // Set the text controller value for copying
    _controllerText.text = textToCopy;

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
                                try {
                                  await Clipboard.setData(
                                      ClipboardData(text: textToCopy));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Copied!')),
                                  );
                                } catch (e) {
                                  _logger.e("Copy error: $e");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to copy')),
                                  );
                                }
                              },
                              child: Text(
                                'Tap to copy: $textToCopy',
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
            note.isNotEmpty ? note : 'No notes provided',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
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
