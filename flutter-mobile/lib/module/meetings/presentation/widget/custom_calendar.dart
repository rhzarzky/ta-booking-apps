import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/model/service_model.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:convert/convert.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCalendar extends StatefulWidget {
  final Service service;
  final ValueChanged<DateTime> onDateSelected;

  const CustomCalendar({
    super.key,
    required this.service,
    required this.onDateSelected,
  });

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late final List<DateTime> highlightDates;
  final DateTime today = DateTime.now();

  @override
  void initState() {
    super.initState();
    highlightDates = generateDateRange(
      startDate: widget.service.startDate,
      endDate: widget.service.endDate,
      activeDays: widget.service.days,
    );
  }

  // Fungsi untuk menghasilkan daftar tanggal berdasarkan rentang dan hari aktif
  List<DateTime> generateDateRange({
    required String startDate,
    required String endDate,
    required List<String> activeDays,
  }) {
    List<DateTime> dates = [];

    try {
      // Parse tanggal mulai dan akhir
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);

      // Mapping nama hari ke index hari (0 = Minggu, 1 = Senin, dst)
      final Map<String, int> dayToIndex = {
        'Sunday': DateTime.sunday,
        'Monday': DateTime.monday,
        'Tuesday': DateTime.tuesday,
        'Wednesday': DateTime.wednesday,
        'Thursday': DateTime.thursday,
        'Friday': DateTime.friday,
        'Saturday': DateTime.saturday,
      };

      // Konversi nama hari ke index
      final List<int> activeWeekdays = activeDays
          .map((day) => dayToIndex[day] ?? -1)
          .where((day) => day != -1)
          .toList();

      // Jika tidak ada hari aktif, kembalikan list kosong
      if (activeWeekdays.isEmpty) return [];

      // Iterate dari tanggal mulai sampai tanggal akhir
      for (DateTime date = start;
          date.isBefore(end) || date.isAtSameMomentAs(end);
          date = date.add(Duration(days: 1))) {
        // Cek apakah hari ini adalah hari aktif
        if (activeWeekdays.contains(date.weekday)) {
          dates.add(date);
        }
      }
    } catch (e) {
      print('Error generating date range: $e');
    }

    return dates;
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Implement calendar day selection
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // Panggil callback dari parent widget
    widget.onDateSelected(selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: 
        
        TableCalendar(
          firstDay: DateTime.utc(2020),
          lastDay: DateTime.utc(2030),
          focusedDay: today,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: const HeaderStyle(formatButtonVisible: false),
          // Tambahkan callback untuk pemilihan tanggal
          onDaySelected: _onDaySelected,
          selectedDayPredicate: (day) {
            return isSameDay(day, today);
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, date, _) {
              final isToday = isSameDay(date, today);
              final isHighlighted =
                  highlightDates.any((d) => isSameDay(d, date));

              return Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:
                      isHighlighted ? Colors.blueAccent.withOpacity(0.8) : null,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      isToday ? Border.all(color: Colors.red, width: 2) : null,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isHighlighted ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isToday)
                        const Text(
                          'Hari ini',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
