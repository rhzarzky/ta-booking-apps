import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Appointly/module/meetings/presentation/bloc/booking_bloc.dart';

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
    {'value': 'all', 'label': 'All Appointments'},
    {'value': 'today', 'label': 'Today'},
    {'value': 'weekly', 'label': '1 Week Ago'},
    {'value': 'monthly', 'label': '30 Days Ago'},
    {'value': 'lastThreeMonths', 'label': '90 Days Ago'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filter your appointments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...filters.map((filter) {
            return RadioListTile<String>(
              value: filter['value']!,
              title: Text(filter['label']!),
              groupValue: _selectedValue,
              activeColor: ColorPallete.primaryColor,
              contentPadding: const EdgeInsets.all(0),
              tileColor: ColorPallete.primaryColor,
              selectedTileColor: ColorPallete.primaryColor,
              onChanged: (String? value) {
                setState(() {
                  _selectedValue = value;
                });
              },
            );
          }),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedValue = null;
                    });
                    Navigator.pop(context, null);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPallete.primary50,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
              SizedBox(width: 16.0),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedValue != null) {
                      context.read<BookingBloc>().add(
                            FilterBookAppointmentEvent(
                              filterType: _selectedValue,
                            ),
                          );
                    }
                    Navigator.pop(context, _selectedValue);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPallete.primaryColor,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
            ],
          ),
        ],
      ),
    );
  }
}
