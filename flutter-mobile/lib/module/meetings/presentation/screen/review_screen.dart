import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/presentation/bloc/review_bloc.dart';
import 'package:Appointly/module/meetings/presentation/bloc/review_event.dart';
import 'package:Appointly/module/meetings/presentation/bloc/review_state.dart';
import 'package:Appointly/module/meetings/presentation/widget/item_reviews.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger get all reviews saat screen dimuat
    context.read<ReviewBloc>().add(GetAllReviewEvent());
  }

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
          child: BlocBuilder<ReviewBloc, ReviewState>(
            builder: (context, state) {
              print('Current ReviewBloc state: ${state.runtimeType}');
              if (state is ReviewLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is GetAllReviewSuccess) {
                print('Reviews count: ${state.reviews.length}');
                if (state.reviews.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada review',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 16,
                        color: ColorPallete.greySilverChalice,
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ReviewBloc>().add(GetAllReviewEvent());
                  },
                  child: ListView.builder(
                    itemCount: state.reviews.length,
                    itemBuilder: (context, index) {
                      final review = state.reviews[index];
                      return ItemReviews(
                        imageUrl: 'https://via.placeholder.com/150',
                        title: 'Booking #${review.bookingId}',
                        subtitle: 'User ID: ${review.userId}',
                        rating: review.rating?.toDouble() ?? 0.0,
                        date: review.createdAt?.toString().split(' ')[0] ?? '',
                        review: review.comment ?? '',
                        isInteractive: false,
                        onRatingChanged: (value) {
                          // Untuk viewing mode, tidak perlu aksi
                        },
                      );
                    },
                  ),
                );
              } else if (state is ReviewFailure) {
                return Center(
                  child: Text(state.error),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
