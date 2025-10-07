import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/member_provider.dart';
import '../providers/fee_provider.dart';
import '../models/fee_payment.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  final _currency = NumberFormat.currency(symbol: '₹');

  @override
  Widget build(BuildContext context) {
    final members = context.watch<MemberProvider>().members;
    final feeProvider = context.watch<FeeProvider>();

    if (members.isEmpty) {
      return const Center(child: Text('No members. Add members first.'));
    }

    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        final payments = feeProvider.getMemberPayments(member.id);
        return ExpansionTile(
          title: Text(member.name),
          subtitle: Text(member.planName),
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: payments.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final p = payments[i];
                return ListTile(
                  leading: Icon(
                    p.status == 'paid' ? Icons.check_circle : Icons.error,
                    color: p.status == 'paid' ? Colors.green : Colors.orange,
                  ),
                  title: Text(
                    '${_currency.format(p.amount)} • ${DateFormat.yMMMd().format(p.date)}',
                  ),
                  subtitle: Text(
                    p.dueDate != null
                        ? 'Due: ${DateFormat.yMMMd().format(p.dueDate!)}'
                        : 'No due date',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await _showPaymentDialog(
                          context,
                          member.id,
                          existing: p,
                        );
                      } else if (value == 'delete') {
                        await feeProvider.deletePayment(p.id);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _showPaymentDialog(context, member.id);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Payment'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPaymentDialog(
    BuildContext context,
    String memberId, {
    FeePayment? existing,
  }) async {
    final isEditing = existing != null;
    final amountController = TextEditingController(
      text: isEditing ? existing.amount.toString() : '',
    );
    DateTime date = isEditing ? existing.date : DateTime.now();
    DateTime? dueDate = isEditing ? existing.dueDate : null;
    String status = isEditing ? existing.status : 'paid';

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Payment' : 'Add Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => date = picked);
                        },
                        child: Text('Date: ${DateFormat.yMMMd().format(date)}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dueDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => dueDate = picked);
                        },
                        child: Text(
                          dueDate == null
                              ? 'Pick Due Date'
                              : 'Due: ${DateFormat.yMMMd().format(dueDate!)}',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  items: const [
                    DropdownMenuItem(value: 'paid', child: Text('Paid')),
                    DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
                  ],
                  onChanged: (v) => setState(() => status = v ?? 'paid'),
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount =
                    double.tryParse(amountController.text.trim()) ?? 0;
                final feeProvider = context.read<FeeProvider>();
                final payment = FeePayment(
                  id: isEditing ? existing.id : DatabaseService.generateId(),
                  memberId: memberId,
                  amount: amount,
                  date: date,
                  status: status,
                  dueDate: dueDate,
                );
                if (isEditing) {
                  await feeProvider.updatePayment(payment);
                } else {
                  await feeProvider.addPayment(payment);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
