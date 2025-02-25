// ignore_for_file: depend_on_referenced_packages

import 'package:appointly/core/theme/color_pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return _FilterContent();
      },
    );
  }
}

class _FilterContent extends StatefulWidget {
  @override
  State<_FilterContent> createState() => _FilterContentState();
}

class _FilterContentState extends State<_FilterContent> {
  String? _selectedValue;

  final List<Map<String, String>> filters = [
    {'value': 'all', 'label': 'Show All'},
    {'value': 'new', 'label': 'New Items'},
    {'value': 'popular', 'label': 'Popular'},
    {'value': 'featured', 'label': 'Featured'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Appointly Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...filters.map((filter) {
            return RadioListTile<String>(
              title: Text(filter['label']!),
              value: filter['value']!,
              groupValue: _selectedValue,
              activeColor: ColorPallete.primaryColor,
              contentPadding: const EdgeInsets.all(0),
              onChanged: (String? value) {
                setState(() {
                  _selectedValue = value;
                });
              },
            );
          }),
          SizedBox(
            height: 12,
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: ColorPallete.primary50,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'Reset',
                      style: GoogleFonts.ubuntu(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ColorPallete.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: ColorPallete.primaryColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'Apply',
                      style: GoogleFonts.ubuntu(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
