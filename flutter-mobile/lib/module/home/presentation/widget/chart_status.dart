// ignore_for_file: depend_on_referenced_packages

import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/model/booking_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:Appointly/module/meetings/presentation/bloc/booking_bloc.dart';

class ChartStatus extends StatelessWidget {
  const ChartStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                SizedBox(
                  height: 360,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _calculateMaxY(chartData),
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
                                padding: const EdgeInsets.only(right: 8.0),
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
                            getTitlesWidget: (double value, TitleMeta meta) {
                              final index = value.toInt();
                              if (index >= chartData.length)
                                return const SizedBox();

                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
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

  // Calculate the maximum Y value for the chart
  double _calculateMaxY(List<DailyAppointmentData> chartData) {
    double maxValue = 0;
    for (var data in chartData) {
      final total = data.approved + data.pending + data.declined;
      if (total > maxValue) {
        maxValue = total.toDouble();
      }
    }
    // Add some padding to the max value
    return maxValue > 0 ? (maxValue * 1.2) : 5;
  }

  // Get the bar groups for the chart
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

  // Process booking data to get the last 7 days
  List<DailyAppointmentData> _processDataForLastSevenDays(
    List<Booking> approved,
    List<Booking> pending,
    List<Booking> declined,
  ) {
    // Create a map to store the count for each day
    final Map<String, DailyAppointmentData> dailyData = {};

    // Get the date for the last 7 days
    final now = DateTime.now();
    final List<String> last7Days = [];
    final List<String> dayLabels = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final dayLabel = DateFormat('E d').format(date); // e.g., "Mon 5"

      last7Days.add(dateStr);
      dayLabels.add(dayLabel);

      // Initialize with zero counts
      dailyData[dateStr] = DailyAppointmentData(
        date: dateStr,
        dayLabel: dayLabel,
        approved: 0, // Initialize with zero
        pending: 0, // Initialize with zero
        declined: 0, // Initialize with zero
      );
    }

    // Count approved appointments by day
    for (var booking in approved) {
      final dateStr = _extractDateFromService(booking.service);
      if (dailyData.containsKey(dateStr)) {
        dailyData[dateStr]!.approved++;
      }
    }

    // Count pending appointments by day
    for (var booking in pending) {
      final dateStr = _extractDateFromService(booking.service);
      if (dailyData.containsKey(dateStr)) {
        dailyData[dateStr]!.pending++;
      }
    }

    // Count declined appointments by day
    for (var booking in declined) {
      final dateStr = _extractDateFromService(booking.service);
      if (dailyData.containsKey(dateStr)) {
        dailyData[dateStr]!.declined++;
      }
    }

    // Convert map to sorted list
    return last7Days.map((date) => dailyData[date]!).toList();
  }

  // Helper method to extract date from ServiceBooking
  String _extractDateFromService(ServiceBooking service) {
    try {
      // Assuming the day is already in 'yyyy-MM-dd' format
      return service.day;
    } catch (e) {
      // If there's an error, return today's date as fallback
      return DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }
}

// Data class to hold appointment counts for each day
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
