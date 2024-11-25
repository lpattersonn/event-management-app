import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String name;
  final String description;
  final DateTime date;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
  });

  factory Event.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Event(
      id: documentId,
      name: data['name'],
      description: data['description'],
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'date': date,
    };
  }
}
