import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final String timeStamp;
  final String indicatorStatus;
  final VoidCallback? onTap;
  final String? body; // Add body parameter for description
  const NotificationItem({
    super.key,
    required this.title,
    required this.timeStamp,
    required this.indicatorStatus,
    required this.onTap,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      padding: EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 16.0), // Increase vertical padding
      constraints: BoxConstraints(
        minHeight:
            90.0, // Increase minimum height for comprehensive service info
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildGetIndicator(),
          SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Column(
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
                ), // Show description if available, otherwise show formatted timestamp
                Builder(
                  builder: (context) {
                    print(
                        '🔍 NotificationItem: title=$title, body=$body, timeStamp=$timeStamp');
                    final displayText = body ?? _formatTimestamp(timeStamp);
                    print('🔍 NotificationItem: displayText=$displayText');
                    return Text(
                      displayText,
                      maxLines:
                          5, // Increase to 5 lines for comprehensive service info
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.ubuntu(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ColorPallete.darkGreySilver,
                        height:
                            1.4, // Increase line height for better readability
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
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
      // case 'completed':
      //   return _completedIndicator();
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

  // Widget _completedIndicator() {
  //   return Container(
  //     padding: EdgeInsets.all(8.0),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(24.0),
  //       color: ColorPallete.secondColor, // Yellow color for completed bookings
  //     ),
  //     child: SvgPicture.asset('assets/icons/calendar-check-white.svg'),
  //   );
  // }

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

  // Helper method to format timestamp
  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours} hours ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        // Format as readable date for older notifications
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return timestamp;
    }
  }
}
