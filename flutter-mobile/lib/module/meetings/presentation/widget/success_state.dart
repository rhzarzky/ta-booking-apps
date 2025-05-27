import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/presentation/screen/detail_meeting_success.dart';
import 'package:Appointly/module/notification/presentation/screen/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:Appointly/core/common/main_tab_screen.dart';

class SuccessState extends StatelessWidget {
  final int bookingId;
  final String userId;

  const SuccessState({
    super.key,
    required this.bookingId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final logger = Logger();
    logger.d('Success state with bookingId: $bookingId');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success Illustration
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/image/sucess-illus.png',
                  width: 350,
                ),
              ),
              const SizedBox(height: 16),

              // Text Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thanks, your booking has been recorded.',
                      style: GoogleFonts.ubuntu(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: ColorPallete.darkBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stay updated on your appointment status and check your email for any updates.',
                      style: GoogleFonts.ubuntu(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: ColorPallete.darkGreySilver,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (bookingId > 0)
                      Column(
                        children: [
                          _buildViewAppointmentButton(context),
                          const SizedBox(height: 8),
                        ],
                      )
                    else
                      _buildHomeButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewAppointmentButton(BuildContext context) {
    final logger = Logger();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          logger.d(
              'Navigating to DetailMeetingSuccess with bookingId: $bookingId');
          // Cek terlebih dahulu apakah bookingId valid
          if (bookingId <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'ID Pemesanan tidak valid. Silakan kembali ke beranda.')),
            );
            // Redirect ke home jika bookingId tidak valid
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainTabScreen()),
              (route) => false,
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailMeetingSuccess(
                bookingId: bookingId,
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: ColorPallete.primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'View Appointment',
            style: GoogleFonts.ubuntu(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainTabScreen()),
              (route) => false,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: ColorPallete.primary400,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Back to Home',
                style: GoogleFonts.ubuntu(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
