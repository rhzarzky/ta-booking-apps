import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CardAppointment extends StatelessWidget {
  final String titleCard;
  final String descCard;
  final String dateCard;
  final String locationCard;
  final String durationCard;
  final VoidCallback linkCard;
  final String noteCard;
  final String statusCard;
  final String? onlineLocCard;
  final String? offlineLocCard;

  const CardAppointment({
    super.key,
    required this.titleCard,
    required this.descCard,
    required this.dateCard,
    required this.locationCard,
    required this.durationCard,
    required this.linkCard,
    required this.noteCard,
    required this.statusCard,
    this.onlineLocCard,
    this.offlineLocCard,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorPallete.concreteWhite,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getStatusColor().withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Title and Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titleCard,
                          style: GoogleFonts.ubuntu(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: ColorPallete.darkBlack,
                          ),
                        ),
                        Text(
                          descCard,
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
                  ),
                  _buildStatusChip(),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info boxes with icons
                  _buildInfoGrid(),

                  const SizedBox(height: 16),

                  // Note Section
                  if (noteCard.isNotEmpty) _buildNoteSection(),

                  const SizedBox(height: 12),

                  // View Button
                  _buildViewButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getStatusIcon(),
          const SizedBox(width: 4),
          Text(
            statusCard,
            style: GoogleFonts.ubuntu(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStatusIcon() {
    switch (statusCard.toLowerCase()) {
      case 'approved':
        return const Icon(Icons.check_circle, size: 14, color: Colors.white);
      case 'pending':
        return const Icon(Icons.access_time, size: 14, color: Colors.white);
      case 'declined':
        return const Icon(Icons.cancel, size: 14, color: Colors.white);
      default:
        return const Icon(Icons.check_circle, size: 14, color: Colors.white);
    }
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
    final location = locationCard.toLowerCase();

    if (location.startsWith('http://') ||
        location.startsWith('https://') ||
        location.contains('zoom') ||
        location.contains('meet') ||
        location.contains('link')) {
      return Icons.wifi_tethering_rounded;
    } else {
      return Icons.place_rounded;
    }
  }

  String _getLocationText() {
    final location = locationCard.toLowerCase();

    if (location.startsWith('http://') ||
        location.startsWith('https://') ||
        location.contains('zoom') ||
        location.contains('meet')) {
      return "Online Meeting";
    } else {
      return locationCard;
    }
  }

  Widget _buildInfoGrid() {
    return Container(
      decoration: BoxDecoration(
        color: ColorPallete.concrete50,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.calendar_today_rounded,
                  'Date',
                  dateCard,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoItem(
                  Icons.access_time_rounded,
                  'Time',
                  durationCard,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            _getLocationIcon(),
            'Location',
            _getLocationText(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorPallete.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: ColorPallete.primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.ubuntu(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: ColorPallete.darkGreySilver,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.ubuntu(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ColorPallete.darkBlack,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoteSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorPallete.concrete50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ColorPallete.backgroundBody,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sticky_note_2_outlined,
                size: 16,
                color: ColorPallete.darkGreySilver,
              ),
              const SizedBox(width: 6),
              Text(
                'Notes',
                style: GoogleFonts.ubuntu(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ColorPallete.darkGreySilver,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            noteCard,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.ubuntu(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: ColorPallete.darkBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton() {
    return InkWell(
      onTap: linkCard,
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: ColorPallete.primaryColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: ColorPallete.primaryColor.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          'View Details',
          style: GoogleFonts.ubuntu(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
