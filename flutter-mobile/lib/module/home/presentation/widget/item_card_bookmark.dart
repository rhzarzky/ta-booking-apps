import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemCardBookmark extends StatelessWidget {
  final String titleCard;
  final String descCard;
  final String imageCard;
  final String locationCard;
  final String? onlineLocCard;
  final String? offlineLocCard;
  final String statusCard;
  final VoidCallback? onTap;

  const ItemCardBookmark({
    super.key,
    required this.titleCard,
    required this.descCard,
    required this.imageCard,
    required this.locationCard,
    this.onlineLocCard,
    this.offlineLocCard,
    required this.statusCard,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 152,
          maxWidth: 182,
          minHeight: 280,
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
              Stack(
                children: [
                  // Image container
                  Container(
                    width: double.infinity,
                    height: 280,
                    decoration: BoxDecoration(
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

                  // Gradient overlay
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
                        mainAxisSize: MainAxisSize.min,
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
                          SizedBox(height: 8),
                          Row(
                            children: [
                              if (locationCard.isNotEmpty &&
                                  (locationCard.contains('Offline') ||
                                      locationCard.contains('Online')))
                                Icon(
                                  _getLocationIcon(),
                                  color: Colors.white,
                                  size: 16,
                                ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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
}
