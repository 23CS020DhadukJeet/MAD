import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/grade.dart';

class AssessmentComparisonChart extends StatelessWidget {
  final List<Grade> grades;
  final String assessmentType; // 'Assignment' | 'Midterm' | 'Final'
  const AssessmentComparisonChart({super.key, required this.grades, required this.assessmentType});

  @override
  Widget build(BuildContext context) {
    final byCourse = <String, Map<String, Grade?>>{}; // course -> {Summer, Winter}
    final courses = <String>{};

    for (final g in grades) {
      if (g.assessmentType != assessmentType) continue;
      final course = g.courseCode;
      final termLabel = (g.term ?? '').toLowerCase();
      final isSummer = termLabel.contains('summer');
      final isWinter = termLabel.contains('winter');
      if (!isSummer && !isWinter) continue; // focus on Summer/Winter comparison
      courses.add(course);
      final map = byCourse.putIfAbsent(course, () => {'Summer': null, 'Winter': null});
      if (isSummer) {
        // keep the most recent per term
        final existing = map['Summer'];
        if (existing == null || g.date.isAfter(existing.date)) map['Summer'] = g;
      } else if (isWinter) {
        final existing = map['Winter'];
        if (existing == null || g.date.isAfter(existing.date)) map['Winter'] = g;
      }
    }

    final palette = _palette(context);
    final summerColor = palette[0];
    final winterColor = palette[1];

    final sortedCourses = courses.toList()..sort();
    final groups = <BarChartGroupData>[];
    for (var i = 0; i < sortedCourses.length; i++) {
      final course = sortedCourses[i];
      final entry = byCourse[course] ?? {'Summer': null, 'Winter': null};
      final summerPct = (entry['Summer']?.percentage ?? 0).toDouble();
      final winterPct = (entry['Winter']?.percentage ?? 0).toDouble();
      groups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 6,
          barRods: [
            BarChartRodData(
              toY: summerPct,
              width: 10,
              borderRadius: BorderRadius.circular(4),
              color: summerColor,
            ),
            BarChartRodData(
              toY: winterPct,
              width: 10,
              borderRadius: BorderRadius.circular(4),
              color: winterColor,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$assessmentType: Summer vs Winter',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 240,
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: 100,
              gridData: const FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20),
              borderData: FlBorderData(show: false),
              groupsSpace: 8,
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: 20,
                    getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: const TextStyle(fontSize: 10)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i >= 0 && i < sortedCourses.length) {
                        final label = _shortCourse(sortedCourses[i]);
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(label, style: const TextStyle(fontSize: 10)),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final term = rodIndex == 0 ? 'Summer' : 'Winter';
                    return BarTooltipItem('$term: ${rod.toY.toStringAsFixed(1)}%', const TextStyle());
                  },
                ),
              ),
              barGroups: groups,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _LegendChip(label: 'Summer', color: summerColor),
            _LegendChip(label: 'Winter', color: winterColor),
          ],
        ),
      ],
    );
  }

  String _shortCourse(String code) {
    // Display a short code like "MAD" from "MAD (CSE309)" for readability.
    final idx = code.indexOf(' ');
    return idx > 0 ? code.substring(0, idx) : code;
  }

  List<Color> _palette(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return [
      scheme.primary,
      scheme.secondary,
      Colors.indigo,
      Colors.orange,
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