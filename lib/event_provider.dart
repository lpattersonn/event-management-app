import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventProvider with ChangeNotifier {
  String _selectedEventType = 'All'; // Default to 'All'
  List<String> eventTypes = ['All', 'Conference', 'Workshop', 'Webinar'];

  List<Map<String, dynamic>> _events = [];
  String? _errorMessage;

  // Getter for events
  List<Map<String, dynamic>> get events => _events;

  // Getter for selected event type
  String get selectedEventType => _selectedEventType;

  // Getter for error message
  String? get errorMessage => _errorMessage;

  // Set a new event type and notify listeners
  void setEventType(String type) {
    _selectedEventType = type;
    notifyListeners(); // Notify listeners to rebuild UI
  }

  // Reference to Firestore collection
  final CollectionReference eventsCollection = FirebaseFirestore.instance.collection('events');

  // Function to fetch events from Firestore with real-time updates
  Stream<List<Map<String, dynamic>>> getEvents() {
    Query query = eventsCollection.orderBy('date', descending: true);
    if (_selectedEventType != 'All') {
      query = query.where('eventType', isEqualTo: _selectedEventType);
    }

    return query.snapshots().map((snapshot) {
      _events = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID to the data map
        return data;
      }).toList();

      return _events;
    });
  }

  // Add a new event to Firestore
  Future<void> addEvent(Map<String, dynamic> eventData) async {
    try {
      // Add new event to Firestore
      DocumentReference docRef = await eventsCollection.add(eventData);
      eventData['id'] = docRef.id; // Add the document ID to the event data
      _events.insert(0, eventData); // Add event to the list in provider
      notifyListeners(); // Notify listeners to update UI
    } catch (e) {
      _errorMessage = "Error adding event: $e";
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  // Update an existing event in Firestore
  Future<void> updateEvent(String eventId, Map<String, dynamic> updatedData) async {
    try {
      // Update event in Firestore
      await eventsCollection.doc(eventId).update(updatedData);
      // Update the local list of events
      int index = _events.indexWhere((event) => event['id'] == eventId);
      if (index != -1) {
        _events[index] = {..._events[index], ...updatedData}; // Merge updated data
        notifyListeners(); // Notify listeners to update UI
      }
    } catch (e) {
      _errorMessage = "Error updating event: $e";
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  // Remove event from the list
  void removeEvent(String eventId) {
    _events.removeWhere((event) => event['id'] == eventId);
    notifyListeners(); // Notify listeners to update UI
  }

  // Delete event from Firestore
  Future<void> deleteEvent(String eventId) async {
    try {
      // Remove event from Firestore
      await eventsCollection.doc(eventId).delete();
      // Remove event from local list
      removeEvent(eventId); // Reuse the removeEvent function
    } catch (e) {
      _errorMessage = "Error deleting event: $e";
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }
}
