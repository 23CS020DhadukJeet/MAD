import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/member_provider.dart';
import 'register_screen.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MemberProvider>(
      builder: (context, memberProvider, _) {
        final members = memberProvider.members;
        if (members.isEmpty) {
          return const Center(
            child: Text('No members yet. Add some from Register tab.'),
          );
        }
        return ListView.separated(
          itemCount: members.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final m = members[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(m.name),
              subtitle: Text('${m.planName} • ${m.phone}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RegisterScreen(existingMember: m),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await memberProvider.deleteMember(m.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Member deleted')),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
