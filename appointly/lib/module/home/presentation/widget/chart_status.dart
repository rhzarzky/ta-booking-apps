import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:appointly/core/theme/color_pallete.dart';

class ChartStatus extends StatelessWidget {
  const ChartStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Legend Row
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
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
                maxY: 24,
                barGroups: _getBarGroups(),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final labels =
                            List.generate(7, (index) => 'Day ${index + 1}');
                        final index = value.toInt();
                        if (index >= labels.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            labels[index],
                            style: const TextStyle(fontSize: 12),
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

  List<BarChartGroupData> _getBarGroups() {
    return List.generate(7, (index) {
      // Now generating 7 bars
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (index + 1) * 2.0,
            color: ColorPallete.primaryColor,
            width: 12,
          ),
          BarChartRodData(
            toY: (index + 2) * 1.0,
            color: ColorPallete.accentColor,
            width: 12,
          ),
          BarChartRodData(
            toY: (index + 1) * 2.0,
            color: ColorPallete.greySilverChalice950,
            width: 12,
          ),
        ],
      );
    });
  }
}
