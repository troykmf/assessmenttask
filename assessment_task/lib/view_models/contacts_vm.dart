// // contact_provider.dart
import 'dart:async';
import 'package:assessment_task/models/contact.dart';
import 'package:assessment_task/services/hive_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final contactsProvider = StreamProvider<List<Contact>>((ref) {
  final hive = ref.watch(hiveServiceProvider);

  // Get initial data immediately
  final initialData = hive.getContacts();

  // Create a controller to combine initial data with stream updates
  final controller = StreamController<List<Contact>>();

  // Add initial data
  controller.add(initialData);

  // Listen to Hive changes
  final subscription = hive.watchContacts().listen((event) {
    controller.add(hive.getContacts());
  });

  // Close the controller when the provider is disposed
  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});
