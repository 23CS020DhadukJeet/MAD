import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grade_provider.dart';

class CourseGradesScreen extends StatelessWidget {
  const CourseGradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GradeProvider>();
    final grades = p.filteredGrades();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by course or assessment'),
                  onChanged: p.setSearch,
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: p.termFilter ?? 'All',
                items: ['All', ...p.allTerms]
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: p.setTermFilter,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: grades.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final g = grades[i];
              return ListTile(
                leading: CircleAvatar(child: Text((g.percentage).toStringAsFixed(0))),
                title: Text('${g.courseCode} • ${g.assessmentType}'),
                subtitle: Text('${g.obtainedMarks}/${g.maxMarks} • ${g.term ?? 'Term'} • ${g.displayDate}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'delete') {
                      context.read<GradeProvider>().deleteGrade(g.id!);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}