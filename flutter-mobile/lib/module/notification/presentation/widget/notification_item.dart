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
                title ?? 'Service Electric 24/7 Available ',
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
                timeStamp ?? '2 minutes ago',
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
      case 'success':
        return _successIndicator();
      case 'pending':
        return _pendingIndicator();
      case 'declined':
        return _declinedIndicator();
      default:
        return _pendingIndicator();
    }
  }

  Widget _successIndicator() {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        color: ColorPallete.greenMalachite,
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
        color: ColorPallete.redCinnabar,
      ),
      child: SvgPicture.asset('assets/icons/calendar-x-white.svg'),
    );
  }
}
