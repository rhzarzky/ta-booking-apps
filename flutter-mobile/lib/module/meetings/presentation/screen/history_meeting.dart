import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/model/booking_model.dart';
import 'package:Appointly/module/meetings/presentation/bloc/booking_bloc.dart';
import 'package:Appointly/module/meetings/presentation/bloc/review_bloc.dart';
import 'package:Appointly/module/meetings/presentation/bloc/review_event.dart';
import 'package:Appointly/module/meetings/presentation/bloc/review_state.dart';
import 'package:Appointly/module/meetings/presentation/screen/detail_meeting_success.dart';
import 'package:Appointly/module/meetings/presentation/widget/card_appointment.dart';
import 'package:Appointly/module/meetings/presentation/widget/filter_bottomsheet.dart';
import 'package:Appointly/module/meetings/repository/review_repository.dart';
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
  // Set untuk melacak service yang sudah di-review oleh user (berdasarkan service ID)
  Set<int> reviewedServiceIds = {};
  final ReviewRepository _reviewRepository = ReviewRepository();
  bool _isLoadingReviewedBookings = true;
  @override
  void initState() {
    super.initState();

    // Fetch bookings when screen loads
    context.read<BookingBloc>().add(GetBookingEvent());
    // Fetch reviews for the reviewed tab
    context.read<ReviewBloc>().add(GetAllReviewEvent());
    // Load reviewed services data
    _loadReviewedServicesFromServer();
  }

  // Load reviewed services from server based on reviews
  Future<void> _loadReviewedServicesFromServer() async {
    try {
      final reviews = await _reviewRepository.getAllReview();

      // Extract service IDs from reviews (since backend uses serviceId in bookingId field)
      final reviewedServiceIds = <int>{};
      for (final review in reviews) {
        if (review.bookingId > 0) {
          // bookingId now contains serviceId
          reviewedServiceIds.add(review.bookingId);
        }
      }

      if (mounted) {
        setState(() {
          this.reviewedServiceIds = reviewedServiceIds;
          _isLoadingReviewedBookings = false;
        });
      }

      // Also save to SharedPreferences for backup
      final prefs = await SharedPreferences.getInstance();
      final reviewedList =
          reviewedServiceIds.map((id) => id.toString()).toList();
      await prefs.setStringList('reviewed_services', reviewedList);
    } catch (e) {
      // Fallback to SharedPreferences if server fails      await _loadSavedStates();
      if (mounted) {
        setState(() {
          _isLoadingReviewedBookings = false;
        });
      }
    }
  }

  // Load saved states from SharedPreferences (fallback only)
  Future<void> _loadSavedStates() async {
    final prefs = await SharedPreferences.getInstance();

    // Load reviewed services (updated to use service IDs)
    final reviewedList = prefs.getStringList('reviewed_services') ?? [];

    final parsedIds = <int>{};
    for (final idStr in reviewedList) {
      try {
        final id = int.parse(idStr);
        if (id > 0) {
          // Only add valid IDs
          parsedIds.add(id);
        } else {
          print('DEBUG: Skipping invalid ID: $idStr');
        }
      } catch (e) {
        print(
            'DEBUG: Failed to parse ID from SharedPreferences: $idStr, error: $e');
      }
    }

    if (mounted) {
      setState(() {
        reviewedServiceIds = parsedIds;
      });
    }

    print(
        'DEBUG: Loaded reviewed services from SharedPreferences: $reviewedServiceIds');
  }

  // Save reviewed services to SharedPreferences
  Future<void> _saveReviewedServices() async {
    final prefs = await SharedPreferences.getInstance();
    final reviewedList = reviewedServiceIds.map((id) => id.toString()).toList();
    await prefs.setStringList('reviewed_services', reviewedList);
    print('Saved reviewed services: $reviewedServiceIds');
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
        case 'Reviwed':
          title = 'No Reviewed Meetings';
          message = 'Good news! You don\'t have any reviewed meetings.';
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

        // Debug logging for booking status
        print(
            'DEBUG: Booking ${booking.idBooking} status: "${booking.status}"');

        final DateTime bookingDate = DateTime.parse(booking.date);

        String formattedDate;
        try {
          formattedDate = DateFormat('EEE, d MMMM yyyy').format(bookingDate);
        } catch (e) {
          // Fallback format if localization isn't initialized
          formattedDate = DateFormat('yyyy-MM-dd').format(bookingDate);
        }

        // Check if the service has already been reviewed (using service ID instead of booking ID)
        final isReviewed = reviewedServiceIds.contains(booking.service.id);

        // Debug logging
        print(
            'DEBUG: Checking booking ${booking.idBooking} with service ID ${booking.service.id}');
        print('DEBUG: Current reviewedServiceIds set: $reviewedServiceIds');
        print('DEBUG: Is service ${booking.service.id} reviewed? $isReviewed');
        print('DEBUG: Booking status: ${booking.status}');
        print(
            'DEBUG: Is loading reviewed bookings? $_isLoadingReviewedBookings');

        // Check if booking status is completed (case-insensitive)
        final bool isCompleted = booking.status.toLowerCase() == 'completed';
        print('DEBUG: Is booking completed? $isCompleted');

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
            // Button "Review Now" - hanya muncul jika status "Completed", belum di-review, dan data sudah loaded
            reviewButton:
                !_isLoadingReviewedBookings && isCompleted && !isReviewed
                    ? () {
                        print(
                            'DEBUG: Opening review sheet for booking ${booking.idBooking}');
                        _bottomSheetReview(context, booking);
                      }
                    : null,
            // Button "Finished" - hanya muncul jika status "Approved"
            approveButton: booking.status.toLowerCase() == 'approved'
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
      length: 4,
      child: Column(
        children: [
          _buildTabBarHeader(),
          Expanded(
            child: TabBarView(
              children: [
                _buildAppointmentList(approved, 'Approved'),
                _buildAppointmentList(pending, 'Under Review'),
                _buildAppointmentList(declined, 'Declined'),
                _buildReviewedTab(),
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
          Tab(text: 'Reviewed'),
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
          onReviewSubmitted: (rating) async {
            print(
                'DEBUG: Review submitted callback triggered for booking ${booking.idBooking} with service ID ${booking.service.id}');

            // Add service to reviewed services set immediately for UI responsiveness
            setState(() {
              reviewedServiceIds.add(booking.service.id);
            });

            // Save to SharedPreferences
            await _saveReviewedServices();

            // Refresh reviewed services from server to ensure synchronization
            await _loadReviewedServicesFromServer();

            // Refresh reviews in the reviewed tab
            context.read<ReviewBloc>().add(GetAllReviewEvent());

            // Refresh booking list to update UI
            context.read<BookingBloc>().add(GetBookingEvent());

            print(
                'DEBUG: Review submitted for booking ${booking.idBooking} with service ID ${booking.service.id} and rating: $rating');
            print('DEBUG: Updated reviewedServiceIds set: $reviewedServiceIds');
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
              // Refresh booking list untuk menampilkan status terbaru dari server
              context.read<BookingBloc>().add(GetBookingEvent());

              // Load reviewed services to update the UI
              _loadReviewedServicesFromServer();

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

  Widget _buildReviewedTab() {
    return BlocBuilder<ReviewBloc, ReviewState>(
      builder: (context, state) {
        if (state is ReviewLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is GetAllReviewSuccess) {
          if (state.reviews.isEmpty) {
            return _emptyBooking(
              title: 'No Reviews Yet',
              message:
                  'You haven\'t submitted any reviews yet. Complete some meetings to start reviewing!',
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ReviewBloc>().add(GetAllReviewEvent());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.reviews.length,
              itemBuilder: (context, index) {
                final review = state.reviews[index];
                return _buildReviewCard(review);
              },
            ),
          );
        } else if (state is ReviewFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: ColorPallete.redCinnabar,
                ),
                SizedBox(height: 16),
                Text(
                  'Failed to load reviews',
                  style: GoogleFonts.ubuntu(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ColorPallete.darkBlack,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  state.error,
                  style: GoogleFonts.ubuntu(
                    fontSize: 14,
                    color: ColorPallete.darkGreySilver,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ReviewBloc>().add(GetAllReviewEvent());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPallete.primaryColor,
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }
        return _emptyBooking(
          title: 'No Reviews',
          message: 'Your reviews will appear here.',
        );
      },
    );
  }

  Widget _buildReviewCard(dynamic review) {
    return Card(
        margin: const EdgeInsets.only(bottom: 12.0),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan rating dan tanggal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: ColorPallete.secondColor,
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${review.rating ?? 0}',
                        style: GoogleFonts.ubuntu(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ColorPallete.darkBlack,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    review.createdAt?.toString().split(' ')[0] ?? '',
                    style: GoogleFonts.ubuntu(
                      fontSize: 12,
                      color: ColorPallete.darkGreySilver,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // Booking info
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorPallete.backgroundBody,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event,
                      color: ColorPallete.primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Booking #${review.bookingId}',
                      style: GoogleFonts.ubuntu(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ColorPallete.darkBlack,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            review.status?.color ?? ColorPallete.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        review.status?.displayName ?? 'Submitted',
                        style: GoogleFonts.ubuntu(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Comment jika ada
              if (review.comment != null && review.comment!.isNotEmpty) ...[
                SizedBox(height: 12),
                Text(
                  'Review:',
                  style: GoogleFonts.ubuntu(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorPallete.darkBlack,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  review.comment!,
                  style: GoogleFonts.ubuntu(
                    fontSize: 14,
                    color: ColorPallete.darkGreySilver,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ));
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
    print(
        'Booking details: ID=${widget.booking.idBooking}, Service ID=${widget.booking.service.id}');

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

      // Important: Use service.id instead of booking.idBooking
      // The API uses service ID for the review, not booking ID
      context.read<ReviewBloc>().add(
            SubmitReviewEvent(
              // Use service ID instead of booking ID
              bookingId: widget.booking.service.id,
              rating: selectedRating,
              comment: reviewController.text,
              userId: user.id,
            ),
          );
      print(
          'SubmitReviewEvent triggered successfully with service ID=${widget.booking.service.id}');
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
            borderRadius: const BorderRadius.only(
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
