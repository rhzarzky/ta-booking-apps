// interactive_rating_bar.dart
import 'package:flutter/material.dart';

class RatingBar extends StatefulWidget {
  final int starCount;
  final double initialRating;
  final ValueChanged<double> onRatingChanged;
  final Color color;
  final Color borderColor; // Warna untuk bintang yang belum dipilih (border)
  final double size;
  final bool
      allowHalfRating; // Jika ingin mengizinkan setengah bintang (lebih kompleks)
  final IconData filledStar;
  final IconData halfFilledStar; // Jika allowHalfRating true
  final IconData emptyStar;

  const RatingBar({
    Key? key,
    this.starCount = 5,
    this.initialRating = 0.0,
    required this.onRatingChanged,
    this.color = Colors.amber, // Warna bintang yang terisi
    this.borderColor = Colors.grey, // Warna bintang kosong atau border
    this.size = 30.0,
    this.allowHalfRating =
        false, // Defaultnya tidak mengizinkan setengah bintang
    this.filledStar = Icons.star_rounded,
    this.halfFilledStar = Icons.star_half_rounded,
    this.emptyStar = Icons.star_border_rounded,
  }) : super(key: key);

  @override
  _RatingBarState createState() => _RatingBarState();
}

class _RatingBarState extends State<RatingBar> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Agar row tidak mengambil lebar penuh
      children: List.generate(widget.starCount, (index) {
        return buildStar(context, index);
      }),
    );
  }

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    double starRating =
        index + 1.0; // Rating untuk bintang saat ini (1, 2, 3, 4, 5)

    if (widget.allowHalfRating) {
      // Logika untuk setengah bintang (lebih kompleks, contoh sederhana di bawah)
      // Untuk implementasi half-rating yang lebih baik, Anda mungkin perlu GestureDetector
      // dan menghitung posisi tap di dalam ikon.
      if (_currentRating >= starRating) {
        icon = Icon(widget.filledStar, color: widget.color, size: widget.size);
      } else if (_currentRating > index && _currentRating < starRating) {
        // Ini adalah kondisi untuk setengah bintang
        icon =
            Icon(widget.halfFilledStar, color: widget.color, size: widget.size);
      } else {
        icon = Icon(widget.emptyStar,
            color: widget.borderColor, size: widget.size);
      }
    } else {
      // Logika untuk bintang penuh
      if (_currentRating >= starRating) {
        icon = Icon(widget.filledStar, color: widget.color, size: widget.size);
      } else {
        icon = Icon(widget.emptyStar,
            color: widget.borderColor, size: widget.size);
        // Atau jika ingin bintang terisi tapi warna border untuk yang kosong:
        // icon = Icon(widget.filledStar, color: widget.borderColor, size: widget.size);
      }
    }

    return IconButton(
      icon: icon,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(), // Menghilangkan padding default IconButton
      splashRadius: widget.size / 1.5,
      tooltip: "${index + 1} star",
      onPressed: () {
        setState(() {
          // Jika allowHalfRating diimplementasikan dengan lebih detail, logika di sini akan berbeda
          _currentRating = starRating;
        });
        widget.onRatingChanged(_currentRating);
      },
    );
  }
}
