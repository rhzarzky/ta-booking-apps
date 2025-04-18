import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Appointly/core/theme/color_pallete.dart';

class DropdownTime extends StatelessWidget {
  final String? selectedValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const DropdownTime({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 2, color: ColorPallete.backgroundBody),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_rounded),
          SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                autofocus: true,
                borderRadius: BorderRadius.circular(16),
                dropdownColor: Colors.white,
                focusColor: ColorPallete.primaryColor,
                value: selectedValue,
                icon: Icon(Icons.keyboard_arrow_down,
                    color: ColorPallete.darkBlack),
                isExpanded: true,
                style: GoogleFonts.ubuntu(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: ColorPallete.darkBlack,
                ),
                onChanged: onChanged,
                items: items.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
