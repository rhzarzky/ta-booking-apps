import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/presentation/screen/field_location_offline.dart';
import 'package:Appointly/module/meetings/presentation/widget/inperson_field_option.dart';
import 'package:Appointly/module/meetings/presentation/widget/success_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DetailMeetingScreen extends StatefulWidget {
  const DetailMeetingScreen({super.key});

  @override
  State<DetailMeetingScreen> createState() => _DetailMeetingScreenState();
}

class _DetailMeetingScreenState extends State<DetailMeetingScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Stack(
            children: [
              _buildBackgroundImage(),
              _buildBackButton(),
            ],
          ),
          _buildContent(),
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

  Widget _buildBackgroundImage() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/image/service_dummy_card.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      left: 12,
      top: 12,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_rounded),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleSection(),
            SizedBox(height: 24),
            _buildScheduleSection(),
            SizedBox(height: 16),
            _buildLocationSection(),
            SizedBox(height: 16),
            _buildNoteSection(),
            SizedBox(height: 16),
            _buildButtonSend()
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Electric 24/7 Available',
          style: GoogleFonts.ubuntu(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ColorPallete.darkBlack,
          ),
        ),
        SizedBox(height: 2.0),
        Text(
          'Service Electric 24/7 Available description.',
          style: GoogleFonts.ubuntu(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: ColorPallete.darkGreySilver,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
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
        SizedBox(height: 8.0),
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: ColorPallete.concrete50,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDatePicker(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Row(
      children: [
        Expanded(
          child: _buildPickerButton(
            onTap: _selectDate,
            iconPath: 'assets/icons/icon-calendar.svg',
            text: selectedDate != null
                ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                : 'Select Date',
          ),
        ),
        SizedBox(width: 8.0),
        Expanded(
          child: _buildPickerButton(
            onTap: _selectTime,
            iconPath: 'assets/icons/icon-clock.svg',
            text: selectedTime != null
                ? '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                : 'Select Time',
          ),
        ),
      ],
    );
  }

  Widget _buildPickerButton({
    required VoidCallback onTap,
    required String iconPath,
    required String text,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54.0,
        padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 2, color: ColorPallete.backgroundBody),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath, height: 24),
            SizedBox(width: 8.0),
            Text(
              text,
              style: GoogleFonts.ubuntu(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: ColorPallete.darkBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
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
        SizedBox(height: 8.0),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: ColorPallete.concrete50,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // In-Person Field
                  Expanded(
                    child: Container(
                      height: 54.0,
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            width: 2, color: ColorPallete.backgroundBody),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/icons/icon-location.svg',
                              height: 24),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FieldLocationOffline(),
                                  ),
                                );
                              },
                              child: Text(
                                'In-Person',
                                style: GoogleFonts.ubuntu(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: ColorPallete.darkBlack,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  // Online Field
                  Expanded(
                    child: Container(
                      height: 54.0,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            width: 2, color: ColorPallete.backgroundBody),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/icons/icon-video.svg',
                              height: 24),
                          SizedBox(width: 8.0),
                          Text(
                            'Online',
                            style: GoogleFonts.ubuntu(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: ColorPallete.darkBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildNoteSection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
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
          SizedBox(height: 8.0),
          Container(
            height: 120,
            width: double.infinity,
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: ColorPallete.concrete50,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: SizedBox(
              height: 90,
              width: double.infinity,
              child: TextField(
                cursorColor: ColorPallete.primaryColor,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: 'Optional Notes',
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButtonSend() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: ColorPallete.primaryColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextButton(
        child: Text(
          'Book Appointment Now',
          style: GoogleFonts.ubuntu(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SuccessState(),
            ),
          );
        },
      ),
    );
  }
}
