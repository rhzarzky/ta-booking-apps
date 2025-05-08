import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/presentation/bloc/booking_bloc.dart';
import 'package:intl/intl.dart';

class DateFilterWidget extends StatefulWidget {
  const DateFilterWidget({super.key});

  @override
  State<DateFilterWidget> createState() => _DateFilterWidgetState();
}
  
class _DateFilterWidgetState extends State<DateFilterWidget> {
  DateTimeRange? _selectedDateRange;
  final DateFormat _dateFormat = DateFormat('MMM d, yyyy');

  @override
  void initState() {
    super.initState();
    // Initialize with last 7 days as default
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    _selectedDateRange = DateTimeRange(start: sevenDaysAgo, end: now);

    // Apply initial filter
    _applyFilter();
  }

  Future<void> _selectDateRange() async {
    final initialDateRange = _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        );

    final newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: ColorPallete.primaryColor,
            colorScheme: ColorScheme.light(
              primary: ColorPallete.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (newDateRange != null) {
      setState(() {
        _selectedDateRange = newDateRange;
      });
      _applyFilter();
    }
  }

  void _applyFilter() {
    if (_selectedDateRange != null) {
      context.read<BookingBloc>().add(
            FilterBookingsByDateRangeEvent(
              startDate: _selectedDateRange!.start,
              endDate: _selectedDateRange!.end,
            ),
          );
    }
  }

  void _resetFilter() {
    context.read<BookingBloc>().add(GetBookingEvent());
    setState(() {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      _selectedDateRange = DateTimeRange(start: sevenDaysAgo, end: now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoaded) {
          final isFiltered = state.isFiltered;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date Range',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ColorPallete.darkBlack,
                    ),
                  ),
                  if (isFiltered)
                    TextButton(
                      onPressed: _resetFilter,
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          color: ColorPallete.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDateRange,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDateRange != null
                            ? '${_dateFormat.format(_selectedDateRange!.start)} - ${_dateFormat.format(_selectedDateRange!.end)}'
                            : 'Select date range',
                        style: TextStyle(
                          color: ColorPallete.darkGreySilver,
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        color: ColorPallete.darkGreySilver,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
