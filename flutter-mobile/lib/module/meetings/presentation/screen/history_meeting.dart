import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/model/booking_model.dart';
import 'package:Appointly/module/meetings/presentation/bloc/booking_bloc.dart';
import 'package:Appointly/module/meetings/presentation/bloc/review_bloc.dart';
import 'package:Appointly/module/meetings/presentation/bloc/review_event.dart';
import 'package:Appointly/module/meetings/presentation/bloc/review_state.dart';
import 'package:Appointly/module/meetings/presentation/screen/review_screen.dart';
import 'package:Appointly/module/meetings/presentation/screen/detail_meeting_success.dart';
import 'package:Appointly/module/meetings/presentation/widget/card_appointment.dart';
import 'package:Appointly/module/meetings/presentation/widget/filter_bottomsheet.dart';
import 'package:Appointly/module/meetings/repository/review_repository.dart';
import 'package:Appointly/module/meetings/repository/historyBooking_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Appointly/module/auth/repository/auth_repository.dart';

class HistoryMeetings extends StatefulWidget {
  final int bookingId;
  const HistoryMeetings({
    super.key,
    required this.bookingId,
  });

  @override
  State<HistoryMeetings> createState() => _HistoryMeetingsState();
}

class HistoryMeetingsWithProvider extends StatelessWidget {
  final int bookingId;

  const HistoryMeetingsWithProvider({
    super.key,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    return HistoryMeetings(bookingId: bookingId);
  }
}

class _HistoryMeetingsState extends State<HistoryMeetings> {
  // Set untuk melacak booking yang sudah di-approve oleh user
  Set<int> finishedBookings = {};
  // Set untuk melacak booking yang sudah di-review oleh user
  Set<int> reviewedBookings = {};

  @override
  void initState() {
    super.initState();
    // Load saved states
    _loadSavedStates();
    // Fetch bookings when screen loads
    context.read<BookingBloc>().add(GetBookingEvent());
  }

  // Load saved states from SharedPreferences
  Future<void> _loadSavedStates() async {
    final prefs = await SharedPreferences.getInstance();

    // Load finished bookings
    final finishedList = prefs.getStringList('finished_bookings') ?? [];
    setState(() {
      finishedBookings = finishedList.map((id) => int.parse(id)).toSet();
    });

    // Load reviewed bookings
    final reviewedList = prefs.getStringList('reviewed_bookings') ?? [];
    setState(() {
      reviewedBookings = reviewedList.map((id) => int.parse(id)).toSet();
    });

    print('Loaded finished bookings: $finishedBookings');
    print('Loaded reviewed bookings: $reviewedBookings');
  }

  // Save finished bookings to SharedPreferences
  Future<void> _saveFinishedBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final finishedList = finishedBookings.map((id) => id.toString()).toList();
    await prefs.setStringList('finished_bookings', finishedList);
    print('Saved finished bookings: $finishedBookings');
  }

  // Save reviewed bookings to SharedPreferences
  Future<void> _saveReviewedBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final reviewedList = reviewedBookings.map((id) => id.toString()).toList();
    await prefs.setStringList('reviewed_bookings', reviewedList);
    print('Saved reviewed bookings: $reviewedBookings');
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
        final DateTime bookingDate = DateTime.parse(booking.date);

        String formattedDate;
        try {
          formattedDate = DateFormat('EEE, d MMMM yyyy').format(bookingDate);
        } catch (e) {
          // Fallback format if localization isn't initialized
          formattedDate = DateFormat('yyyy-MM-dd').format(bookingDate);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: CardAppointment(
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
            isApproved:
                finishedBookings.contains(booking.idBooking) ? 'true' : 'false',
            reviewButton: booking.status.toLowerCase() == 'approved' &&
                    finishedBookings.contains(booking.idBooking)
                ? () {
                    _bottomSheetReview(context, booking);
                  }
                : null,
            linkViewReview: booking.status.toLowerCase() == 'approved'
                ? () {
                    _navigateToReviews(context, booking);
                  }
                : null,
            approveButton: booking.status.toLowerCase() == 'approved' &&
                    !finishedBookings.contains(booking.idBooking)
                ? () {
                    _showModalApprove(context, booking);
                  }
                : null,
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

  void _bottomSheetReview(BuildContext context, Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ReviewBottomSheet(
          booking: booking,
          onReviewSubmitted: (rating) {
            // Tambahkan booking ke set reviewed bookings
            setState(() {
              reviewedBookings.add(booking.idBooking);
            });
            // Save to SharedPreferences
            _saveReviewedBookings();
            print(
                'Review submitted for booking ${booking.idBooking} with rating: $rating');
          },
        );
      },
    );
  }

