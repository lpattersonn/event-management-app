import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch all events from Firestore
  Stream<List<Event>> getEvents() {
    return _db
        .collection('events')
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Add a new event to Firestore
  Future<void> addEvent(Event event) async {
    await _db.collection('events').add(event.toMap());
  }

  // Update an existing event
  Future<void> updateEvent(Event event) async {
    await _db.collection('events').doc(event.id).update(event.toMap());
  }

  // Delete an event from Firestore
  Future<void> deleteEvent(String eventId) async {
    await _db.collection('events').doc(eventId).delete();
  }
}
