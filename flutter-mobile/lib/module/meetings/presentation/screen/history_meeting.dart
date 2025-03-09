// ignore_for_file: depend_on_referenced_packages

import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/presentation/widget/card_appointment.dart';
import 'package:Appointly/module/meetings/presentation/widget/filter_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HistoryMeetings extends StatefulWidget {
  const HistoryMeetings({super.key});

  @override
  State<HistoryMeetings> createState() => _HistoryMeetingsState();
}

class _HistoryMeetingsState extends State<HistoryMeetings> {
  // Dummy data for demonstration
  final List<Map<String, String>> approvedAppointments = [
    {
      'title': 'Team Meeting',
      'description':
          'Discuss project updates Discuss project updates Discuss project updates Discuss project updates Discuss project updates Discuss project updates Discuss project updates',
      'date': '2023-10-15',
      'location': 'Conference Room A',
      'duration': '2 hours',
      'note': 'Bring your laptops',
      'status': 'Approved',
    },
    {
      'title': 'Client Call',
      'description': 'Discuss contract details',
      'date': '2023-10-16',
      'location': 'Online',
      'duration': '1 hour',
      'note': 'Prepare the contract draft',
      'status': 'Approved',
    },
  ];

  final List<Map<String, String>> pendingAppointments = [
    {
      'title': 'Interview',
      'description': 'Candidate screening',
      'date': '2023-10-17',
      'location': 'HR Office',
      'duration': '1.5 hours',
      'note': 'Review the resume beforehand',
      'status': 'Pending',
    },
  ];

  final List<Map<String, String>> rejectedAppointments = [
    {
      'title': 'Workshop',
      'description': 'Flutter workshop for beginners',
      'date': '2023-10-18',
      'location': 'Training Room',
      'duration': '3 hours',
      'note': 'Cancelled due to low attendance',
      'status': 'Rejected',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPallete.backgroundBody,
      appBar: _buildAppBar(context),
      body: _buildTabBar(),
    );
  }

  Widget _buildTabBar() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          _buildTabBarHeader(),
          Expanded(
            child: TabBarView(
              children: [
                _buildAppointmentList(approvedAppointments),
                _buildAppointmentList(pendingAppointments),
                _buildAppointmentList(rejectedAppointments),
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
          Tab(text: 'Pending'),
          Tab(text: 'Rejected'),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(List<Map<String, String>> appointments) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: CardAppointment(
            titleCard: appointment['title']!,
            descCard: appointment['description']!,
            dateCard: appointment['date']!,
            locationCard: appointment['location']!,
            durationCard: appointment['duration']!,
            linkCard: () {
              // Handle navigation or action when the card is tapped
              print('Appointment tapped: ${appointment['title']}');
            },
            noteCard: appointment['note']!,
            statusCard: appointment['status']!,
          ),
        );
      },
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
}