  void _showModalApprove(BuildContext context, Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return BlocListener<ReviewBloc, ReviewState>(
          listener: (context, state) {
            if (state is CompleteMeetingSuccess) {
              // Tambahkan booking ke set finished bookings
              setState(() {
                finishedBookings.add(booking.idBooking);
              });
              // Save to SharedPreferences
              _saveFinishedBookings();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Meeting marked as finished!'),
                  backgroundColor: ColorPallete.primaryColor,
                ),
              );
            } else if (state is ReviewFailure) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<ReviewBloc, ReviewState>(
            builder: (context, state) {
              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Mark as Finished',
                      style: GoogleFonts.ubuntu(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ColorPallete.darkBlack,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Mark this meeting as finished? You can then leave a review.',
                      style: GoogleFonts.ubuntu(
                        fontSize: 14,
                        color: ColorPallete.darkGreySilver,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: state is ReviewLoading
                                ? null
                                : () {
                                    Navigator.pop(context);
                                  },
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.ubuntu(
                                fontSize: 14,
                                color: ColorPallete.darkGreySilver,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: state is ReviewLoading
                                ? null
                                : () {
                                    // Trigger complete meeting event
                                    context.read<ReviewBloc>().add(
                                          CompleteMeetingEvent(
                                              bookingId: booking.idBooking),
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPallete.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: state is ReviewLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Mark Finished',
                                    style: GoogleFonts.ubuntu(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _navigateToReviews(BuildContext context, Booking booking) {
    // Navigate to reviews screen for this service
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReviewsScreen(),
      ),
    );
  }
}

class ReviewBottomSheet extends StatefulWidget {
  final Booking booking;
  final Function(int)? onReviewSubmitted;

  const ReviewBottomSheet({
    super.key,
    required this.booking,
    this.onReviewSubmitted,
  });

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  int selectedRating = 0;
  final TextEditingController reviewController = TextEditingController();

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    print(
        '_submitReview called with rating: $selectedRating, comment: ${reviewController.text}');

    try {
      // Get user ID from AuthRepository instead of SharedPreferences directly
      final AuthRepository authRepository = AuthRepository();
      final user = await authRepository.getUserData();

      print('User data from AuthRepository: $user');

      if (user == null || user.id == 0) {
        print('Error: User not found or invalid user ID');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: User not found. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('User ID: ${user.id}');
      print('Triggering SubmitReviewEvent...');
      // Trigger submit review event
      context.read<ReviewBloc>().add(
            SubmitReviewEvent(
              bookingId: widget.booking.idBooking,
              rating: selectedRating,
              comment: reviewController.text,
              userId: user.id,
            ),
          );
      print('SubmitReviewEvent triggered successfully');
    } catch (e) {
      print('Error in _submitReview: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting review: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReviewBloc, ReviewState>(
      listener: (context, state) {
        if (state is SubmitReviewSuccess) {
          // Call the callback to update parent state
          if (widget.onReviewSubmitted != null) {
            widget.onReviewSubmitted!(selectedRating);
          }
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Review submitted successfully!'),
              backgroundColor: ColorPallete.primaryColor,
            ),
          );
        } else if (state is ReviewFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: ColorPallete.redCinnabar,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      'Write Your Review',
                      style: GoogleFonts.ubuntu(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ColorPallete.darkBlack,
                      ),
                    ),
                    BlocBuilder<ReviewBloc, ReviewState>(
                      builder: (context, reviewState) {
                        final isEnabled =
                            selectedRating > 0 && reviewState is! ReviewLoading;
                        print(
                            'Button enabled: $isEnabled, selectedRating: $selectedRating, state: $reviewState');

                        return ElevatedButton(
                          onPressed: isEnabled
                              ? () {
                                  print(
                                      'Submit button pressed with rating: $selectedRating');
                                  _submitReview();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isEnabled
                                ? ColorPallete.primaryColor
                                : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: reviewState is ReviewLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: Colors.grey[300]),

              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Info
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 70,
                            height: 70,
                            child: (widget.booking.service.image != null &&
                                    widget.booking.service.image!.isNotEmpty)
                                ? widget.booking.service.image!
                                        .startsWith('http')
                                    ? Image.network(
                                        widget.booking.service.image!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                                    'assets/image/404page.png',
                                                    fit: BoxFit.cover),
                                      )
                                    : Image.asset(widget.booking.service.image!,
                                        fit: BoxFit.cover)
                                : Image.asset(
                                    'assets/image/404page.png',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.booking.service.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.booking.service.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 30),

                    // Rating Section
                    Row(
                      children: [
                        Text(
                          'Tap to Rate',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () {
                                print('Rating tapped: ${index + 1}');
                                setState(() {
                                  selectedRating = index + 1;
                                });
                                print(
                                    'Selected rating updated to: $selectedRating');
                              },
                              child: Container(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.star_rate_rounded,
                                  size: 32,
                                  color: index < selectedRating
                                      ? ColorPallete.primaryColor
                                      : Colors.grey[300],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),

                    SizedBox(height: 30),
                    // Review Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Review',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: reviewController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText: 'Optional',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
