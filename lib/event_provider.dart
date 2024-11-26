import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List of events
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> get events => _events;

  // Current user
  User? _user;
  User? get user => _user;

  EventProvider() {
    // Listen to changes in authentication state
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Fetch events from Firestore
  Future<void> fetchEvents() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('events').get();
      _events = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  // Create or update an event
  Future<void> saveEvent(String? eventId, Map<String, dynamic> eventData) async {
    try {
      if (eventId == null) {
        // Add new event
        await _firestore.collection('events').add(eventData);
      } else {
        // Update existing event
        await _firestore.collection('events').doc(eventId).update(eventData);
      }
      await fetchEvents(); // Refresh the list after saving
    } catch (e) {
      print('Error saving event: $e');
    }
  }

  // Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      await fetchEvents(); // Refresh the list after deleting
    } catch (e) {
      print('Error deleting event: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Sign in anonymously (or use another sign-in method)
  Future<void> signIn() async {
    await _auth.signInAnonymously();
  }
}
