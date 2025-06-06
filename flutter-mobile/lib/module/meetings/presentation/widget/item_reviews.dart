import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:flutter/material.dart';
import 'rating_bar.dart';

class ItemReviews extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String date;
  final double rating;
  final String review;
  final VoidCallback? onTap;
  final bool isInteractive;
  final ValueChanged<double>? onRatingChanged;

  const ItemReviews({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.date,
    required this.rating,
    required this.review,
    this.onTap,
    this.isInteractive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: (imageUrl != null && imageUrl.isNotEmpty)
                      ? imageUrl.startsWith('http')
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset('assets/image/404page.png',
                                      fit: BoxFit.cover),
                            )
                          : Image.asset(imageUrl, fit: BoxFit.cover)
                      : Image.asset(
                          'assets/image/404page.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorPallete.darkBlack),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorPallete.darkGreySilver,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: ColorPallete.greySilverChalice950,
                ),
              ),
            ],
          ),
          Divider(
            color: ColorPallete.darkGreySilver,
            thickness: 1,
            height: 12,
          ),
          SizedBox(height: 8),
          Column(
            children: [
              isInteractive
                  ? RatingBar(
                      starCount: 5,
                      initialRating: rating,
                      onRatingChanged: onRatingChanged ?? (value) {},
                      color: ColorPallete.primaryColor,
                      borderColor: ColorPallete.darkGreySilver,
                      size: 20,
                      allowHalfRating: false,
                    )
                  : _buildStaticRatingStars(rating),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorPallete.backgroundBody,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  review,
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorPallete.darkBlack,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStaticRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: ColorPallete.primaryColor,
          size: 16,
        );
      }),
    );
  }
}
