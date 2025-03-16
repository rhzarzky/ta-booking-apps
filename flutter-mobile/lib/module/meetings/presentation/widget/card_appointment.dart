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
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.white,
      color: Colors.white,
      child: Stack(
        children: [
          // Status Chip
          Positioned(
            top: 0,
            left: 290,
            right: 0,
            child: _buildGetStatus(),
          ),
          // Title and Description
          Padding(
            padding: const EdgeInsets.all(12.0),
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
                const SizedBox(height: 4.0),
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
                const SizedBox(height: 12.0),

                // Details Grid
                _buildDetailsGrid(dateCard, locationCard, durationCard),
                const SizedBox(height: 16.0),
                // Note Section
                _buildNoteSection(noteCard),
                const SizedBox(height: 8.0),
                // View Appointment Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: linkCard,
                      child: Text(
                        'View Appointment',
                        style: GoogleFonts.ubuntu(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ColorPallete.primaryColor,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_right_rounded,
                      weight: 12,
                      color: ColorPallete.primaryColor,
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStatus() {
    switch (statusCard.toLowerCase()) {
      case 'approved':
        return _buildStatusSucess(statusCard);
      case 'pending':
        return _buildStatusUnderReview(statusCard);
      case 'declined':
        return _buildStatusDeclined(statusCard);
      default:
        return _buildStatusSucess(statusCard);
    }
  }

  Widget _buildStatusSucess(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: ColorPallete.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
      ),
      child: Text(
        status,
        style: GoogleFonts.ubuntu(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatusUnderReview(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: ColorPallete.accent400,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
      ),
      child: Text(
        status,
        style: GoogleFonts.ubuntu(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatusDeclined(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: ColorPallete.greySilverChalice,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
      ),
      child: Text(
        status,
        style: GoogleFonts.ubuntu(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDetailsGrid(String date, String location, String duration) {
    return Column(
      children: [
        Row(
          children: [
            Flexible(
              child: _buildDetailItem('Date:', date),
            ),
            const SizedBox(width: 8.0),
            Flexible(
              child: _buildDetailItem('Duration:', duration),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Flexible(
              child: _buildDetailItem('Location:', location),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: ColorPallete.backgroundBody,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Label Text
          Text(
            label,
            style: GoogleFonts.ubuntu(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: ColorPallete.darkBlack,
            ),
          ),
          const SizedBox(width: 4.0), 
          // Value Text
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.ubuntu(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ColorPallete.darkBlack,
              ),
              overflow: TextOverflow.ellipsis, 
              maxLines: 1, 
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection(String note) {
    return Container(
      height: 90,
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: ColorPallete.concrete50,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        note,
        style: GoogleFonts.ubuntu(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: ColorPallete.darkGreySilver,
        ),
      ),
    );
  }
}
