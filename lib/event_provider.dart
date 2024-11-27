import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON parsing

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

  // Set a new event type and fetch filtered events
  void setEventType(String type) {
    _selectedEventType = type;
    notifyListeners(); // Notify listeners to rebuild UI
    fetchFilteredEvents(); // Fetch events after the event type is changed
  }

  // Base URL of your Firebase Cloud Functions
  final String _baseUrl = 'https://us-central1-event-management-backend-7022a.cloudfunctions.net/api';

  // Function to fetch events from the Firebase Cloud Function endpoint with filtering
  Future<void> fetchFilteredEvents() async {
    String url = '$_baseUrl/filterEvents'; // Endpoint for filtering events

    // Append eventType to the URL if it's not 'All'
    if (_selectedEventType != 'All') {
      url += '?eventType=$_selectedEventType'; // Apply the event type filter
    }

    try {
      _errorMessage = null; // Clear any previous errors
      notifyListeners(); // Notify listeners before fetching (this could trigger a loading state)

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Successfully fetched the events
        List<Map<String, dynamic>> eventList = List<Map<String, dynamic>>.from(json.decode(response.body));
        _events = eventList; // Update the list of events
      } else {
        // Failed to load events from server
        _errorMessage = 'Failed to load events: ${response.statusCode}';
        _events = []; // Clear events list in case of failure
      }
    } catch (e) {
      // Handle network or other errors
      _errorMessage = 'Error fetching events: $e';
      _events = []; // Clear events list in case of failure
    } finally {
      // Notify listeners after fetch attempt (success or failure)
      notifyListeners();
    }
  }

  // Add a new event via Firebase Cloud Function
Future<void> addEvent(Map<String, dynamic> eventData) async {
  try {
    // Optimistically add the event to the local list
    _events.insert(0, eventData);  // Insert at the beginning of the list
    notifyListeners();  // Notify listeners to immediately reflect the change

    final response = await http.post(
      Uri.parse('$_baseUrl/createEvent'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(eventData),
    );

    if (response.statusCode == 201) {  // Check for '201 Created' status code
      // Successfully added event
      var newEvent = json.decode(response.body);
      
      // Ensure the new event is inserted correctly
      int index = _events.indexWhere((event) => event['id'] == newEvent['id']);
      if (index != -1) {
        _events[index] = newEvent;  // Update the event with the response from server
      } else {
        // If index is not found, add the new event to the list
        _events.insert(0, newEvent);
      }
      notifyListeners();  // Notify listeners that the event list has been updated
    } else {
      // Failed to add event, revert optimistic update
      _errorMessage = 'Failed to add event: ${response.statusCode}';
      _events.removeAt(0);  // Revert the optimistic update
      notifyListeners();
    }
  } catch (e) {
    // Handle errors during the add event request
    _errorMessage = 'Error adding event: $e';
    _events.removeAt(0);  // Revert the optimistic update
    notifyListeners();
  } finally {
    // Notify listeners to reflect the final state
    notifyListeners();
  }
}


  // Update an existing event via Firebase Cloud Function
  Future<void> updateEvent(String eventId, Map<String, dynamic> updatedData) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/updateEvent/$eventId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        // Successfully updated the event
        var updatedEvent = json.decode(response.body);
        int index = _events.indexWhere((event) => event['id'] == eventId);
        if (index != -1) {
          _events[index] = updatedEvent; // Update the event in the list
        }
      } else {
        // Failed to update event
        _errorMessage = 'Failed to update event: ${response.statusCode}';
      }
    } catch (e) {
      // Handle errors during the update event request
      _errorMessage = 'Error updating event: $e';
    } finally {
      // Notify listeners to reflect the final state
      notifyListeners();
    }
  }

  // Delete an event via Firebase Cloud Function
  Future<void> deleteEvent(String eventId) async {
    try {
      // Check if the event is already deleted locally
      if (!_events.any((event) => event['id'] == eventId)) {
        print('Event already deleted locally');
        return; // Prevent sending delete request if event already deleted locally
      }

      // Optimistically remove the event from the local list
      _events.removeWhere((event) => event['id'] == eventId);
      notifyListeners(); // Update the UI immediately

      // Send the delete request to the backend
      final response = await http.delete(
        Uri.parse('$_baseUrl/deleteEvent/$eventId'),
      );

      // Handle the response
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Successfully deleted the event on the server
        print("Event deleted successfully");
      } else if (response.statusCode == 404) {
        // If the event is not found, treat it as a successful deletion (it was already deleted)
        print('Event already deleted or not found');
      } else {
        // Handle other error codes
        _handleDeleteError(response);
      }
    } catch (e) {
      // Handle any errors during the delete request
      _errorMessage = 'Error deleting event: $e';
      print(_errorMessage);

      // Revert optimistic deletion if an exception occurs
      _events.add({'id': eventId});
    } finally {
      // Always notify listeners to update the UI state
      notifyListeners();
    }
  }

  void _handleDeleteError(http.Response response) {
    // Try to parse the response body as JSON
    try {
      final errorResponse = json.decode(response.body);
      // If JSON decoding is successful, handle the error appropriately
      _errorMessage = 'Failed to delete event: ${errorResponse['message'] ?? 'Unknown error'}';
    } catch (e) {
      // If JSON decoding fails, assume the response is plain text
      _errorMessage = 'Failed to delete event: ${response.body}';
    }
    print(_errorMessage);
    notifyListeners();  // Notify listeners to reflect the error
  }

  // Optional: Define getEvents() for compatibility
  List<Map<String, dynamic>> getEvents() {
    return _events;
  }
}
