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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                image: DecorationImage(
                  // Use NetworkImage for URLs instead of AssetImage
                  image: imageService.startsWith('http')
                      ? NetworkImage(imageService) as ImageProvider
                      : AssetImage(imageService),
                  fit: BoxFit.cover,
                ),
              ),
              width: 400,
              height: 200,
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
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: ColorPallete.backgroundBody),
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available Now',
                            style: GoogleFonts.ubuntu(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ColorPallete.darkBlack,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            provideService.join(', '),
                            style: GoogleFonts.ubuntu(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: ColorPallete.greenMalachite,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 40,
                        child: VerticalDivider(
                          thickness: 1,
                          color: ColorPallete.greySilverChalice,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Schedule From',
                            style: GoogleFonts.ubuntu(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ColorPallete.darkBlack,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeService.join(', '),
                            style: GoogleFonts.ubuntu(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: ColorPallete.greenMalachite,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPallete.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Pusatkan elemen
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
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
