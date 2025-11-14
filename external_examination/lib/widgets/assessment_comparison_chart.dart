import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/grade.dart';

class AssessmentComparisonChart extends StatelessWidget {
  final List<Grade> grades;
  final String assessmentType; // 'Assignment' | 'Midterm' | 'Final'
  const AssessmentComparisonChart({super.key, required this.grades, required this.assessmentType});

  @override
  Widget build(BuildContext context) {
    final byCourse = <String, Map<String, Grade?>>{}; // course -> {Sem-4, Sem-5}
    final courses = <String>{};

    for (final g in grades) {
      if (g.assessmentType != assessmentType) continue;
      final course = g.courseCode;
      final termLabel = (g.term ?? '').toLowerCase();
      final isSem4 = termLabel.contains('sem-4') || termLabel.contains('summer') || termLabel.contains('fall');
      final isSem5 = termLabel.contains('sem-5') || termLabel.contains('winter');
      if (!isSem4 && !isSem5) continue; // focus on Sem-4/Sem-5 comparison
      courses.add(course);
      final map = byCourse.putIfAbsent(course, () => {'Sem-4': null, 'Sem-5': null});
      if (isSem4) {
        // keep the most recent per term
        final existing = map['Sem-4'];
        if (existing == null || g.date.isAfter(existing.date)) map['Sem-4'] = g;
      } else if (isSem5) {
        final existing = map['Sem-5'];
        if (existing == null || g.date.isAfter(existing.date)) map['Sem-5'] = g;
      }
    }

    final palette = _palette(context);
    final sem4Color = palette[0];
    final sem5Color = palette[1];

    final sortedCourses = courses.toList()..sort();
    final groups = <BarChartGroupData>[];
    for (var i = 0; i < sortedCourses.length; i++) {
      final course = sortedCourses[i];
      final entry = byCourse[course] ?? {'Sem-4': null, 'Sem-5': null};
      final sem4Pct = (entry['Sem-4']?.percentage ?? 0).toDouble();
      final sem5Pct = (entry['Sem-5']?.percentage ?? 0).toDouble();
      groups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 6,
          barRods: [
            BarChartRodData(
              toY: sem4Pct,
              width: 10,
              borderRadius: BorderRadius.circular(4),
              color: sem4Color,
            ),
            BarChartRodData(
              toY: sem5Pct,
              width: 10,
              borderRadius: BorderRadius.circular(4),
              color: sem5Color,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$assessmentType: Sem-4 vs Sem-5',
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
                    final term = rodIndex == 0 ? 'Sem-4' : 'Sem-5';
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
            _LegendChip(label: 'Sem-4', color: sem4Color),
            _LegendChip(label: 'Sem-5', color: sem5Color),
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