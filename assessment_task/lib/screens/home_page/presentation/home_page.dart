import 'dart:io';

import 'package:assessment_task/screens/home_page/widgets/contacts_card_widget.dart';
import 'package:assessment_task/view_models/contacts_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assessment_task/models/contact.dart';
import 'package:assessment_task/services/hive_service.dart';
import 'package:assessment_task/services/notification_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get providers for contacts data, Hive operations, and notifications
    final contacts = ref.watch(contactsProvider);
    final hive = ref.read(hiveServiceProvider);
    final notifications = ref.read(notificationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          // Clear all contacts button
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => hive.clearContacts(),
          ),
        ],
      ),
      body: contacts.when(
        loading:
            () => const Center(
              child: CircularProgressIndicator(),
            ), // loading state
        error: (err, _) => Center(child: Text('Error: $err')), // error state
        // Data loaded state
        data:
            (contacts) =>
                contacts.isEmpty
                    ? _buildEmptyState() // Show empty state UI
                    : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: contacts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      // Build each contact card
                      itemBuilder:
                          (_, i) => ContactCard(
                            contact: contacts[i],
                            onDelete: () => hive.deleteContact(contacts[i]),
                            onRemind:
                                () => _scheduleReminder(
                                  context,
                                  notifications,
                                  contacts[i],
                                ),
                          ),
                    ),
      ),
      // button to add new contacts
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/add'),
      ),
    );
  }

  // Builds the empty state UI when no contacts exist
  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.contacts, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          'No Contacts Found\nTap + to add your first contact!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      ],
    ),
  );

  // Schedules a reminder notification for the contact
  //   Future<void> _scheduleReminder(
  //     BuildContext context,
  //     NotificationService service,
  //     Contact contact,
  //   ) async {
  //     try {
  //       await service.scheduleReminder(contact);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: const Text('Reminder set! Notification in 1 minute ⏰'),
  //           backgroundColor: Colors.green[800],
  //           duration: const Duration(seconds: 2),
  //         ),
  //       );
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error: ${e.toString()}'),
  //           backgroundColor: Colors.red[800],
  //         ),
  //       );
  //     }
  //   }
  Future<void> _scheduleReminder(
    BuildContext context,
    NotificationService service,
    Contact contact,
  ) async {
    try {
      // Check if Android and request permissions
      if (Platform.isAndroid) {
        final status = await service.requestPermissions();
        if (!status) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification permission denied'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      await service.scheduleReminder(contact);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder set! Check notifications in 1 minute'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to set reminder: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
