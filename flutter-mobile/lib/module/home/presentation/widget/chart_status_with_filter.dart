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

    // Initialize with the current date
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  void _refreshData() {
    // Get current state to check what's currently loaded
    final currentState = context.read<BookingBloc>().state;

    // Log for debugging
    if (currentState is BookingLoaded) {
      if (currentState.month == _selectedMonth &&
          currentState.year == _selectedYear) {
        return; // Tidak perlu refresh jika sudah menampilkan bulan/tahun yang sama
      }
    }

    // Request fresh data from the API with the selected month/year
    context.read<BookingBloc>().add(GetBookingEvent(
          month: _selectedMonth,
          year: _selectedYear,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listenWhen: (previous, current) {
        // Only trigger listener when BookingLoaded states have different month/year
        if (previous is BookingLoaded && current is BookingLoaded) {
          return (previous.month != current.month ||
              previous.year != current.year);
        }
        return previous.runtimeType != current.runtimeType;
      },
      listener: (context, state) {
        if (state is BookingLoaded &&
            state.month != null &&
            state.year != null) {
          // Always update local state to match BLoC state when data changes
          setState(() {
            _selectedMonth = state.month!;
            _selectedYear = state.year!;
          });
        }
      },
      child: Column(
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
          const SizedBox(height: 8),
          _buildChart(),
        ],
      ),
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
                  if (value != null && value != _selectedMonth) {
                    setState(() {
                      _selectedMonth = value;
                    });

                    // Add a small delay to ensure setState completes
                    Future.microtask(() {
                      // Make sure we're still mounted
                      if (mounted) {
                        // Refresh data immediately when month changes
                        _refreshData();
                      }
                    });
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
                  if (value != null && value != _selectedYear) {
                    setState(() {
                      _selectedYear = value;
                    });
                    // Add a small delay to ensure setState completes
                    Future.microtask(() {
                      // Make sure we're still mounted
                      if (mounted) {
                        // Refresh data immediately when year changes
                        _refreshData();
                      }
                    });
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
        // Always rebuild when the state type changes (loading -> loaded)
        if (previous.runtimeType != current.runtimeType) {
          return true;
        }

        // Rebuild when BookingLoaded state changes relevant data
        if (current is BookingLoaded && previous is BookingLoaded) {
          final shouldRebuild = previous.month != current.month ||
              previous.year != current.year ||
              previous.approved.length != current.approved.length ||
              previous.pending.length != current.pending.length ||
              previous.declined.length != current.declined.length;

          if (shouldRebuild) {
            print('Data changed, rebuilding chart: '
                'Month: ${previous.month} -> ${current.month}, '
                'Year: ${previous.year} -> ${current.year}');
          }

          return shouldRebuild;
        }
        return false;
      },
      builder: (context, state) {
        if (state is BookingLoaded) {
          // Selalu gunakan month/year dari state karena itu adalah sumber kebenaran data
          final int displayMonth = state.month ?? _selectedMonth;
          final int displayYear = state.year ?? _selectedYear;

          // Pastikan nilai lokal selalu sinkron dengan state
          // Ini dapat menyelesaikan masalah dropdown tidak berubah
          if (displayMonth != _selectedMonth || displayYear != _selectedYear) {
            // Gunakan Future.microtask agar setState tidak berjalan di tengah build
            Future.microtask(() {
              if (mounted) {
                setState(() {
                  _selectedMonth = displayMonth;
                  _selectedYear = displayYear;
                });
              }
            });
          }

          // Extract the data from the state
          final approved = state.approved;
          final pending = state.pending;
          final declined = state.declined;

          // Process data for chart using the month/year from state
          final chartData =
              _processDataForLastSevenDays(approved, pending, declined);

          // Format the period label using the source of truth (state)
          final String currentPeriod = DateFormat('MMMM yyyy').format(
            DateTime(displayYear, displayMonth),
          ); // Create a key that changes when either selected or state month/year changes, forcing a full rebuild
          final String chartKey =
              'chart-$displayMonth-$displayYear-selected-$_selectedMonth-$_selectedYear';

          return Padding(
            key: Key(chartKey),
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                // Current Month/Year Display
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
                      height: 320,
                      width: constraints.maxWidth,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: SizedBox(
                          width: chartWidth,
                          child: BarChart(
                            BarChartData(
                              minY: 0,
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
                                    reservedSize: 40,
                                    interval: 1,
                                    getTitlesWidget:
                                        (double value, TitleMeta meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: ColorPallete.darkBlack,
                                        ),
                                      );
                                    },
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
    // Get current state - ALWAYS use state data as source of truth
    final currentState = context.read<BookingBloc>().state;
    int monthToUse, yearToUse;

    if (currentState is BookingLoaded &&
        currentState.month != null &&
        currentState.year != null) {
      // Selalu gunakan month/year dari state karena data yang kita proses berasal dari state
      monthToUse = currentState.month!;
      yearToUse = currentState.year!;
    } else {
      // Fallback ke selected values (seharusnya tidak terjadi)
      monthToUse = _selectedMonth;
      yearToUse = _selectedYear;
    }

    final Map<String, DailyAppointmentData> dailyData = {};

    // Calculate the first and last day of the selected month/year
    final DateTime firstDayOfMonth = DateTime(yearToUse, monthToUse, 1);
    final DateTime lastDayOfMonth = DateTime(yearToUse, monthToUse + 1,
        0); // If it's the current month, only show until today
    final DateTime now = DateTime.now();
    DateTime endDate = lastDayOfMonth;
    if (yearToUse == now.year && monthToUse == now.month) {
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
    } // Populate data - filter bookings to only include the selected month and year    // Debug all dates for troubleshooting

    // Debug first few approved bookings
    if (approved.isNotEmpty) {
      final sampleBooking = approved.first;
      try {
        final date = DateTime.parse(sampleBooking.date);
        print(
            'Sample approved booking: Date=${sampleBooking.date}, parsed month=${date.month}, year=${date.year}');
      } catch (e) {
        print('Error parsing sample booking date: ${sampleBooking.date}');
      }
    }

    for (var booking in approved) {
      final dateStr = booking.date;
      try {
        final bookingDate = DateTime.parse(dateStr);
        // Only count bookings from the selected month and year
        if (bookingDate.month == monthToUse &&
            bookingDate.year == yearToUse &&
            dailyData.containsKey(dateStr)) {
          dailyData[dateStr]!.approved++;
        }
      } catch (e) {
        print('Error parsing approved booking date: $dateStr');
      }
    }

    for (var booking in pending) {
      final dateStr = booking.date;
      try {
        final bookingDate = DateTime.parse(dateStr);
        // Only count bookings from the selected month and year
        if (bookingDate.month == monthToUse &&
            bookingDate.year == yearToUse &&
            dailyData.containsKey(dateStr)) {
          dailyData[dateStr]!.pending++;
        }
      } catch (e) {
        print('Error parsing pending booking date: $dateStr');
      }
    }

    for (var booking in declined) {
      final dateStr = booking.date;
      try {
        final bookingDate = DateTime.parse(dateStr);
        // Only count bookings from the selected month and year
        if (bookingDate.month == monthToUse &&
            bookingDate.year == yearToUse &&
            dailyData.containsKey(dateStr)) {
          dailyData[dateStr]!.declined++;
        }
      } catch (e) {
        print('Error parsing declined booking date: $dateStr');
      }
    }

    return dayKeys.map((date) => dailyData[date]!).toList();
  }
  // Helper method to filter bookings by the selected month and year
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
