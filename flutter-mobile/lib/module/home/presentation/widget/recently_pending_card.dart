import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class RecentlyPendingCard extends StatelessWidget {
  final String titleCard;
  final String descCard;
  final String dateCard;
  final String imageCard;
  final String locationCard;
  final String? onlineLocCard;
  final String? offlineLocCard;
  final String durationCard;
  final VoidCallback linkCard;
  final String? noteCard;
  final String statusCard;

  const RecentlyPendingCard({
    super.key,
    required this.titleCard,
    required this.descCard,
    required this.imageCard,
    required this.dateCard,
    required this.locationCard,
    this.onlineLocCard,
    this.offlineLocCard,
    required this.durationCard,
    required this.linkCard,
    this.noteCard,
    required this.statusCard,
  });

  Color _getStatusColor() {
    switch (statusCard.toLowerCase()) {
      case 'approved':
        return ColorPallete.primaryColor;
      case 'pending':
        return ColorPallete.accent400;
      case 'declined':
        return ColorPallete.greySilverChalice;
      default:
        return ColorPallete.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 300,
        maxWidth: 400,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            ColorPallete.concrete50.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with status badge and blur overlay
            Stack(
              children: [
                // Image container
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    image: (imageCard.isNotEmpty)
                        ? DecorationImage(
                            image: imageCard.startsWith('http')
                                ? NetworkImage(imageCard)
                                : AssetImage(imageCard) as ImageProvider,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (imageCard.isEmpty)
                      ? Image.asset(
                          'assets/image/404page.png',
                          fit: BoxFit.contain,
                        )
                      : null,
                ),

                // Gradient overlay without blur for smooth transition
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.black.withOpacity(0.5),
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),

                // Status badge with frosted glass effect
                // Status badge with frosted glass effect
                Positioned(
                  top: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      topRight: Radius.circular(16),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getStatusColor().withOpacity(0.9),
                              _getStatusColor().withOpacity(0.7),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            topRight: Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getStatusColor().withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          statusCard,
                          style: GoogleFonts.ubuntu(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Title and description at bottom of image
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titleCard,
                          style: GoogleFonts.ubuntu(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          descCard,
                          style: GoogleFonts.ubuntu(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.95),
                            height: 1.3,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content area with blur effect
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.9),
                        ColorPallete.concrete50.withOpacity(0.85),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildScheduleSection(),
                      const SizedBox(height: 16),
                      // if (noteCard.isNotEmpty) ...[
                      //   _buildNoteSection(),
                      //   const SizedBox(height: 12),
                      // ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Schedule section with blur effect and smooth design transitions
  Widget _buildScheduleSection() {
    return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColorPallete.concrete50.withOpacity(0.8),
                    ColorPallete.concrete50.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Schedule',
                        style: GoogleFonts.ubuntu(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ColorPallete.darkBlack,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Date and time row with enhanced styling
                  Row(
                    children: [
                      // Date
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color:
                                    ColorPallete.primaryDark.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.calendar_today_outlined,
                                color: ColorPallete.primaryDark,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dateCard,
                                style: GoogleFonts.ubuntu(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: ColorPallete.primaryDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      // Duration with improved icon
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color:
                                    ColorPallete.primaryDark.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.access_time_rounded,
                                color: ColorPallete.primaryDark,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                durationCard,
                                style: GoogleFonts.ubuntu(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: ColorPallete.primaryDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Location section with improved design
                  _buildLocationSection(),
                ],
              ),
            )));
  }

  // Location section with frosted glass effect
  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Location',
              style: GoogleFonts.ubuntu(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorPallete.darkBlack,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Location container with frosted glass effect
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.98),
                    Colors.white.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Conditional icon based on location type with enhanced styling
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _getLocationIconColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getLocationIcon(),
                      color: _getLocationIconColor(),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      locationCard,
                      style: GoogleFonts.ubuntu(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ColorPallete.darkBlack,
                        letterSpacing: 0.2,
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
      ],
    );
  }

  // Helper method to determine appropriate location icon
  IconData _getLocationIcon() {
    final String location = locationCard.toLowerCase();
    if (location == 'offline') {
      return Icons.map_outlined;
    } else if (location == 'online') {
      return Icons.wifi_tethering_rounded;
    } else if (location.contains('zoom') || location.contains('meet')) {
      return Icons.videocam_rounded;
    } else {
      return Icons.place_rounded;
    }
  }

  // Helper method to determine appropriate location icon color
  Color _getLocationIconColor() {
    final String location = locationCard.toLowerCase();
    if (location == 'offline') {
      return ColorPallete.primaryDark;
    } else if (location == 'online') {
      return Colors.teal;
    } else if (location.contains('zoom')) {
      return const Color(0xFF2D8CFF); // Zoom blue
    } else {
      return ColorPallete.primaryDark;
    }
  }

  // Notes section with frosted glass effect
  // Widget _buildNoteSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         children: [
  //           Text(
  //             'Notes',
  //             maxLines: 2,
  //             overflow: TextOverflow.ellipsis,
  //             style: GoogleFonts.ubuntu(
  //               fontSize: 16,
  //               fontWeight: FontWeight.w600,
  //               color: ColorPallete.darkBlack,
  //             ),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 8),

  //       // Notes container with frosted glass effect
  //       ClipRRect(
  //         borderRadius: BorderRadius.circular(16),
  //         child: BackdropFilter(
  //           filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
  //           child: Container(
  //             width: double.infinity,
  //             padding: const EdgeInsets.all(14),
  //             decoration: BoxDecoration(
  //               gradient: LinearGradient(
  //                 begin: Alignment.topLeft,
  //                 end: Alignment.bottomRight,
  //                 colors: [
  //                   ColorPallete.concrete50.withOpacity(0.9),
  //                   ColorPallete.concrete50.withOpacity(0.7),
  //                 ],
  //               ),
  //               borderRadius: BorderRadius.circular(16),
  //               border: Border.all(
  //                 color: Colors.white.withOpacity(0.5),
  //                 width: 1,
  //               ),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withOpacity(0.03),
  //                   blurRadius: 8,
  //                   offset: const Offset(0, 2),
  //                 ),
  //               ],
  //             ),
  //             child: Text(
  //               noteCard,
  //               style: GoogleFonts.ubuntu(
  //                 fontSize: 13,
  //                 fontWeight: FontWeight.w400,
  //                 color: ColorPallete.darkGreySilver,
  //                 height: 1.4,
  //                 letterSpacing: 0.2,
  //               ),
  //               maxLines: 3,
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
