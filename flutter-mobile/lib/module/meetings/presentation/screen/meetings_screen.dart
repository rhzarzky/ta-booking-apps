// ignore_for_file: depend_on_referenced_packages

import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/presentation/bloc/service_bloc.dart';
import 'package:Appointly/module/meetings/presentation/screen/history_meeting.dart';
import 'package:Appointly/module/meetings/presentation/widget/card_service.dart';
import 'package:Appointly/module/meetings/presentation/widget/search_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    context.read<ServiceBloc>().add(GetServiceEvent());
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
                    builder: (context) => HistoryMeetings(),
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
            CustomSearchBar(),
            SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<ServiceBloc, ServiceState>(
                builder: (context, state) {
                  if (state is ServiceLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is ServiceFailure) {
                    return Center(child: Text('Error: ${state.failure}'));
                  } else if (state is ServiceLoaded) {
                    return RefreshIndicator(
                      onRefresh: _refreshData,
                      child: ListView.builder(
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
                              onTap: () {},
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
