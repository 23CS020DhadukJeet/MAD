import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/grade.dart';

class GradeChart extends StatelessWidget {
  final List<Grade> grades;
  const GradeChart({super.key, required this.grades});

  @override
  Widget build(BuildContext context) {
    final sorted = List.of(grades)..sort((a, b) => a.date.compareTo(b.date));
    final primary = Theme.of(context).colorScheme.primary;
    final barGroups = <BarChartGroupData>[];
    for (var i = 0; i < sorted.length; i++) {
      final y = sorted[i].percentage;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: y,
              width: 14,
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(
                colors: [primary.withOpacity(0.85), primary.withOpacity(0.35)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: 100,
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i >= 0 && i < sorted.length) {
                  final label = sorted[i].assessmentType;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(label, style: const TextStyle(fontSize: 10)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}', style: const TextStyle(fontSize: 10));
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20),
        borderData: FlBorderData(show: false),
        groupsSpace: 8,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem('${rod.toY.toStringAsFixed(1)}%', const TextStyle()),
          ),
        ),
        barGroups: barGroups,
      ),
    );
  }
}