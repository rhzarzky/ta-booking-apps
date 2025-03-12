import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final String status;
  final String timeStamp;
  final String imageStatus;

  const NotificationItem({
    super.key,
    required this.title,
    required this.status,
    required this.timeStamp,
    required this.imageStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            color: ColorPallete.greenMalachite,
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(24.0)),
            child: Image.asset("assets/icons/calendar-check-white.svg"),
          ),
          SizedBox(
            width: 8.0,
          ),
          Column(
            children: [
              Text(
                'Service Electric 24/7 Available ',
                style: GoogleFonts.ubuntu(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: ColorPallete.darkBlack,
                ),
              ),
              SizedBox(
                height: 4.0,
              ),
              Text(
                'SHas been Approved',
                style: GoogleFonts.ubuntu(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColorPallete.darkBlack,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                '2 minutes ago',
                style: GoogleFonts.ubuntu(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ColorPallete.darkGreySilver,
                ),
              ),
            ],
          ),
          Spacer(),
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                color: ColorPallete.darkBlack,
                size: 24.0,
              ))
        ],
      ),
    );
  }
}
