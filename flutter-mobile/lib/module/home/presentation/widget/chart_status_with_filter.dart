// ignore_for_file: depend_on_referenced_packages

import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/model/booking_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Appointly/module/meetings/presentation/bloc/booking_bloc.dart';

class ChartStatusWithFilter extends StatefulWidget {
  const ChartStatusWithFilter({super.key});

  @override
  State<ChartStatusWithFilter> createState() => _ChartStatusWithFilterState();
}

class _ChartStatusWithFilterState extends State<ChartStatusWithFilter> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  final List<int> _availableYears = [
    DateTime.now().year - 1,
    DateTime.now().year,
    DateTime.now().year + 1
  ];
  @override
  void initState() {
    super.initState();
    // Don't automatically refresh data on init to avoid multiple calls
    // The parent HomeScreen already calls GetBookingEvent
  }

  void _refreshData() {
    context.read<BookingBloc>().add(GetBookingEvent(
          month: _selectedMonth,
          year: _selectedYear,
        ));
  }

  @override
  Widget build(BuildContext context) {
    // Check if there's already a filtered state in the BLoC
    final currentState = context.read<BookingBloc>().state;
    if (currentState is BookingLoaded &&
        currentState.month != null &&
        currentState.year != null) {
      // Update local state to match BLoC state without triggering a refresh
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            (_selectedMonth != currentState.month ||
                _selectedYear != currentState.year)) {
          setState(() {
            _selectedMonth = currentState.month!;
            _selectedYear = currentState.year!;
          });
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Insights',
              style: GoogleFonts.ubuntu(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ColorPallete.darkBlack,
              ),
            ),
            _buildFilterBar(),
          ],
        ),
        const SizedBox(height: 16),
        _buildChart(),
      ],
    );
  }

  Widget _buildFilterBar() {
    return LayoutBuilder(builder: (context, constraints) {
      final isSmallScreen = constraints.maxWidth < 180;

      return Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        alignment: WrapAlignment.end,
        children: [
          // Month Dropdown
          Container(
            constraints:
                BoxConstraints(maxWidth: isSmallScreen ? double.infinity : 120),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: ColorPallete.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: ColorPallete.primaryColor.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: _selectedMonth,
                isDense: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: ColorPallete.primaryColor, size: 16),
                items: List.generate(12, (index) {
                  final month = index + 1;
                  return DropdownMenuItem<int>(
                    value: month,
                    child: Text(
                      isSmallScreen
                          ? DateFormat('MMM')
                              .format(DateTime(DateTime.now().year, month))
                          : DateFormat('MMMM')
                              .format(DateTime(DateTime.now().year, month)),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ColorPallete.darkBlack,
                      ),
                    ),
                  );
                }),
                onChanged: (int? value) {
                  if (value != null) {
                    setState(() {
                      _selectedMonth = value;
                    });
                    // Refresh data only when user explicitly changes the filter
                    _refreshData();
                  }
                },
              ),
            ),
          ),
          // Year Dropdown
          Container(
            constraints:
                BoxConstraints(maxWidth: isSmallScreen ? double.infinity : 80),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: ColorPallete.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: ColorPallete.primaryColor.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: _selectedYear,
                isDense: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: ColorPallete.primaryColor, size: 16),
                items: _availableYears.map((year) {
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(
                      year.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ColorPallete.darkBlack,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (int? value) {
                  if (value != null) {
                    setState(() {
                      _selectedYear = value;
                    });
                    // Refresh data only when user explicitly changes the filter
                    _refreshData();
                  }
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildChart() {
    return BlocBuilder<BookingBloc, BookingState>(
      buildWhen: (previous, current) {
        // Only rebuild when the state changes from something else to BookingLoaded
        // or when changing between different BookingLoaded states
        return current is BookingLoaded;
      },
      builder: (context, state) {
        if (state is BookingLoaded) {
          // Extract the data from the state
          final approved = state.approved;
          final pending = state.pending;
          final declined = state.declined;

          // Process data for chart
          final chartData =
              _processDataForLastSevenDays(approved, pending, declined);

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Legend Row
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Wrap(
                    alignment: WrapAlignment.spaceAround,
                    spacing: 16.0,
                    runSpacing: 8.0,
                    children: [
                      _buildLegendItem(
                        color: ColorPallete.primaryColor,
                        text: 'Approved',
                      ),
                      _buildLegendItem(
                        color: ColorPallete.accentColor,
                        text: 'Under Review',
                      ),
                      _buildLegendItem(
                        color: ColorPallete.greySilverChalice950,
                        text: 'Declined',
                      ),
                    ],
                  ),
                ),
                // Chart
                LayoutBuilder(
                  builder: (context, constraints) {
                    final chartWidth = constraints.maxWidth < 400
                        ? 400.0
                        : constraints.maxWidth;
                    return SizedBox(
                      height: 360,
                      width: constraints.maxWidth,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: SizedBox(
                          width: chartWidth,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              barGroups: _getBarGroups(chartData),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                    reservedSize: 30,
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget:
                                        (double value, TitleMeta meta) {
                                      final index = value.toInt();
                                      if (index >= chartData.length) {
                                        return const SizedBox();
                                      }

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          chartData[index].dayLabel,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }

        // Show loading indicator if data is not yet loaded
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildLegendItem({required Color color, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _getBarGroups(List<DailyAppointmentData> chartData) {
    return List.generate(chartData.length, (index) {
      final data = chartData[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.approved.toDouble(),
            color: ColorPallete.primaryColor,
            width: 12,
          ),
          BarChartRodData(
            toY: data.pending.toDouble(),
            color: ColorPallete.accentColor,
            width: 12,
          ),
          BarChartRodData(
            toY: data.declined.toDouble(),
            color: ColorPallete.greySilverChalice950,
            width: 12,
          ),
        ],
      );
    });
  }

  List<DailyAppointmentData> _processDataForLastSevenDays(
    List<Booking> approved,
    List<Booking> pending,
    List<Booking> declined,
  ) {
    final Map<String, DailyAppointmentData> dailyData = {};

    // Calculate the first and last day of the selected month/year
    final DateTime firstDayOfMonth = DateTime(_selectedYear, _selectedMonth, 1);
    final DateTime lastDayOfMonth =
        DateTime(_selectedYear, _selectedMonth + 1, 0);

    // If it's the current month, only show until today
    final DateTime now = DateTime.now();
    DateTime endDate = lastDayOfMonth;
    if (_selectedYear == now.year && _selectedMonth == now.month) {
      endDate = now;
    }

    // Get days to display in the chart (up to 7 days)
    final List<DateTime> daysToShow = [];
    final int daysInMonth = endDate.difference(firstDayOfMonth).inDays + 1;
    final int start = daysInMonth > 7 ? daysInMonth - 7 : 0;

    for (int i = start; i < daysInMonth; i++) {
      daysToShow.add(firstDayOfMonth.add(Duration(days: i)));
    }

    // Initialize daily data
    final List<String> dayKeys = [];

    for (DateTime day in daysToShow) {
      final dateStr = DateFormat('yyyy-MM-dd').format(day);
      final dayLabel = DateFormat('E d').format(day);
      dayKeys.add(dateStr);

      dailyData[dateStr] = DailyAppointmentData(
        date: dateStr,
        dayLabel: dayLabel,
        approved: 0,
        pending: 0,
        declined: 0,
      );
    }

    // Populate data
    for (var booking in approved) {
      final dateStr = booking.date;
      if (dailyData.containsKey(dateStr)) {
        dailyData[dateStr]!.approved++;
      }
    }

    for (var booking in pending) {
      final dateStr = booking.date;
      if (dailyData.containsKey(dateStr)) {
        dailyData[dateStr]!.pending++;
      }
    }

    for (var booking in declined) {
      final dateStr = booking.date;
      if (dailyData.containsKey(dateStr)) {
        dailyData[dateStr]!.declined++;
      }
    }

    return dayKeys.map((date) => dailyData[date]!).toList();
  }
}

class DailyAppointmentData {
  final String date;
  final String dayLabel;
  int approved;
  int pending;
  int declined;

  DailyAppointmentData({
    required this.date,
    required this.dayLabel,
    this.approved = 0,
    this.pending = 0,
    this.declined = 0,
  });
}
