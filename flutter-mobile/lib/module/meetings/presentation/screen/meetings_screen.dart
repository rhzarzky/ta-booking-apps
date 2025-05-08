import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/presentation/bloc/booking_bloc.dart';
import 'package:Appointly/module/meetings/presentation/bloc/service_bloc.dart';
import 'package:Appointly/module/meetings/presentation/screen/detail_meeting_screen.dart';
import 'package:Appointly/module/meetings/presentation/screen/history_meeting.dart';
import 'package:Appointly/module/meetings/presentation/widget/card_service.dart';
import 'package:Appointly/module/meetings/presentation/widget/search_bar.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:Appointly/module/meetings/presentation/widget/empty_state_service.dart';

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
  late ScrollController _scrollController;
  bool _isSearchBarVisible = true;
  String _searchQuery = '';
  List<dynamic> _filteredResults = [];

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
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_scrollistener);
    _scrollController.dispose();
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
    context.read<ServiceBloc>().add(GetServiceEvent());
    return Future.value();
  }

  void _onSearch(String query, List<dynamic> filteredResults) {
    setState(() {
      _searchQuery = query;
      _filteredResults = filteredResults;
    });
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
                    builder: (context) => BlocProvider.value(
                      value: context.read<BookingBloc>(),
                      child: HistoryMeetings(
                        bookingId: widget.bookingId,
                      ),
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
                                final searchLower = _searchQuery.toLowerCase();
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
                              }).toList();

                    if (filteredServices.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No services found',
                              style: GoogleFonts.sourceSans3(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
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
                          final service = filteredServices[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
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
                                      builder: (context) => DetailMeetingScreen(
                                        bookingId: widget.bookingId,
                                        serviceId: service.id,
                                        userId: widget.userId,
                                      ),
                                    ));
                              },
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
          ],
        ),
      ),
    );
  }
}
