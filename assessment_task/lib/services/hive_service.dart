import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:assessment_task/models/contact.dart';

class HiveService {
  // Singleton instance setup
  static final HiveService _instance = HiveService._internal();

  // Hive box to store Contact objects
  late Box<Contact> _contactsBox;

  // Factory constructor to return the singleton instance
  factory HiveService() => _instance;
  HiveService._internal();

  // Initialization method to initialize HiveService
  static Future<void> init() async {
    // Get application documents directory for Hive storage
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ContactAdapter());
    }

    // Open contacts box to store contacts
    _instance._contactsBox = await Hive.openBox<Contact>('contacts');
  }

  // Get all contacts from the box
  List<Contact> getContacts() => _contactsBox.values.toList();

  // Add a new contact to the box
  Future<void> addContact(Contact contact) => _contactsBox.add(contact);

  // Clear all contacts from the box
  Future<void> clearContacts() => _contactsBox.clear();

  // Delete a specific contact from the box
  Future<void> deleteContact(Contact contact) => contact.delete();

  // Watch for changes in the contacts box
  Stream<BoxEvent> watchContacts() => _contactsBox.watch();
}

final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());
