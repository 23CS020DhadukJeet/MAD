import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/member_provider.dart';
import '../providers/attendance_provider.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final members = context.watch<MemberProvider>().members;
    final attendanceProvider = context.watch<AttendanceProvider>();

    if (members.isEmpty) {
      return const Center(child: Text('No members. Add members first.'));
    }

    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        final m = members[index];
        final records = attendanceProvider.getMemberAttendance(m.id);
        return ExpansionTile(
          title: Text(m.name),
          children: [
            Row(
              children: [
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
                    if (picked != null) {
                      await attendanceProvider.markAttendance(m.id, picked, true);
                    }
                  },
                  child: const Text('Mark Present'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
                    if (picked != null) {
                      await attendanceProvider.markAttendance(m.id, picked, false);
                    }
                  },
                  child: const Text('Mark Absent'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final r = records[i];
                return ListTile(
                  leading: Icon(r.present ? Icons.check_circle : Icons.cancel, color: r.present ? Colors.green : Colors.red),
                  title: Text(DateFormat.yMMMd().format(r.date)),
                  subtitle: Text(r.present ? 'Present' : 'Absent'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'toggle') {
                        await context.read<AttendanceProvider>().markAttendance(m.id, r.date, !r.present);
                      } else if (value == 'delete') {
                        await context.read<AttendanceProvider>().deleteAttendance(r.id);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'toggle', child: Text('Toggle Present/Absent')),
                      PopupMenuItem(value: 'delete', child: Text('Delete Record')),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}