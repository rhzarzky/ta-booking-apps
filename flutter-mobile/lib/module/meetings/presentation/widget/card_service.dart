// ignore_for_file: depend_on_referenced_packages

import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class CardService extends StatelessWidget {
  final String imageService;
  final String headService;
  final String descService;
  final String locationService;
  final List<String> timeService;
  final List<String> provideService;
  final VoidCallback onTap;
  final VoidCallback onSave;
  final int rating;
  final int review;

  const CardService({
    super.key,
    required this.imageService,
    required this.descService,
    required this.locationService,
    required this.headService,
    required this.timeService,
    required this.provideService,
    required this.onTap,
    required this.onSave,
    required this.rating,
    required this.review,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: (imageService.isNotEmpty &&
                            imageService.startsWith('http'))
                        ? Image.network(
                            imageService,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 240,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Container(
                                width: double.infinity,
                                height: 240,
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      ColorPallete.primaryColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print('🚨 Image loading error: $error');
                              print('🔗 Failed URL: $imageService');
                              return Container(
                                width: double.infinity,
                                height: 240,
                                color: Colors.grey[100],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Image not available',
                                      style: GoogleFonts.ubuntu(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : (imageService.isNotEmpty)
                            ? Image.asset(
                                imageService,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 240,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.infinity,
                                    height: 240,
                                    color: Colors.grey[100],
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Asset not found',
                                          style: GoogleFonts.ubuntu(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : Container(
                                width: double.infinity,
                                height: 240,
                                color: Colors.grey[100],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'No image available',
                                      style: GoogleFonts.ubuntu(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: onSave,
                          icon: Icon(
                            Icons.bookmark_outline_rounded,
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(8),
                          iconSize: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
                  width: double.infinity,
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
                        vertical: 6.0,
                        horizontal: 16.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: ColorPallete.primaryDark,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${timeService.isNotEmpty ? timeService.first : "N/A"} at $locationService  ',
                              style: GoogleFonts.ubuntu(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ColorPallete.primaryDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
                                vertical: 6.0,
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
                    SizedBox(width: 8),
                    // Rating Section with Stars
                    Tooltip(
                      message: rating > 0
                          ? 'Rating: $rating/5 stars'
                          : 'No rating yet',
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: rating > 0
                              ? LinearGradient(
                                  colors: [
                                    Colors.amber.shade50,
                                    Colors.amber.shade100,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.grey.shade100,
                                    Colors.grey.shade50,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: rating > 0
                                ? Colors.amber.shade300
                                : Colors.grey.shade300,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (rating > 0 ? Colors.amber : Colors.grey)
                                  .withOpacity(0.15),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...List.generate(5, (index) {
                              return Padding(
                                padding:
                                    EdgeInsets.only(right: index < 4 ? 1 : 0),
                                child: Icon(
                                  index < rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 12,
                                  color: index < rating
                                      ? Colors.amber.shade600
                                      : Colors.grey.shade400,
                                ),
                              );
                            }),
                            SizedBox(width: 4),
                            Text(
                              rating > 0 ? rating.toString() : '0',
                              style: GoogleFonts.ubuntu(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: rating > 0
                                    ? Colors.amber.shade800
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    // Reviews Count Section
                    Tooltip(
                      message: review > 0
                          ? '$review review${review > 1 ? 's' : ''}'
                          : 'No reviews yet',
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: review > 0
                              ? LinearGradient(
                                  colors: [
                                    ColorPallete.primaryColor.withOpacity(0.1),
                                    ColorPallete.primaryColor.withOpacity(0.15),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.grey.shade100,
                                    Colors.grey.shade50,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: review > 0
                                ? ColorPallete.primaryColor.withOpacity(0.4)
                                : Colors.grey.shade300,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (review > 0
                                      ? ColorPallete.primaryColor
                                      : Colors.grey)
                                  .withOpacity(0.15),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: (review > 0
                                        ? ColorPallete.primaryColor
                                        : Colors.grey)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline,
                                size: 10,
                                color: review > 0
                                    ? ColorPallete.primaryColor
                                    : Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              review > 0 ? '$review' : '0',
                              style: GoogleFonts.ubuntu(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: review > 0
                                    ? ColorPallete.primaryColor
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 16),
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
