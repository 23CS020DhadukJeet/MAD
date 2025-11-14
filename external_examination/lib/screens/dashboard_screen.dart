// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grade_provider.dart';
import '../widgets/grade_chart.dart';
import '../widgets/aggregate_chart.dart';
import '../widgets/deadline_countdown.dart';
import '../models/grade.dart';
import '../widgets/assessment_comparison_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GradeProvider>();
    final nearest = p.nearestDeadline();

    return RefreshIndicator(
      onRefresh: () async => p.initialize(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overall GPA',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.overallGpa.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (nearest != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DeadlineCountdown(deadline: nearest),
              ),
            ),
          const SizedBox(height: 12),
          Text('Term-wise GPA', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: p.gpaByTerm.entries
                .map(
                  (e) => Chip(
                    label: Text('${e.key}: ${e.value.toStringAsFixed(2)}'),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text('Recent Grades', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...p.recentGrades.map(
            (g) => ListTile(
              leading: CircleAvatar(
                child: Text(
                  g.courseCode.characters.take(2).toString().toUpperCase(),
                ),
              ),
              title: Text('${g.courseCode} — ${g.assessmentType}'),
              subtitle: Text(
                '${g.obtainedMarks}/${g.maxMarks} • ${g.displayDate}',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Course Trends & Comparison',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: AggregateCourseChart(seriesByCourse: _courseGroups(p)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Assessment Comparisons',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: AssessmentComparisonChart(
                grades: p.grades,
                assessmentType: 'Assignment',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: AssessmentComparisonChart(
                grades: p.grades,
                assessmentType: 'Midterm',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: AssessmentComparisonChart(
                grades: p.grades,
                assessmentType: 'Final',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Grade>> _courseGroups(GradeProvider p) {
    final map = <String, List<Grade>>{};
    for (final g in p.grades) {
      map.putIfAbsent(g.courseCode, () => <Grade>[]).add(g);
    }
    return map;
  }
}
