import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpandedText extends StatefulWidget {
  final String text;
  final int maxLine;

  const ExpandedText({
    super.key,
    required this.text,
    this.maxLine = 120,
  });

  @override
  State<ExpandedText> createState() => _ExpandedTextState();
}

class _ExpandedTextState extends State<ExpandedText> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    final isLongText = widget.text.length > widget.maxLine;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isExpanded
              ? widget.text
              : isLongText
                  ? '${widget.text.substring(0, widget.maxLine)}...'
                  : widget.text,
          style: GoogleFonts.ubuntu(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: ColorPallete.darkGreySilver,
          ),
        ),
        if (isLongText)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(_isExpanded ? 'Show less' : 'Show more',
                style: GoogleFonts.ubuntu(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: ColorPallete.primaryColor,
                )),
          )
      ],
    );
  }
}
