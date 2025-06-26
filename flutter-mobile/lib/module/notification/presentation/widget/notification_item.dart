import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final String timeStamp;
  final String indicatorStatus;
  final VoidCallback? onTap;

  const NotificationItem({
    super.key,
    required this.title,
    required this.timeStamp,
    required this.indicatorStatus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildGetIndicator(),
          SizedBox(
            width: 12.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.ubuntu(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorPallete.darkBlack,
                ),
              ),
              SizedBox(
                height: 4.0,
              ),
              Text(
                timeStamp,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.ubuntu(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ColorPallete.darkGreySilver,
                ),
              ),
            ],
          ),
          Spacer(),
          IconButton(
            onPressed: onTap,
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: ColorPallete.greySilverChalice,
              size: 20.0,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGetIndicator() {
    switch (indicatorStatus.toLowerCase()) {
      case 'approved':
        return _approvedIndicator();
      case 'completed':
        return _completedIndicator();
      case 'declined':
        return _declinedIndicator();
      case 'success':
        return _approvedIndicator();
      case 'pending':
        return _pendingIndicator();
      default:
        return _pendingIndicator();
    }
  }

  Widget _approvedIndicator() {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        color: ColorPallete.greenMalachite,
      ),
      child: SvgPicture.asset('assets/icons/calendar-check-white.svg'),
    );
  }

  Widget _completedIndicator() {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        color: ColorPallete.secondColor, // Yellow color for completed bookings
      ),
      child: SvgPicture.asset('assets/icons/calendar-check-white.svg'),
    );
  }

  Widget _pendingIndicator() {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        color: ColorPallete.secondColor,
      ),
      child: SvgPicture.asset('assets/icons/calendar-time-white.svg'),
    );
  }

  Widget _declinedIndicator() {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        color:
            ColorPallete.greySilverChalice, // Grey color for declined bookings
      ),
      child: SvgPicture.asset('assets/icons/calendar-x-white.svg'),
    );
  }
}
