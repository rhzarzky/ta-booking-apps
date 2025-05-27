import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CardBookmarks extends StatelessWidget {
  final String title;
  final int itemCount;
  final VoidCallback? onArrowTap;
  final Color? startColor;
  final Color? endColor;
  final IconData? topIcon;
  final bool isOnline;
  final bool isOffline;

  const CardBookmarks({
    super.key,
    required this.title,
    required this.itemCount,
    required this.onArrowTap,
    this.topIcon,
    this.isOnline = false,
    this.isOffline = false,
    this.startColor,
    this.endColor,
  });

  // Helper method to get service type text
  String _getServiceTypeText() {
    if (isOnline) return 'Online Services';
    if (isOffline) return 'Offline Services';
    return 'Services';
  }

  // Helper method to get service icon
  IconData _getServiceIcon() {
    if (topIcon != null) return topIcon!;
    if (isOnline) return Icons.wifi_tethering_rounded;
    if (isOffline) return Icons.location_on_rounded;
    return Icons.list_rounded; // Default icon
  }

  @override
  Widget build(BuildContext context) {
    // Define colors based on service type
    Color getStartColor() {
      if (isOnline) return const Color(0xFF7B68EE); 
      if (isOffline) return const Color(0xFF4CAF50); 
      return const Color(0xFF7B68EE); 
    }

    Color getEndColor() {
      if (isOnline) return const Color(0xFF4A4A4A); 
      if (isOffline) return const Color(0xFF2E7D32); 
      return const Color(0xFF4A4A4A); 
    }

    final defaultStartColor = getStartColor();
    final defaultEndColor = getEndColor();

    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Stack(
          clipBehavior: Clip.antiAlias,
          children: [
            // Main card container
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    startColor ?? defaultStartColor,
                    endColor ?? defaultEndColor,
                  ],
                ),
                border: Border.all(
                  color: ColorPallete.primaryDark.withOpacity(0.6),
                  strokeAlign: BorderSide.strokeAlignInside,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    // Bottom section with item count and arrow
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Item count and online/offline status
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$itemCount Items',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getServiceTypeText(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        // Arrow button
                        GestureDetector(
                          onTap: onArrowTap,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.arrow_outward_rounded,
                              color: Colors.white,
                              size: 32,
                              weight: 800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Title in absolute top-right position
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: ColorPallete.primaryDark,
                      width: 2,
                    ),
                    right: BorderSide(
                      color: ColorPallete.primaryDark,
                      width: 2,
                    ),
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(0),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Text(
                  title,
                  style: GoogleFonts.ubuntu(
                    color: ColorPallete.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Service type icon
            Positioned(
              top: -36,
              left: -112,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Transform.rotate(
                  angle: 0,
                  child: Icon(
                    _getServiceIcon(),
                    color: Colors.white.withOpacity(0.2),
                    size: 280,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
