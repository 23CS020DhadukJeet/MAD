// ignore_for_file: unused_local_variable, dead_code

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/grade.dart';

class AggregateCourseChart extends StatelessWidget {
  final Map<String, List<Grade>> seriesByCourse;
  const AggregateCourseChart({super.key, required this.seriesByCourse});

  @override
  Widget build(BuildContext context) {
    // Build a sorted unique timeline of dates across all grades
    final allGrades = seriesByCourse.values.expand((v) => v).toList();
    allGrades.sort((a, b) => a.date.compareTo(b.date));
    final uniqueDates = <DateTime>[];
    for (final g in allGrades) {
      if (uniqueDates.isEmpty || uniqueDates.last != _day(g.date)) {
        uniqueDates.add(_day(g.date));
      }
    }

    // Precompute color palette
    final palette = _palette(context);
    final bars = <LineChartBarData>[];
    var colorIndex = 0;

    for (final entry in seriesByCourse.entries) {
      final course = entry.key;
      final grades = List.of(entry.value)
        ..sort((a, b) => a.date.compareTo(b.date));

      final byDay = <DateTime, List<double>>{};
      for (final g in grades) {
        final d = _day(g.date);
        byDay.putIfAbsent(d, () => <double>[]).add(g.percentage);
      }

      final spots = <FlSpot>[];
      for (var i = 0; i < uniqueDates.length; i++) {
        final d = uniqueDates[i];
        final vals = byDay[d];
        if (vals != null && vals.isNotEmpty) {
          final avg = vals.reduce((a, b) => a + b) / vals.length;
          spots.add(FlSpot(i.toDouble(), avg));
        }
      }

      if (spots.isNotEmpty) {
        final color = palette[colorIndex % palette.length];
        colorIndex++;
        bars.add(
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Percentage by Date',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 240,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 100,
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i >= 0 && i < uniqueDates.length) {
                        final d = uniqueDates[i];
                        final label = '${d.month}/${d.day}';
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
              lineBarsData: bars,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < seriesByCourse.keys.length; i++)
              _LegendChip(
                label: seriesByCourse.keys.elementAt(i),
                color: palette[i % palette.length],
              ),
          ],
        ),
      ],
    );
  }

  DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  List<Color> _palette(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return [
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      Colors.orange,
      Colors.indigo,
      Colors.pink,
      Colors.green,
      Colors.brown,
    ];
  }
}

class _LegendChip extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      avatar: CircleAvatar(backgroundColor: color, radius: 8),
    );
  }
}
