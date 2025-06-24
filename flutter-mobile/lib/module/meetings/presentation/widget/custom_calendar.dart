import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/model/service_model.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

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
  final Logger _logger = Logger();
  late final List<DateTime> highlightDates;
  DateTime selectedDay = DateTime.now();
  DateTime today = DateTime.now();
  DateTime focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    highlightDates = _getHighlightDates();
  }

  List<DateTime> _getHighlightDates() {
    List<DateTime> dates = [];
    try {
      // Menggunakan dates dari JSON
      for (var dateMap in widget.service.dates) {
        final date = DateTime.parse(dateMap['date']!);
        dates.add(date);
      }
    } catch (e) {
      _logger.e('Error parsing dates: $e');
    }
    return dates;
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Implement calendar day selection with date validation
  void _onDaySelected(DateTime day, DateTime focusedDay) {
    if (highlightDates.any((d) => isSameDay(d, day))) {
      setState(() {
        selectedDay = day;
        this.focusedDay = focusedDay;
      });
      widget.onDateSelected(day);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button from closing
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      size: 32,
                    ),
                    color: ColorPallete.darkGreySilver,
                    onPressed: () => Navigator.pop(context),
                  ),
                  Spacer(),
                ],
              ),
            ),
            // Calendar Section
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pick Your Perfect Date',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: ColorPallete.darkBlack,
                        ),
                      ),
                      TableCalendar(
                        selectedDayPredicate: (day) =>
                            isSameDay(day, selectedDay),
                        firstDay: DateTime.utc(2000),
                        lastDay: DateTime.utc(2045),
                        focusedDay: focusedDay,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        pageAnimationEnabled: true,
                        pageAnimationCurve: Curves.easeInOut,
                        pageAnimationDuration:
                            const Duration(milliseconds: 300),
                        availableGestures: AvailableGestures.all,
                        calendarFormat: CalendarFormat.month,
                        enabledDayPredicate: (day) {
                          return highlightDates.any((d) => isSameDay(d, day));
                        },
                        onPageChanged: (focusDay) {
                          setState(() {
                            focusedDay = focusDay;
                          });
                        },
                        calendarStyle: CalendarStyle(
                          cellMargin: EdgeInsets.all(4),
                          cellPadding: EdgeInsets.zero,
                          todayDecoration: BoxDecoration(
                            color: ColorPallete.darkBlack,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          selectedDecoration: BoxDecoration(
                            color: ColorPallete.primary400,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          selectedTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          markerDecoration: BoxDecoration(
                            color: ColorPallete.primary400,
                            shape: BoxShape.rectangle,
                          ),
                          weekendTextStyle: TextStyle(
                            fontFamily: 'sourceSans3',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: ColorPallete.darkBlack,
                          ),
                          defaultTextStyle: TextStyle(
                            fontFamily: 'sourceSans3',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: ColorPallete.darkBlack,
                          ),
                          outsideTextStyle: TextStyle(
                            fontFamily: 'sourceSans3',
                            fontSize: 16,
                            color: ColorPallete.darkGreySilver,
                          ),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          dowTextFormatter: (date, locale) =>
                              DateFormat.E(locale).format(date).substring(0, 3),
                          weekdayStyle: TextStyle(
                            fontFamily: 'sourceSans3',
                            fontSize: 16,
                            color: ColorPallete.darkBlack,
                          ),
                          weekendStyle: TextStyle(
                            fontFamily: 'sourceSans3',
                            fontSize: 16,
                            color: ColorPallete.redCinnabar,
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          rightChevronVisible: false,
                          leftChevronVisible: false,
                          titleCentered: false,
                          headerMargin: EdgeInsets.only(
                            bottom: 8,
                            top: 8,
                            left: 8,
                          ),
                          titleTextFormatter: (date, locale) =>
                              DateFormat('MMMM yyyy', locale).format(date),
                          titleTextStyle: TextStyle(
                            fontFamily: 'sourceSans3',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ColorPallete.darkBlack,
                          ),
                        ),
                        onDaySelected: _onDaySelected,
                        calendarBuilders: CalendarBuilders(
                          dowBuilder: (context, day) {
                            final isSunday = day.weekday == DateTime.sunday;
                            return Center(
                              child: Text(
                                DateFormat.E().format(day).substring(0, 3),
                                style: TextStyle(
                                  fontFamily: 'sourceSans3',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSunday
                                      ? ColorPallete.redCinnabar
                                      : ColorPallete.darkBlack,
                                ),
                              ),
                            );
                          },
                          defaultBuilder: (context, date, _) {
                            final isToday = isSameDay(date, today);
                            final isHighlighted =
                                highlightDates.any((d) => isSameDay(d, date));
                            final isSunday = date.weekday == DateTime.sunday;
                            final isDisabled = !isHighlighted;

                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: isHighlighted
                                    ? ColorPallete.primary200
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: EdgeInsets.all(4),
                              padding: EdgeInsets.symmetric(
                                  vertical: 1, horizontal: 14),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isToday) ...[
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: isSameDay(date, selectedDay)
                                            ? ColorPallete.redCinnabar
                                            : ColorPallete.darkBlack
                                                .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Today',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isSameDay(date, selectedDay)
                                              ? Colors.white
                                              : ColorPallete.darkBlack,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                  ],
                                  Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDisabled
                                          ? ColorPallete.darkGreySilver
                                              .withOpacity(0.4)
                                          : (isSunday
                                              ? ColorPallete.redCinnabar
                                              : (isHighlighted
                                                  ? Colors.white
                                                  : ColorPallete.darkBlack)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
              child: Row(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: ColorPallete.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Selected Date',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorPallete.darkBlack,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: ColorPallete.primary200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Available Date',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorPallete.darkBlack,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: ColorPallete.darkBlack,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Today',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorPallete.darkBlack,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            // Bottom Selection Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorPallete.darkBlack.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        'Appointment date',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorPallete.darkBlack,
                        ),
                      ),
                      Spacer(),
                      Text(
                        DateFormat('E, dd MMMM yyyy').format(selectedDay),
                        style: GoogleFonts.sourceSans3(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: ColorPallete.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, selectedDay);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPallete.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: Size(double.infinity, 48),
                    ),
                    child: Text(
                      'Save',
                      style: GoogleFonts.ubuntu(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
