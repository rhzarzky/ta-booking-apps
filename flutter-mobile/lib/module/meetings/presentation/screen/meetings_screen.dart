import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/presentation/bloc/service_bloc.dart';
import 'package:Appointly/module/meetings/presentation/screen/detail_meeting_screen.dart';
import 'package:Appointly/module/meetings/presentation/screen/history_meeting.dart';
import 'package:Appointly/module/meetings/presentation/widget/card_service.dart';
import 'package:Appointly/module/meetings/presentation/widget/search_bar.dart';
import 'package:Appointly/module/meetings/presentation/widget/empty_state_service.dart';
import 'package:Appointly/module/meetings/model/saved_service_model.dart';
import 'package:Appointly/module/meetings/repository/saved_service_repository.dart';
import 'package:Appointly/module/meetings/model/service_model.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:Appointly/module/meetings/presentation/bloc/review_bloc.dart';
import 'package:Appointly/module/meetings/presentation/bloc/review_event.dart';
import 'package:Appointly/module/meetings/presentation/bloc/review_state.dart';
import 'dart:async';
// Repository is already imported above

class MeetingsScreen extends StatefulWidget {
  final String userId;
  final int bookingId;
  const MeetingsScreen({
    super.key,
    required this.userId,
    required this.bookingId,
  });

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen>
    with WidgetsBindingObserver {
  late ScrollController _scrollController; //mengnotrol behavior scroll
  bool _isSearchBarVisible = true; // Menyimpan status visibilitas search bar
  String _searchQuery = ''; // Menyimpan query pencarian
  List<dynamic> _filteredResults = []; // Menyimpan hasil pencarian
  final _savedServiceRepository = SavedServiceRepository();

  // Map untuk menyimpan service reviews berdasarkan serviceId, untuk menghindari duplikasi fetch
  Map<int, Map<String, dynamic>> _serviceReviews = {};

  // Set untuk melacak serviceId yang sedang di-fetch untuk mencegah duplikasi
  Set<int> _fetchingServices = {};

  // Map untuk melacak multiple service requests dan responses
  Map<int, bool> _serviceRequestMap = {};

  // Timeout untuk request yang terlalu lama
  Map<int, Timer?> _requestTimers = {};

  // Set untuk melacak service yang sudah dijadwalkan untuk fetch
  Set<int> _scheduledServices = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollistener);
    _refreshData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance
        .removeObserver(this); //auto refresh saat app lifecycle berubah
    _scrollController.removeListener(_scrollistener);
    _scrollController.dispose();
    _cleanupTimers(); // Cleanup timers on dispose
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  void _scrollistener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isSearchBarVisible) {
        setState(() {
          _isSearchBarVisible = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isSearchBarVisible) {
        setState(() {
          _isSearchBarVisible = true;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    print('🔄 Refreshing data - clearing all caches...');
    _debugServiceState(); // Debug state sebelum clear    // Clear cache saat refresh untuk memastikan data fresh
    setState(() {
      _serviceReviews.clear();
      _fetchingServices.clear();
      _serviceRequestMap.clear();
      _scheduledServices.clear(); // Clear scheduled services too
    });

    // Cleanup timers
    _cleanupTimers();

    print('✅ All caches cleared, fetching fresh service data...');
    context.read<ServiceBloc>().add(GetServiceEvent());
    return Future.value();
  }

  // Method untuk memvalidasi data reviews
  bool _isValidReviewData(Map<String, dynamic>? reviewData) {
    if (reviewData == null) return false;
    return reviewData.containsKey('averageRating') &&
        reviewData.containsKey('totalReviews');
  }

  // Method untuk handle timeout
  // Mencegah request hang forever 🔒
  // Membersihkan tracking state 🧹
  void _handleRequestTimeout(int serviceId) {
    print('⏰ Request timeout for service $serviceId');
    if (mounted) {
      setState(() {
        _fetchingServices.remove(serviceId);
        _serviceRequestMap.remove(serviceId);
        _requestTimers.remove(serviceId);
      });
    } else {
      // Handle case when widget is not mounted
      _fetchingServices.remove(serviceId);
      _serviceRequestMap.remove(serviceId);
      _requestTimers.remove(serviceId);
    }

    // Reschedule this specific service for retry
    print('🔄 Rescheduling service $serviceId after timeout');
    _scheduleServiceReviewFetch(serviceId);
  }

  void _fetchServiceReviews(int serviceId) {
    // Hanya fetch jika belum ada data valid dan tidak sedang di-fetch
    if (!_isValidReviewData(_serviceReviews[serviceId]) &&
        !_fetchingServices.contains(serviceId)) {
      print('🔍 Fetching reviews for service $serviceId...');
      // Don't use setState during build phase - just modify the collections directly
      _fetchingServices.add(serviceId);
      _serviceRequestMap[serviceId] = true;

      // Set timeout untuk request = Jika lebih dari 10 detik belum selesai → trigger timeout handler
      _requestTimers[serviceId] = Timer(Duration(seconds: 10), () {
        _handleRequestTimeout(serviceId);
      });

      context
          .read<ReviewBloc>()
          .add(GetServiceReviewsEvent(serviceId: serviceId));
    } else {
      if (_isValidReviewData(_serviceReviews[serviceId])) {
        final cached = _serviceReviews[serviceId];
        print(
            '📦 Using cached reviews for service $serviceId: ${cached?['averageRating']} avg, ${cached?['totalReviews']} total');
      } else if (_fetchingServices.contains(serviceId)) {
        print('⏳ Already fetching reviews for service $serviceId...');
      }
    }
  }

  // New method to schedule review fetching safely
  void _scheduleServiceReviewFetch(int serviceId) {
    // Only schedule if not already scheduled or fetching
    if (!_scheduledServices.contains(serviceId) &&
        !_fetchingServices.contains(serviceId) &&
        !_isValidReviewData(_serviceReviews[serviceId])) {
      print('📅 Scheduling review fetch for service $serviceId');
      _scheduledServices.add(serviceId);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          print('⚡ Executing scheduled fetch for service $serviceId');
          _fetchServiceReviews(serviceId);
          _scheduledServices.remove(serviceId);
        }
      });
    } else {
      print(
          '⏭️ Skipping schedule for service $serviceId - already scheduled: ${_scheduledServices.contains(serviceId)}, fetching: ${_fetchingServices.contains(serviceId)}, has data: ${_isValidReviewData(_serviceReviews[serviceId])}');
    }
  }

  void _onSearch(String query, List<dynamic> filteredResults) {
    setState(() {
      _searchQuery = query;
      _filteredResults = filteredResults;
    });
  }

  void _onSaveService(Service service) async {
    final savedService = SavedServiceModel(
      id: service.id,
      title: service.title,
      description: service.description,
      image: service.image,
      location: service.location,
      option: service.option,
    );

    await _savedServiceRepository.saveService(savedService);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Service has been saved to your bookmarks'),
        backgroundColor: ColorPallete.primaryDark,
      ),
    );
  }

  // Method untuk mendapatkan cached review atau default values
  Map<String, dynamic> _getServiceReviewData(int serviceId) {
    // Coba ambil data review dari cache berdasarkan serviceId
    final cachedData = _serviceReviews[serviceId];
    if (_isValidReviewData(cachedData)) {
      return cachedData!;
    }

    // Return default values - ini akan tetap menampilkan service card
    // meskipun belum ada review data
    return {
      'averageRating': 0.0,
      'totalReviews': 0,
    };
  }

  // Method untuk mengecek apakah service memiliki actual review data (bukan default)
  bool _hasActualReviewData(int serviceId) {
    final cachedData = _serviceReviews[serviceId];
    if (!_isValidReviewData(cachedData)) return false;

    // Check if it has actual rating/review data
    final avgRating = cachedData!['averageRating'] as double;
    final totalReviews = cachedData['totalReviews'] as int;

    return avgRating > 0.0 || totalReviews > 0;
  }

  // Method untuk debug state
  void _debugServiceState() {
    print('🔍 Current Service Reviews State:');
    print('   - Cached services: ${_serviceReviews.keys.toList()}');
    print('   - Fetching services: ${_fetchingServices.toList()}');
    print('   - Request map: ${_serviceRequestMap.keys.toList()}');
    print('   - Scheduled services: ${_scheduledServices.toList()}');
  }

  // Method untuk memaksa fetch ulang reviews
  void _forceRefreshServiceReviews(List<int> serviceIds) {
    print('🔄 Force refreshing reviews for services: $serviceIds');
    for (int serviceId in serviceIds) {
      // Clear existing data for this service
      _serviceReviews.remove(serviceId);
      _fetchingServices.remove(serviceId);
      _serviceRequestMap.remove(serviceId);
      _scheduledServices.remove(serviceId);

      // Schedule fresh fetch
      _scheduleServiceReviewFetch(serviceId);
    }
  }

  // Method untuk cleanup timers
  void _cleanupTimers() {
    _requestTimers.values.forEach((timer) => timer?.cancel());
    _requestTimers.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPallete.backgroundBody,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        foregroundColor: Colors.white,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        shadowColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Meetings',
              style: GoogleFonts.sourceSans3(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ColorPallete.darkBlack,
              ),
            ),
            IconButton(
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
              icon: SvgPicture.asset('assets/icons/icon-history.svg'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SizedBox(height: 24),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: _isSearchBarVisible ? 56 : 0,
              child: _isSearchBarVisible
                  ? CustomSearchBar(
                      onSearch: _onSearch,
                      userId: widget.userId,
                      bookingId: widget.bookingId,
                    )
                  : SizedBox(),
            ),
            SizedBox(height: _isSearchBarVisible ? 24 : 0),
            Expanded(
              child: MultiBlocListener(
                listeners: [
                  BlocListener<ReviewBloc, ReviewState>(
                    listener: (context, state) {
                      print(
                          '🎭 ReviewBloc state changed: ${state.runtimeType}');

                      if (state is ReviewLoading) {
                        print('🔄 Review loading state detected');
                      } else if (state is GetServiceReviewsSuccess) {
                        // Gunakan service ID dari state untuk mapping yang tepat
                        final serviceId = state.serviceId;
                        final serviceReviews = state.serviceReviews;

                        // Validasi data yang masuk
                        if (serviceId > 0) {
                          print(
                              '🎯 Successfully fetched reviews for service $serviceId:');
                          print(
                              '   - Average Rating: ${serviceReviews.averageRating}');
                          print(
                              '   - Total Reviews: ${serviceReviews.totalReviews}');
                          print(
                              '   - Reviews Count: ${serviceReviews.reviews.length}');

                          if (mounted) {
                            setState(() {
                              _serviceReviews[serviceId] = {
                                'averageRating': serviceReviews.averageRating,
                                'totalReviews': serviceReviews.totalReviews,
                              };
                              _fetchingServices.remove(serviceId);
                              _serviceRequestMap.remove(serviceId);

                              // Cancel timeout timer
                              _requestTimers[serviceId]?.cancel();
                              _requestTimers.remove(serviceId);
                            });

                            print(
                                '✅ Successfully cached reviews for service $serviceId');
                            print(
                                '🔄 Current cached data: ${_serviceReviews[serviceId]}');
                          }
                        } else {
                          print('❌ Invalid service ID received: $serviceId');
                        }
                      } else if (state is ReviewFailure) {
                        // Handle error case - remove all pending requests
                        print('❌ Failed to fetch reviews: ${state.error}');
                        print('🔍 Error details: ${state.toString()}');

                        // Try to get service ID from error if available
                        // If ReviewFailure has serviceId property, use it
                        // Otherwise, clear all pending requests
                        if (mounted) {
                          setState(() {
                            // For now, clear all pending requests
                            // TODO: Improve this to only clear specific failed service
                            _fetchingServices.clear();
                            _serviceRequestMap.clear();
                          });
                        }

                        // Optionally, you can implement retry logic here
                        print('🔄 Will retry failed services in 5 seconds...');
                        Timer(Duration(seconds: 5), () {
                          if (mounted) {
                            final allServiceIds = _fetchingServices.toList();
                            if (allServiceIds.isNotEmpty) {
                              print(
                                  '🔄 Retrying failed services: $allServiceIds');
                              _forceRefreshServiceReviews(allServiceIds);
                            }
                          }
                        });
                      }
                    },
                  ),
                ],
                child: BlocBuilder<ServiceBloc, ServiceState>(
                  builder: (context, state) {
                    if (state is ServiceLoading) {
                      return Skeletonizer(
                        effect: ShimmerEffect(
                          baseColor: Colors.grey[200]!,
                          highlightColor: Colors.grey[100]!,
                          duration: Duration(seconds: 2),
                        ),
                        enabled: true,
                        child: ListView.builder(
                            itemCount: 7,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: CardService(
                                  headService: 'Loading Service',
                                  descService: 'Service description loading...',
                                  imageService: '',
                                  timeService: ['Monday'],
                                  locationService: '',
                                  provideService: ['Online'],
                                  onTap: () {},
                                  onSave: () {},
                                  rating: 0,
                                  review: 0,
                                ),
                              );
                            }),
                      );
                    } else if (state is ServiceFailure) {
                      return Center(child: Text('Error: ${state.failure}'));
                    } else if (state is ServiceLoaded) {
                      // Use the filtered results from the search widget if available
                      final filteredServices = _searchQuery.isEmpty
                          ? state.services
                          : _filteredResults.isNotEmpty
                              ? _filteredResults
                              : state.services.where((service) {
                                  final searchLower =
                                      _searchQuery.toLowerCase();
                                  return service.title
                                          .toLowerCase()
                                          .contains(searchLower) ||
                                      service.description
                                          .toLowerCase()
                                          .contains(searchLower) ||
                                      service.location
                                          .toLowerCase()
                                          .contains(searchLower) ||
                                      service.days.any((day) => day
                                          .toLowerCase()
                                          .contains(searchLower)) ||
                                      service.option.any((option) => option
                                          .toLowerCase()
                                          .contains(searchLower));
                                }).toList(); // Schedule a delayed check untuk services yang belum mendapat data
                      Timer(Duration(seconds: 3), () {
                        if (mounted) {
                          final servicesWithoutData = filteredServices
                              .where((service) =>
                                  !_isValidReviewData(
                                      _serviceReviews[service.id]) &&
                                  !_fetchingServices.contains(service.id) &&
                                  !_scheduledServices.contains(service.id))
                              .map((service) => service.id as int)
                              .toList();

                          if (servicesWithoutData.isNotEmpty) {
                            print(
                                '🔄 Retrying fetch for services without data: $servicesWithoutData');
                            _forceRefreshServiceReviews(servicesWithoutData);
                          }
                        }
                      });

                      if (filteredServices.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              EmptyStateService(),
                              Text(
                                'Try changing your search criteria',
                                style: GoogleFonts.sourceSans3(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: _refreshData,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: filteredServices.length,
                          itemBuilder: (context, index) {
                            final service = filteredServices[
                                index]; // Schedule fetching after the build is complete safely
                            _scheduleServiceReviewFetch(service.id);

                            // Gunakan method helper untuk mendapatkan data review yang konsisten
                            final reviewData =
                                _getServiceReviewData(service.id);
                            final averageRating =
                                reviewData['averageRating'].toDouble();
                            final totalReviews =
                                reviewData['totalReviews'] as int;

                            // Check jika ini adalah data asli atau default
                            final hasActualData =
                                _hasActualReviewData(service.id);

                            // Debug info dengan service ID yang spesifik
                            print(
                                '📊 Service ${service.id} (${service.title}): ${averageRating.toStringAsFixed(1)} stars, $totalReviews reviews${hasActualData ? ' (actual data)' : ' (default/loading)'}');
                            print(
                                '🔍 Has cached data: ${_isValidReviewData(_serviceReviews[service.id])}');
                            print(
                                '🔄 Is fetching: ${_fetchingServices.contains(service.id)}');
                            print(
                                '📅 Is scheduled: ${_scheduledServices.contains(service.id)}');

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: CardService(
                                headService: service.title,
                                descService: service.description,
                                imageService: service.image,
                                timeService: service.days,
                                locationService: service.location,
                                provideService: service.option,
                                onTap: () {
                                  context
                                      .read<ServiceBloc>()
                                      .add(GetServiceIdEvent(id: service.id));

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailMeetingScreenProvider(
                                          bookingId: widget.bookingId,
                                          serviceId: service.id,
                                          userId: widget.userId,
                                        ),
                                      ));
                                },
                                onSave: () => _onSaveService(service),
                                // Pastikan rating dan review menggunakan data yang konsisten
                                rating: averageRating.round(),
                                review: totalReviews,
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return Center(child: EmptyStateService());
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
