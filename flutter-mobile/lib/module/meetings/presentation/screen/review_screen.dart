import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/presentation/widget/item_reviews.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorPallete.backgroundBody,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          foregroundColor: Colors.white,
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          elevation: 0,
          shadowColor: Colors.transparent,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: ColorPallete.darkBlack,
                ),
              ),
              Text(
                'My Reviews',
                style: GoogleFonts.sourceSans3(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: ColorPallete.darkBlack,
                ),
              ),
            ],
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          child: ListView.builder(
            itemBuilder: (context, index) {
              return ItemReviews(
                imageUrl: 'https://via.placeholder.com/150',
                title: 'Judul Layanan',
                subtitle: 'Nama Layanan',
                rating: 4.5,
                review: 'yang pernah diajukan untuk memperoleh gelar akademik di suatu Perguruan Tinggi, dan sepanjang pengetahuan saya juga tidak terdapat karya atau pendapat yang pernah ditulis atau diterbitkan oleh ora',
                date: '2023-01-01',
                isInteractive: true,
                onRatingChanged: (value) {
                  print(value);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
