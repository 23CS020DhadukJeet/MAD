import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/member_provider.dart';
import '../models/member.dart';
import '../services/database_service.dart';

class RegisterScreen extends StatefulWidget {
  final Member? existingMember;
  const RegisterScreen({super.key, this.existingMember});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _planController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _planStart;
  DateTime? _planEnd;

  @override
  void initState() {
    super.initState();
    final m = widget.existingMember;
    if (m != null) {
      _nameController.text = m.name;
      _phoneController.text = m.phone;
      _emailController.text = m.email ?? '';
      _planController.text = m.planName ?? '';
      _notesController.text = m.notes ?? '';
      _planStart = m.planStartDate;
      _planEnd = m.planEndDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _planController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? (_planStart ?? DateTime.now()) : (_planEnd ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _planStart = picked;
        } else {
          _planEnd = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<MemberProvider>();
    final isEdit = widget.existingMember != null;

    final member = Member(
      id: isEdit ? widget.existingMember!.id : DatabaseService.generateId(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      planName: _planController.text.trim(),
      planStartDate: _planStart,
      planEndDate: _planEnd,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (isEdit) {
      await provider.updateMember(member);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member updated')));
        Navigator.pop(context);
      }
    } else {
      await provider.addMember(member);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member added')));
        // Clear form for next entry
        _formKey.currentState!.reset();
        _nameController.clear();
        _phoneController.clear();
        _emailController.clear();
        _planController.clear();
        _notesController.clear();
        setState(() {
          _planStart = null;
          _planEnd = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingMember != null;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isEdit ? 'Edit Member' : 'Register Member', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone)),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter phone' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email (optional)', prefixIcon: Icon(Icons.email)),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _planController,
                      decoration: const InputDecoration(labelText: 'Plan (e.g., Monthly, Yearly)', prefixIcon: Icon(Icons.card_membership)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickDate(isStart: true),
                            icon: const Icon(Icons.date_range),
                            label: Text(_planStart == null ? 'Plan Start' : _planStart!.toLocal().toString().split(' ').first),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickDate(isStart: false),
                            icon: const Icon(Icons.event),
                            label: Text(_planEnd == null ? 'Plan End' : _planEnd!.toLocal().toString().split(' ').first),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Notes (optional)', prefixIcon: Icon(Icons.note)),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.save),
                        label: Text(isEdit ? 'Save Changes' : 'Register'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}