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
  final int? initialTabIndex;
  const HistoryMeetings({
    super.key,
    required this.bookingId,
    this.initialTabIndex,
  });

  @override
  State<HistoryMeetings> createState() => _HistoryMeetingsState();
}

class HistoryMeetingsWithProvider extends StatelessWidget {
  final int bookingId;
  final int? initialTabIndex;

  const HistoryMeetingsWithProvider({
    super.key,
    required this.bookingId,
    this.initialTabIndex,
  });

  @override
  Widget build(BuildContext context) {
    return HistoryMeetings(
      bookingId: bookingId,
      initialTabIndex: initialTabIndex,
    );
  }
}

class _HistoryMeetingsState extends State<HistoryMeetings>
    with WidgetsBindingObserver {
  // Track which bookings have been reviewed (for button control only)
  // Multiple reviews are still allowed through other means
  Set<int> reviewedBookingIds = {};
  bool isLoadingReviewedBookings = true;
  bool _isRefreshing = false; // Prevent multiple concurrent refresh calls

  // Track completion timestamps untuk sorting yang lebih akurat
  Map<int, DateTime> completionTimestamps = {};

  @override
  void initState() {
    super.initState();

    // Add observer to listen for app lifecycle changes
    WidgetsBinding.instance
        .addObserver(this); // Load saved state first for immediate UI response
    _loadSavedStates();
    _loadCompletionTimestamps();

    // Fetch bookings when screen loads
    context.read<BookingBloc>().add(GetBookingEvent());
    // Fetch reviews for the reviewed tab
    context.read<ReviewBloc>().add(GetAllReviewEvent());
    // Load reviewed bookings to control button visibility (not to prevent multiple reviews)
    _loadReviewedBookingsFromServer();
  }

  @override
  void dispose() {
    // Remove observer when widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Reload reviewed bookings when app becomes active again
    if (state == AppLifecycleState.resumed) {
      print('DEBUG: ========== APP LIFECYCLE RESUMED ==========');
      print(
          'DEBUG: Current reviewedBookingIds before reload: $reviewedBookingIds');
      print('DEBUG: App resumed - reloading reviewed bookings state');
      _loadReviewedBookingsFromServer();
    }
  }

  // Manual refresh method that can be called when needed
  Future<void> refreshReviewedBookings() async {
    print('DEBUG: Manual refresh triggered');
    await _loadReviewedBookingsFromServer();
  }

  // Load reviewed bookings from server based on user reviews
  // This is used ONLY for button control, not to prevent multiple reviews
  Future<void> _loadReviewedBookingsFromServer() async {
    // Prevent multiple concurrent calls
    if (_isRefreshing) {
      print('DEBUG: Already refreshing reviewed bookings, skipping...');
      return;
    }

    _isRefreshing = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdString = prefs.getString('user_id');

      if (userIdString == null) {
        setState(() {
          isLoadingReviewedBookings = false;
        });
        return;
      }

      final reviewRepository = ReviewRepository();
      final reviews = await reviewRepository
          .getAllReview(); // Extract booking IDs from reviews (for button control only)
      final reviewedBookingIds = <int>{};
      print('DEBUG: ========== LOADING REVIEWED BOOKINGS ==========');
      print('DEBUG: Processing ${reviews.length} reviews from getAllReview()');

      for (int i = 0; i < reviews.length; i++) {
        final review = reviews[i];
        print(
            'DEBUG: Review $i: ID=${review.id}, ServiceId=${review.serviceId}, BookingId=${review.bookingId}');

        if (review.bookingId > 0) {
          reviewedBookingIds.add(review.bookingId);
          print(
              'DEBUG: Added booking ${review.bookingId} to reviewedBookingIds');
        } else {
          print('DEBUG: Skipped invalid bookingId: ${review.bookingId}');
        }
      }
      print(
          'DEBUG: Final reviewedBookingIds set from server: $reviewedBookingIds');
      print(
          'DEBUG: Current local reviewedBookingIds: ${this.reviewedBookingIds}');

      // Merge server data with local state to prevent losing recently reviewed bookings
      final mergedBookingIds = <int>{};
      mergedBookingIds.addAll(this.reviewedBookingIds); // Keep local state
      mergedBookingIds.addAll(reviewedBookingIds); // Add server state

      print('DEBUG: Merged reviewedBookingIds set: $mergedBookingIds');
      print('DEBUG: Bookings in this set will have HIDDEN review buttons');
      print('DEBUG: =============================================');
      if (mounted) {
        setState(() {
          this.reviewedBookingIds = mergedBookingIds;
          isLoadingReviewedBookings = false;
        });
      }

      // Save merged state to SharedPreferences for backup
      final reviewedList = mergedBookingIds.map((id) => id.toString()).toList();
      await prefs.setStringList('reviewed_bookings', reviewedList);

      print(
          'DEBUG: Saved reviewedBookingIds to SharedPreferences: $reviewedList');
      print(
          'DEBUG: Multiple reviews are still possible through other entry points');
      print('DEBUG: This tracking is ONLY for history screen button control');
    } catch (e) {
      print('Error loading reviewed bookings: $e');
      // Fallback to SharedPreferences
      await _loadSavedStates();
    } finally {
      _isRefreshing = false;
    }
  }

  // Load saved states from SharedPreferences as fallback
  Future<void> _loadSavedStates() async {
    print('DEBUG: ========== LOADING SAVED STATES ==========');
    final prefs = await SharedPreferences.getInstance();
    final reviewedList = prefs.getStringList('reviewed_bookings') ?? [];
    print(
        'DEBUG: Found saved reviewed bookings in SharedPreferences: $reviewedList');

    final parsedIds = <int>{};
    for (final idStr in reviewedList) {
      try {
        final id = int.parse(idStr);
        if (id > 0) {
          parsedIds.add(id);
          print('DEBUG: Loaded booking ID $id from SharedPreferences');
        }
      } catch (e) {
        print('Failed to parse ID from SharedPreferences: $idStr');
      }
    }

    print('DEBUG: Parsed booking IDs from SharedPreferences: $parsedIds');
    if (mounted) {
      setState(() {
        reviewedBookingIds = parsedIds;
        isLoadingReviewedBookings = false;
      });
      print('DEBUG: Updated local state with saved booking IDs');
    }
    print('DEBUG: ==========================================');
  } // Load completion timestamps dari SharedPreferences

  Future<void> _loadCompletionTimestamps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampsJson = prefs.getString('completion_timestamps');
      if (timestampsJson != null) {
        // Parse JSON manually
        final List<String> entries = timestampsJson.split(',');
        for (String entry in entries) {
          final parts = entry.split(':');
          if (parts.length == 2) {
            final bookingId = int.tryParse(parts[0]);
            final timestamp = int.tryParse(parts[1]);
            if (bookingId != null && timestamp != null) {
              completionTimestamps[bookingId] =
                  DateTime.fromMillisecondsSinceEpoch(timestamp);
            }
          }
        }
        print('DEBUG: Loaded completion timestamps: $completionTimestamps');
      }
    } catch (e) {
      print('DEBUG: Error loading completion timestamps: $e');
    }
  }

  // Save completion timestamps ke SharedPreferences
  Future<void> _saveCompletionTimestamps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampsString = completionTimestamps.entries
          .map((entry) => '${entry.key}:${entry.value.millisecondsSinceEpoch}')
          .join(',');
      await prefs.setString('completion_timestamps', timestampsString);
      print('DEBUG: Saved completion timestamps: $timestampsString');
    } catch (e) {
      print('DEBUG: Error saving completion timestamps: $e');
    }
  }

  // Save reviewed bookings to SharedPreferences
  Future<void> _saveReviewedBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final reviewedList = reviewedBookingIds.map((id) => id.toString()).toList();
    await prefs.setStringList('reviewed_bookings', reviewedList);
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: ========== BUILD METHOD CALLED ==========');
    print('DEBUG: Current reviewedBookingIds in build: $reviewedBookingIds');
    print('DEBUG: isLoadingReviewedBookings: $isLoadingReviewedBookings');
    print('DEBUG: ===========================================');

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
              completed: state.completed,
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
    } // Sort appointments berdasarkan tanggal, dengan yang terbaru di atas
    // Khusus untuk tab "Completed", urutkan berdasarkan waktu terbaru
    List<Booking> sortedAppointments = List.from(appointments);
    if (tabName == 'Completed') {
      // Untuk completed appointments, sort berdasarkan completion timestamp terbaru
      sortedAppointments.sort((a, b) {
        try {
          // Prioritas sorting:
          // 1. Jika ada completion timestamp, gunakan itu (paling akurat)
          // 2. Jika tidak, gunakan booking ID (yang lebih besar biasanya lebih baru)
          // 3. Fallback ke tanggal booking

          DateTime? timestampA = completionTimestamps[a.idBooking];
          DateTime? timestampB = completionTimestamps[b.idBooking];

          if (timestampA != null && timestampB != null) {
            // Kedua ada timestamp, sort berdasarkan timestamp (terbaru di atas)
            return timestampB.compareTo(timestampA);
          } else if (timestampA != null) {
            // Hanya A yang ada timestamp, A lebih prioritas
            return -1;
          } else if (timestampB != null) {
            // Hanya B yang ada timestamp, B lebih prioritas
            return 1;
          } else {
            // Kedua tidak ada timestamp, gunakan booking ID (yang lebih besar = lebih baru)
            int comparison = b.idBooking.compareTo(a.idBooking);

            // Jika ID sama (tidak mungkin), gunakan tanggal booking
            if (comparison == 0) {
              DateTime dateA = DateTime.parse(a.date);
              DateTime dateB = DateTime.parse(b.date);
              comparison = dateB.compareTo(dateA);
            }

            return comparison;
          }
        } catch (e) {
          print('DEBUG: Error sorting completed appointments: $e');
          return 0;
        }
      });

      print('DEBUG: ========== SORTED COMPLETED APPOINTMENTS ==========');
      for (int i = 0; i < sortedAppointments.length; i++) {
        final booking = sortedAppointments[i];
        final timestamp = completionTimestamps[booking.idBooking];
        print(
            'DEBUG: ${i + 1}. Booking ID: ${booking.idBooking} - Service: ${booking.service.title}');
        print(
            'DEBUG:    Completion Time: ${timestamp?.toString() ?? 'No timestamp'}');
        print('DEBUG:    Original Date: ${booking.date}');
      }
      print('DEBUG: =================================================');
    } else {
      // Untuk tab lainnya, urutkan berdasarkan tanggal booking (ascending)
      sortedAppointments.sort((a, b) {
        try {
          DateTime dateA = DateTime.parse(a.date);
          DateTime dateB = DateTime.parse(b.date);

          // Sort ascending untuk tab lainnya (meeting mendatang di atas)
          return dateA.compareTo(dateB);
        } catch (e) {
          return 0;
        }
      });
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sortedAppointments.length,
      itemBuilder: (context, index) {
        final booking =
            sortedAppointments[index]; // Debug logging for booking status
        print(
            'DEBUG: Booking ${booking.idBooking} status: "${booking.status}"');

        final DateTime bookingDate = DateTime.parse(booking.date);

        String formattedDate;
        try {
          formattedDate = DateFormat('EEE, d MMMM yyyy').format(bookingDate);
        } catch (e) {
          // Fallback format if localization isn't initialized
          formattedDate = DateFormat('yyyy-MM-dd').format(bookingDate);
        } // Check if the booking has already been reviewed (for button control only)
        final isReviewed = reviewedBookingIds.contains(booking.idBooking);

        // Check if booking status is completed (case-insensitive)
        final bool isCompleted = booking.status.toLowerCase() == 'completed';

        // Debug logging for booking tracking and button logic
        print('DEBUG: ==========================================');
        print('DEBUG: Processing booking ${booking.idBooking}');
        print('DEBUG: - Service ID: ${booking.service.id}');
        print('DEBUG: - Service Title: ${booking.service.title}');
        print('DEBUG: - Booking Status: ${booking.status}');
        print('DEBUG: - Current reviewedBookingIds: $reviewedBookingIds');
        print(
            'DEBUG: - Is booking ${booking.idBooking} already reviewed? $isReviewed');
        print('DEBUG: - Is booking completed? $isCompleted');
        print(
            'DEBUG: - Is loading reviewed bookings? $isLoadingReviewedBookings');
        print(
            'DEBUG: - Will show review button? ${!isLoadingReviewedBookings && isCompleted && !isReviewed}');
        print(
            'DEBUG: - Button logic: loading=false ✓ + completed=true ✓ + booking_not_reviewed=true ✓ = SHOW button');
        print('DEBUG: ==========================================');

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: CardAppointment(
            titleCard: booking.service.title,
            descCard: booking.service.description,
            dateCard: formattedDate,
            locationCard: booking.service.location,
            durationCard: booking.time,
            linkCard: () async {
              // Navigate to detail and refresh state when returning
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailMeetingSuccess(
                    bookingId: booking.idBooking,
                  ),
                ),
              );
              // Refresh reviewed bookings state when returning from detail screen
              print(
                  'DEBUG: Returning from detail screen - refreshing reviewed bookings state');
              await refreshReviewedBookings();
            },
            noteCard: booking.note ?? '', statusCard: booking.status,
            // Button "Review Now" - only show for completed bookings that haven't been reviewed
            reviewButton:
                !isLoadingReviewedBookings && isCompleted && !isReviewed
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
    List<Booking>? completed,
  }) {
    return DefaultTabController(
      length: 4,
      initialIndex: widget.initialTabIndex ?? 0,
      child: Column(
        children: [
          _buildTabBarHeader(),
          Expanded(
            child: TabBarView(
              children: [
                _buildAppointmentList(approved, 'Approved'),
                _buildAppointmentList(pending, 'Under Review'),
                _buildAppointmentList(declined, 'Declined'),
                _buildAppointmentList(completed ?? [], 'Completed'),
                //_buildReviewedTab(),
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
        isScrollable: true,
        tabs: [
          Tab(text: 'Approved'),
          Tab(text: 'Under Review'),
          Tab(text: 'Declined'),
          Tab(text: 'Completed'),
          // Tab(text: 'Reviewed'),
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
            print('DEBUG: ========== REVIEW SUBMITTED CALLBACK ==========');
            print('DEBUG: Review submitted for booking ${booking.idBooking}');
            print(
                'DEBUG: Booking ID being marked as reviewed: ${booking.idBooking}');
            print('DEBUG: Service ID: ${booking.service.id}');
            print('DEBUG: Service Title: ${booking.service.title}');
            print('DEBUG: Rating given: $rating');
            print(
                'DEBUG: reviewedBookingIds BEFORE adding: $reviewedBookingIds');

            // Add booking to reviewed bookings set immediately for UI responsiveness
            setState(() {
              reviewedBookingIds.add(booking.idBooking);
            });

            print(
                'DEBUG: reviewedBookingIds AFTER adding: $reviewedBookingIds');
            print(
                'DEBUG: Booking ${booking.idBooking} button will now be HIDDEN'); // Save to SharedPreferences immediately
            await _saveReviewedBookings();
            print('DEBUG: Saved reviewedBookingIds to SharedPreferences');

            // Refresh reviews in the reviewed tab
            context.read<ReviewBloc>().add(GetAllReviewEvent());

            // Refresh booking list to update UI
            context.read<BookingBloc>().add(GetBookingEvent());

            // Wait a bit for backend to process the review, then refresh from server
            print('DEBUG: Waiting for backend to process review...');
            await Future.delayed(Duration(seconds: 2));

            // Refresh reviewed bookings from server to ensure synchronization
            await _loadReviewedBookingsFromServer();
            print(
                'DEBUG: Refreshed reviewedBookingIds from server after delay');

            print(
                'DEBUG: UI refresh triggered - buttons will update based on new reviewedBookingIds');
            print('DEBUG: Only this specific booking will hide its button');
            print(
                'DEBUG: Other bookings with same service ID will keep their buttons');
            print('DEBUG: ============================================');
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
              print(
                  'DEBUG: Meeting ${booking.idBooking} marked as completed at ${DateTime.now()}');

              // Save completion timestamp untuk sorting yang akurat
              final completionTime = DateTime.now();
              completionTimestamps[booking.idBooking] = completionTime;
              _saveCompletionTimestamps();

              print(
                  'DEBUG: Saved completion timestamp for booking ${booking.idBooking}: $completionTime');

              // Refresh booking list untuk menampilkan status terbaru dari server
              context.read<BookingBloc>().add(GetBookingEvent());

              // Multiple reviews enabled - no need to load reviewed services

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
      print(
          'Using service ID: ${widget.booking.service.id}, booking ID: ${widget.booking.idBooking}');

      context.read<ReviewBloc>().add(
            SubmitReviewEvent(
              serviceId: widget.booking.service.id, // For API endpoint
              bookingId:
                  widget.booking.idBooking, // For tracking specific booking
              rating: selectedRating,
              comment: reviewController.text,
              userId: user.id,
            ),
          );
      print(
          'SubmitReviewEvent triggered successfully with service ID=${widget.booking.service.id}, booking ID=${widget.booking.idBooking}');
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
