// ignore_for_file: depend_on_referenced_packages

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

class MeetingsScreen extends StatefulWidget {
  final String userId;
  const MeetingsScreen({super.key, required this.userId});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen>
    with WidgetsBindingObserver {
  late ScrollController _scrollController;
  bool _isSearchBarVisible = true;

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
                      child: const HistoryMeetings(),
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
              child: _isSearchBarVisible ? CustomSearchBar() : SizedBox(),
            ),
            SizedBox(height: _isSearchBarVisible ? 16 : 0),
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
                                headService: 'Loading...',
                                descService: 'Loading...',
                                imageService: '',
                                timeService: [],
                                provideService: [],
                                onTap: () {},
                              ),
                            );
                          }),
                    );
                  } else if (state is ServiceFailure) {
                    return Center(child: Text('Error: ${state.failure}'));
                  } else if (state is ServiceLoaded) {
                    return RefreshIndicator(
                      onRefresh: _refreshData,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: state.services.length,
                        itemBuilder: (context, index) {
                          final service = state.services[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: CardService(
                              headService: service.title,
                              descService: service.description,
                              imageService: service.image,
                              timeService: service.days,
                              provideService: service.option,
                              onTap: () {
                                context
                                    .read<ServiceBloc>()
                                    .add(GetServiceIdEvent(id: service.id));

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailMeetingScreen(
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
                  return Center(child: Text('No Data Available'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
