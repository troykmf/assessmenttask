import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assessment_task/models/contact.dart';
import 'package:assessment_task/services/hive_service.dart';

class AddContactScreen extends ConsumerStatefulWidget {
  const AddContactScreen({super.key});

  @override
  ConsumerState<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends ConsumerState<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final hive = ref.read(hiveServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Contact')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name input
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                // Ensure the user typed at least one character
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 20),
              // Phone input
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                // Validate that the value is digits only and length between 7–11
                validator: (v) {
                  final text = v?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  // Only digits allowed
                  if (!RegExp(r'^\d+$').hasMatch(text)) {
                    return 'Phone must be digits only';
                  }
                  if (text.length < 7 || text.length > 11) {
                    return 'Phone must be 7–11 digits';
                  }
                  return null;
                },
              ),

              const Spacer(),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // Validate form before saving
                    if (_formKey.currentState!.validate()) {
                      // Add to Hive storage
                      hive.addContact(
                        Contact(
                          name: _nameController.text.trim(),
                          phoneNumber: _phoneController.text.trim(),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'SAVE CONTACT',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
