import 'package:assessment_task/models/contact.dart';
import 'package:flutter/material.dart';

class ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onDelete;
  final Future<void> Function() onRemind;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onDelete,
    required this.onRemind,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(contact.name, style: const TextStyle(fontSize: 18)),
        subtitle: Text(contact.phoneNumber),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.notification_add),
              onPressed: () async {
                await onRemind();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
