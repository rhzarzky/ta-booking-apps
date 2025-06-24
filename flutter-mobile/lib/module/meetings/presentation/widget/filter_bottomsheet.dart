import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Appointly/module/meetings/presentation/bloc/booking_bloc.dart';
import 'package:intl/intl.dart';

class FilterBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the bottom sheet to be larger
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
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchMode = false;
  bool _isCalendarMode = false;

  final List<Map<String, String>> filters = [
    {'value': 'all', 'label': 'All Appointments'},
    {'value': 'today', 'label': 'Today'},
    {'value': 'weekly', 'label': '1 Week Ago'},
    {'value': 'monthly', 'label': '30 Days Ago'},
    {'value': 'lastThreeMonths', 'label': '90 Days Ago'},
    {'value': 'custom', 'label': 'Select Date'},
    {'value': 'search', 'label': 'Search'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      // Make the bottom sheet taller for calendar display
      height: _isCalendarMode || _isSearchMode
          ? MediaQuery.of(context).size.height * 0.7
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter your appointments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Show search field if search mode is active
          if (_isSearchMode) ...[
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search meetings...',
                prefixIcon:
                    Icon(Icons.search, color: ColorPallete.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: ColorPallete.primary50),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide:
                      BorderSide(color: ColorPallete.primaryColor, width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Show calendar if calendar mode is active
          if (_isCalendarMode) ...[
            _buildCalendarPicker(),
            if (_selectedDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Selected Date: ${DateFormat('dd MMMM yyyy').format(_selectedDate!)}',
                  style: TextStyle(
                    color: ColorPallete.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],

          // Only show normal filters when not in calendar or search mode
          if (!_isCalendarMode && !_isSearchMode) ...[
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

                    // Toggle modes based on selection
                    if (value == 'custom') {
                      _isCalendarMode = true;
                      _isSearchMode = false;
                    } else if (value == 'search') {
                      _isCalendarMode = false;
                      _isSearchMode = true;
                    } else {
                      _isCalendarMode = false;
                      _isSearchMode = false;
                    }
                  });
                },
              );
            }),
          ],

          Spacer(),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedValue = null;
                      _selectedDate = null;
                      _searchController.clear();
                      _isCalendarMode = false;
                      _isSearchMode = false;
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
                    if (_selectedValue == 'custom' && _selectedDate != null) {
                      // Filter by specific date
                      final startDate = DateTime(_selectedDate!.year,
                          _selectedDate!.month, _selectedDate!.day);
                      final endDate = DateTime(_selectedDate!.year,
                          _selectedDate!.month, _selectedDate!.day, 23, 59, 59);

                      context.read<BookingBloc>().add(
                            FilterBookingsByDateRangeEvent(
                              startDate: startDate,
                              endDate: endDate,
                            ),
                          );
                    } else if (_selectedValue == 'search' &&
                        _searchController.text.isNotEmpty) {
                      // Search by text
                      context.read<BookingBloc>().add(
                            FilterBookAppointmentEvent(
                              filterType: 'search',
                              searchQuery: _searchController.text.trim(),
                            ),
                          );
                    } else if (_selectedValue != null) {
                      // Regular filter types
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

  Widget _buildCalendarPicker() {
    return Container(
      height: 300,
      child: Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: ColorPallete.primaryColor,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: CalendarDatePicker(
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          onDateChanged: (DateTime date) {
            setState(() {
              _selectedDate = date;
            });
          },
        ),
      ),
    );
  }
}
