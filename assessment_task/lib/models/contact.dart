// contact.dart
import 'package:hive/hive.dart';

part 'contact.g.dart'; // Changed from 'hive.g.dart'

@HiveType(typeId: 0)
class Contact extends HiveObject { // Added HiveObject extension
  @HiveField(0)
  final String name;
  
  @HiveField(1)
  final String phoneNumber;

  Contact({required this.name, required this.phoneNumber});
}