import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/presentation/bloc/booking_bloc.dart';
import 'package:Appointly/module/meetings/presentation/bloc/review_bloc.dart';
import 'package:Appointly/module/meetings/presentation/bloc/review_event.dart';
import 'package:Appointly/module/meetings/presentation/bloc/review_state.dart';
import 'package:Appointly/core/common/main_tab_screen.dart';
import 'package:Appointly/module/meetings/model/booking_detail_model.dart'
    as detail;
import 'package:Appointly/module/meetings/presentation/widget/expanded_text.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Appointly/module/meetings/model/booking_model.dart';
import 'package:Appointly/module/meetings/presentation/screen/visual_map.dart';
import 'package:Appointly/module/meetings/repository/service_repository.dart';
import 'package:Appointly/module/meetings/presentation/widget/calendar_sync_dialog.dart';

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
  final ServiceRepository _serviceRepository = ServiceRepository();

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
      _logger.d('Requesting booking details for ID: ${widget.bookingId}');
      if (widget.bookingId <= 0) {
        _logger.e('Invalid booking ID: ${widget.bookingId}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ID Pemesanan tidak valid'),
            backgroundColor: Colors.red,
          ),
        );
        // Kembalikan ke halaman sebelumnya jika ID tidak valid
        Future.delayed(Duration(seconds: 2), () {
          if (!mounted) return;

          Navigator.pop(context);
        });
        return;
      }
      // fetch data secara langsung dari initstate
      context
          .read<BookingBloc>()
          .add(BookAppointmentByIdEvent(idBooking: widget.bookingId));

      // Review will be fetched after booking details are loaded
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
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          // When booking is loaded, fetch the review
          if (state is BookingLoaded && state.bookingDetail != null) {
            final booking = state.bookingDetail!;
            // Get current user ID from shared preferences or auth repository
            _fetchReviewForBooking(booking);
          }
        },
        builder: (context, state) {
          if (state is BookingLoading) {
            return _buildSkeletonLoader();
          } else if (state is BookingLoaded && state.bookingDetail != null) {
            final booking = state.bookingDetail!;
            _logger.t(booking);
            return _buildContentWithData(booking);
          } else if (state is BookingLoaded && state.bookingDetail == null) {
            // Jika BookingLoaded tetapi bookingDetail null
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tidak bisa memuat detail janji temu.',
                    style: GoogleFonts.ubuntu(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorPallete.darkBlack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BookingBloc>().add(BookAppointmentByIdEvent(
                            idBooking: widget.bookingId,
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPallete.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Coba Lagi'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainTabScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: ColorPallete.darkBlack,
                    ),
                    child: Text('Kembali ke Beranda'),
                  ),
                ],
              ),
            );
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
                            idBooking: widget.bookingId,
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPallete.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Coba Lagi'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainTabScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: ColorPallete.darkBlack,
                    ),
                    child: Text('Kembali ke Beranda'),
                  ),
                ],
              ),
            );
          }
          return _buildSkeletonLoader();
        },
      ),
    );
  }

  void _fetchReviewForBooking(detail.BookingDetail booking) async {
    try {
      // Fetch all reviews for the service instead of just user's review
      context.read<ReviewBloc>().add(
            GetServiceReviewsEvent(
              serviceId: booking.service.id,
            ),
          );
    } catch (e) {
      _logger.e('Error fetching service reviews: $e');
    }
  }

  // Google Calendar Integration Methods
  Future<void> _handleCalendarSync(detail.BookingDetail booking) async {
    try {
      // Show loading dialog for calendar sync
      CalendarSyncLoadingDialog.show(context);

      try {
        // Parse date and time from booking
        final bookingDate = DateTime.parse(booking.date);

        // Create calendar event
        final calendarSuccess = await _serviceRepository.createCalendarEvent(
          serviceTitle: booking.service.title,
          serviceDescription: booking.service.description,
          bookingDate: bookingDate,
          bookingTime: booking.time,
          location: booking.option.toLowerCase() == 'online'
              ? 'Online Meeting'
              : booking.service.location ?? 'Location not specified',
          meetingUrl: booking.option.toLowerCase() == 'online'
              ? 'Meeting URL akan diberikan sebelum appointment'
              : null,
        );

        // Hide loading dialog
        if (mounted) {
          CalendarSyncLoadingDialog.hide(context);

          if (calendarSuccess) {
            CalendarSyncMessages.showSuccess(context);
          } else {
            CalendarSyncMessages.showError(context);
          }
        }
      } catch (calendarError) {
        // Hide loading dialog
        if (mounted) {
          CalendarSyncLoadingDialog.hide(context);

          // Check specific error types
          String errorMessage = 'Gagal sync ke calendar';
          if (calendarError.toString().contains('Permission calendar')) {
            errorMessage =
                calendarError.toString().replaceAll('Exception: ', '');

            // Show dialog for permission settings if permanently denied
            if (calendarError.toString().contains('permanen')) {
              _showPermissionDialog();
              return;
            }
          } else if (calendarError.toString().contains('Authentication')) {
            errorMessage = 'Gagal login ke Google Account. Silakan coba lagi.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      _logger.e('Error in calendar sync: $e');
      if (mounted) {
        CalendarSyncLoadingDialog.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan saat sync ke calendar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Show permission dialog when calendar permission is permanently denied
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: ColorPallete.primaryColor,
            ),
            SizedBox(width: 8),
            Text(
              'Calendar Permission',
              style: GoogleFonts.ubuntu(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorPallete.darkBlack,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Untuk sync appointment ke Google Calendar, izinkan akses calendar di pengaturan aplikasi.',
              style: GoogleFonts.ubuntu(
                fontSize: 14,
                color: ColorPallete.darkBlack,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Settings > Apps > Appointly > Permissions > Calendar',
              style: GoogleFonts.ubuntu(
                fontSize: 12,
                color: ColorPallete.darkGreySilver,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Nanti',
              style: GoogleFonts.ubuntu(
                color: ColorPallete.darkGreySilver,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Open app settings (implementation depends on platform)
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPallete.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Buka Settings',
              style: GoogleFonts.ubuntu(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    final dummyBooking = detail.BookingDetail(
      service: detail.Service(
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

  Widget _buildContentWithData(detail.BookingDetail booking) {
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
      leading: IconButton(
        onPressed: () {
          context.read<BookingBloc>().add(GetBookingEvent());
          Navigator.pop(context);
        },
        icon: Icon(
          Icons.arrow_back_rounded,
          color: ColorPallete.darkBlack,
        ),
      ),
      title: Text(
        'Detail Appointment',
        style: GoogleFonts.ubuntu(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ColorPallete.darkBlack,
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(detail.BookingDetail booking) {
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
                image: booking.service.image!.isNotEmpty
                    ? NetworkImage(booking.service.image!) as ImageProvider
                    : const AssetImage('assets/image/404page.png'),
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

  Widget _buildContent(detail.BookingDetail booking) {
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
          _buildNoteSection(booking.note ?? ''), SizedBox(height: 16),
          _buildReviewSection(booking),
          SizedBox(
              height:
                  16), // Show Google Calendar section only for approved and completed bookings
          if (booking.status.toLowerCase() == 'approved' ||
              booking.status.toLowerCase() == 'completed') ...[
            _buildGoogleCalendarSection(booking),
            SizedBox(height: 16),
          ],
          if (booking.option == 'Online') ...[
            Column(
              children: [
                _buildButtonSend(booking),
                const SizedBox(height: 16),
              ],
            )
          ] else if (booking.option == 'Offline') ...[
            Row(
              children: [
                _buildButtonSend(booking),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildVisualMapButton(context, booking),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildTitleSection(detail.BookingDetail booking) {
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

  Widget _buildScheduleSection(detail.BookingDetail booking) {
    _logger.d(booking.date);
    _logger.d(booking.time);

    // Add error handling for date parsing
    String formattedDate;
    try {
      final DateTime bookingDate = DateTime.parse(booking.date);
      formattedDate = DateFormat('EEE, d MMMM yyyy').format(bookingDate);
    } catch (e) {
      _logger.e("Error parsing date: ${booking.date}, $e");
      formattedDate = booking.date;
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

  Widget _buildLocationWithStatus(detail.BookingDetail booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
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
          child: Column(
            children: [
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
                    SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 80,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ColorPallete.concrete50,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: InkWell(
                        onTap: () async {
                          final url = booking.service.location;
                          if (url != null && url.isNotEmpty) {
                            try {
                              // Check if the URL has a scheme, if not add https://
                              final parsedUrl = url.startsWith('http://') ||
                                      url.startsWith('https://')
                                  ? url
                                  : 'https://$url';

                              if (await canLaunchUrl(Uri.parse(parsedUrl))) {
                                await launchUrl(
                                  Uri.parse(parsedUrl),
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                throw 'Could not launch $parsedUrl';
                              }
                            } catch (e) {
                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Could not open URL: $e')),
                              );
                              _logger.e("URL launch error: $e");
                            }
                          }
                        },
                        child: Text(
                          'Tap to open: ${booking.service.location}',
                          style: TextStyle(
                            color: ColorPallete.greySilverChalice,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
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
            note.isNotEmpty ? note : 'You have no notes',
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

  Widget _buildReviewSection(detail.BookingDetail booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews & Ratings',
          style: GoogleFonts.ubuntu(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorPallete.darkBlack,
          ),
        ),
        SizedBox(height: 8),
        BlocBuilder<ReviewBloc, ReviewState>(
          builder: (context, state) {
            if (state is ReviewLoading) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorPallete.concrete50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ColorPallete.primaryColor,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Loading reviews...',
                      style: GoogleFonts.ubuntu(
                        fontSize: 14,
                        color: ColorPallete.darkGreySilver,
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is GetServiceReviewsSuccess) {
              final serviceReviews = state.serviceReviews;

              if (serviceReviews.reviews.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorPallete.concrete50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        color: ColorPallete.greySilverChalice,
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No reviews yet',
                        style: GoogleFonts.ubuntu(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorPallete.darkBlack,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Be the first to review this service',
                        style: GoogleFonts.ubuntu(
                          fontSize: 12,
                          color: ColorPallete.darkGreySilver,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ColorPallete.concrete50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Rating Summary
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Average Rating
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    serviceReviews.averageRating
                                        .toStringAsFixed(1),
                                    style: GoogleFonts.ubuntu(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: ColorPallete.darkBlack,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.star,
                                    color: ColorPallete.secondColor,
                                    size: 24,
                                  ),
                                ],
                              ),
                              Text(
                                '${serviceReviews.totalReviews} review${serviceReviews.totalReviews > 1 ? 's' : ''}',
                                style: GoogleFonts.ubuntu(
                                  fontSize: 14,
                                  color: ColorPallete.darkGreySilver,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          // Star Rating Display
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    Icons.star,
                                    size: 20,
                                    color: index <
                                            serviceReviews.averageRating.round()
                                        ? ColorPallete.secondColor
                                        : ColorPallete.greySilverChalice,
                                  );
                                }),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Average Rating',
                                style: GoogleFonts.ubuntu(
                                  fontSize: 12,
                                  color: ColorPallete.darkGreySilver,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Reviews List
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: 300, // Limit height to prevent overflow
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: serviceReviews.reviews.length > 3
                            ? 3 // Show only first 3 reviews
                            : serviceReviews.reviews.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: ColorPallete.backgroundBody,
                        ),
                        itemBuilder: (context, index) {
                          final review = serviceReviews.reviews[index];
                          return Container(
                            padding: EdgeInsets.all(16),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // User info and rating
                                Row(
                                  children: [
                                    // User avatar (placeholder)
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor:
                                          ColorPallete.primaryColor,
                                      child: Text(
                                        review.userName?.isNotEmpty == true
                                            ? review.userName!
                                                .substring(0, 1)
                                                .toUpperCase()
                                            : 'U',
                                        style: GoogleFonts.ubuntu(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            review.userName ?? 'Anonymous User',
                                            style: GoogleFonts.ubuntu(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: ColorPallete.darkBlack,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              // Rating stars
                                              Row(
                                                children: List.generate(5,
                                                    (starIndex) {
                                                  return Icon(
                                                    Icons.star,
                                                    size: 14,
                                                    color: starIndex <
                                                            (review.rating ?? 0)
                                                        ? ColorPallete
                                                            .secondColor
                                                        : ColorPallete
                                                            .greySilverChalice,
                                                  );
                                                }),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                '${review.rating ?? 0}/5',
                                                style: GoogleFonts.ubuntu(
                                                  fontSize: 12,
                                                  color: ColorPallete
                                                      .darkGreySilver,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Review date
                                    if (review.createdAt != null)
                                      Text(
                                        _formatReviewDate(review.createdAt!),
                                        style: GoogleFonts.ubuntu(
                                          fontSize: 11,
                                          color: ColorPallete.darkGreySilver,
                                        ),
                                      ),
                                  ],
                                ),

                                // Review comment
                                if (review.comment != null &&
                                    review.comment!.isNotEmpty) ...[
                                  SizedBox(height: 8),
                                  Text(
                                    review.comment!,
                                    style: GoogleFonts.ubuntu(
                                      fontSize: 13,
                                      color: ColorPallete.darkBlack,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Show more reviews button if there are more than 3 reviews
                    if (serviceReviews.reviews.length > 3)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            // TODO: Navigate to all reviews page
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('All reviews page coming soon'),
                              ),
                            );
                          },
                          child: Text(
                            'View all ${serviceReviews.totalReviews} reviews',
                            style: GoogleFonts.ubuntu(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ColorPallete.primaryColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            } else if (state is ReviewFailure) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorPallete.concrete50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: ColorPallete.redCinnabar,
                      size: 24,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Failed to load reviews',
                      style: GoogleFonts.ubuntu(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorPallete.darkBlack,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      state.error,
                      style: GoogleFonts.ubuntu(
                        fontSize: 12,
                        color: ColorPallete.darkGreySilver,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // Retry fetching service reviews
                        context.read<ReviewBloc>().add(
                              GetServiceReviewsEvent(
                                serviceId: booking.service.id,
                              ),
                            );
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          color: ColorPallete.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Default state - no review yet
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorPallete.concrete50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    color: ColorPallete.greySilverChalice,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Loading reviews...',
                    style: GoogleFonts.ubuntu(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ColorPallete.darkBlack,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildButtonSend(detail.BookingDetail booking) {
    final bool isOnline = booking.option == 'Online';

    return Container(
      width: !isOnline ? 64 : double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: ColorPallete.primaryDark,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside),
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainTabScreen()),
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPallete.backgroundBody,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.home_filled,
              color: ColorPallete.primaryDark,
              size: 24,
            ),
            if (isOnline) ...[
              const SizedBox(width: 8),
              Text(
                'Back to Home',
                style: GoogleFonts.ubuntu(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ColorPallete.primaryDark,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVisualMapButton(
      BuildContext context, detail.BookingDetail booking) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // visual map hanya membutuhkan 1 booking spesifik untuk ditampilkan di map yaitu approved booking
              //Logic: Karena user sedang melihat detail 1 booking yang sudah approved, maka: Hanya approved array yang diisi
              //Array lain kosong karena tidak relevan
              builder: (context) => VisualMap(
                booking: BookingModel(
                    status: booking.status,
                    message: '',
                    user: User(id: 0, name: '', email: ''),
                    services: Bookings(pending: [], approved: [
                      Booking(
                        idBooking: widget.bookingId,
                        service: ServiceBooking(
                          id: booking.service.id,
                          title: booking.service.title,
                          description: booking.service.description,
                          location: booking.service.location ?? '',
                          image: booking.service.image,
                        ),
                        option: booking.option,
                        date: booking.date,
                        time: booking.time,
                        note: booking.note,
                        status: booking.status,
                      )
                    ], declined: [], completed: [])),
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            gradient: ColorPallete.gradientPrimary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lihat di Maps',
                style: GoogleFonts.ubuntu(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.near_me_sharp,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatReviewDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return DateFormat('MMM d, yyyy').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildGoogleCalendarSection(detail.BookingDetail booking) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPallete.concrete50),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: ColorPallete.primaryColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Add to Google Calendar',
                style: GoogleFonts.ubuntu(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ColorPallete.darkBlack,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Appointment yang sudah approved dapat ditambahkan ke Google Calendar dengan reminder otomatis.',
            style: GoogleFonts.ubuntu(
              fontSize: 14,
              color: ColorPallete.darkBlack.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await _handleCalendarSync(booking);
              },
              icon: Icon(
                Icons.add_to_photos,
                size: 18,
                color: Colors.white,
              ),
              label: Text(
                'Tambahkan ke Calendar',
                style: GoogleFonts.ubuntu(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPallete.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),          
        ],
      ),
    );
  }
}
