// ignore_for_file: depend_on_referenced_packages

import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CardService extends StatelessWidget {
  final String imageService;
  final String headService;
  final String descService;
  final List<String> timeService;
  final List<String> provideService;
  final VoidCallback onTap;

  const CardService({
    super.key,
    required this.imageService,
    required this.descService,
    required this.headService,
    required this.timeService,
    required this.provideService,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              width: 400,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                image: (imageService != null && imageService.isNotEmpty)
                    ? DecorationImage(
                        image: imageService.startsWith('http')
                            ? NetworkImage(imageService)
                            : AssetImage(imageService) as ImageProvider,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (imageService == null || imageService.isEmpty)
                  ? Image.asset(
                      'assets/image/404page.png',
                      fit: BoxFit.contain,
                    )
                  : null,
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headService,
                  style: GoogleFonts.ubuntu(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ColorPallete.darkBlack,
                  ),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 8),
                Text(
                  descService,
                  style: GoogleFonts.ubuntu(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: ColorPallete.darkGreySilver,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorPallete.primaryDark,
                        ColorPallete.primary400,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Container(
                    margin: EdgeInsets.all(1.5), // Border thickness
                    decoration: BoxDecoration(
                      gradient: ColorPallete.gradientAccent,
                      borderRadius: BorderRadius.circular(22.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize
                            .min, // <<< ADD THIS to make container wrap content
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: ColorPallete.primaryDark,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          // In CardService class
                          Text(
                            'Beginning on : ${timeService.isNotEmpty ? timeService.first : "N/A"}',
                            style: GoogleFonts.ubuntu(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ColorPallete.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (provideService.contains('Offline'))
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ColorPallete.primaryDark,
                              ColorPallete.primary400,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: Container(
                          margin: EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            gradient: ColorPallete.gradientAccent,
                            borderRadius: BorderRadius.circular(22.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.pin_drop_outlined,
                                  color: ColorPallete.primaryDark,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Offline',
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: ColorPallete.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (provideService.contains('Offline') &&
                        provideService.contains('Online'))
                      SizedBox(width: 8),
                    if (provideService.contains('Online'))
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ColorPallete.primaryDark,
                              ColorPallete.primary400,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: Container(
                          margin: EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            gradient: ColorPallete.gradientAccent,
                            borderRadius: BorderRadius.circular(22.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.wifi_tethering_rounded,
                                  color: ColorPallete.primaryDark,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Online',
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: ColorPallete.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorPallete.primaryDark,
                      ColorPallete.primary400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Book Appointment',
                        style: GoogleFonts.ubuntu(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
