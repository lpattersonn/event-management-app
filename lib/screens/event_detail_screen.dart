import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting
import 'package:provider/provider.dart'; // Import provider package
import 'create_edit_event_screen.dart';
import '../event_provider.dart'; // Import your EventProvider
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'event_list_screen.dart';  // Import EventListScreen

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  // Constructor for EventDetailScreen
  EventDetailScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Map<String, dynamic>? eventDetails;
  String? _errorMessage;
  bool _isLoading = true;  // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchEventDetails(); // Fetch the event details when the screen loads
  }

  // Base URL of your Firebase Cloud Functions
  final String _baseUrl = 'https://us-central1-event-management-backend-7022a.cloudfunctions.net/api';

  // Fetch event details using Cloud Function
  Future<void> _fetchEventDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/getEventById/${widget.eventId}'), // Replace with your actual Cloud Function URL
      );

      if (response.statusCode == 200) {
        setState(() {
          eventDetails = json.decode(response.body); // Parse the event details and update state
          _isLoading = false;  // Stop loading after data is fetched
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load event details: ${response.statusCode}';
          _isLoading = false;  // Stop loading even in case of error
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching event details: $e';
        _isLoading = false;  // Stop loading after error
      });
    }
  }

  // Delete event via Cloud Function
Future<void> deleteEvent(EventProvider eventProvider) async {
  try {
    final response = await http.delete(
      Uri.parse('$_baseUrl/deleteEvent/${widget.eventId}'),
    );

    // Check if the response status code is 200 (OK)
    if (response.statusCode == 200) {
      // Event deleted successfully from backend
      final responseBody = json.decode(response.body); // Parse the response body

      if (responseBody['message'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['message'])), // Display the success message
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event deleted successfully!')),
        );
      }

      eventProvider.deleteEvent(widget.eventId); // Remove event from provider list

      // Navigate to the EventListScreen (or any other screen you want)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => EventListScreen()), // Navigate to Event List Screen
        (Route<dynamic> route) => false, // Remove all previous screens
      );
    } else {
      // Handle the error gracefully if response status is not 200
      if (response.body.isEmpty) {
        // No message from server, but event deletion was successful
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event deleted, but no message returned from server.')),
        );
      } else {
        // Attempt to decode the JSON response and show specific error message
        try {
          final errorResponse = json.decode(response.body);
          if (errorResponse is Map<String, dynamic>) {
            final errorMessage = errorResponse['message'] ?? 'Unknown error occurred';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete event: $errorMessage')),
            );
          } else {
            // Handle unexpected response format
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete event: Unexpected response format')),
            );
          }
        } catch (e) {
          // Handle invalid JSON response
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete event: Invalid response from server')),
          );
        }
      }
    }
  } catch (e) {
    // Handle any exceptions during the delete operation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error deleting event: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    // If there's an error message, display it
    if (_errorMessage != null && !_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Event Details'),
        ),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    // If event details are not loaded yet, show a loading indicator
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Event Details'),
        ),
        body: Center(child: CircularProgressIndicator()), // Show a loading spinner while event details are being fetched
      );
    }

    // Safely extract the event details
    final title = eventDetails!['title'];
    final description = eventDetails!['description'];
    dynamic dateRaw = eventDetails!['date'];
    final location = eventDetails!['location'];
    final organizer = eventDetails!['organizer'];
    final eventType = eventDetails!['eventType'];

    // Safely handle the date parsing
    DateTime date;
    if (dateRaw is String) {
      // If it's a string, try parsing it directly
      try {
        date = DateTime.parse(dateRaw);
      } catch (e) {
        date = DateTime.now(); // Fallback if parsing fails
      }
    } else if (dateRaw is Map) {
      // If it's a Firestore Timestamp object, check for the 'seconds' field
      var timestamp = dateRaw['seconds'];
      if (timestamp != null && timestamp is int) {
        // Convert seconds to milliseconds
        date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      } else {
        date = DateTime.now(); // Fallback if 'seconds' is null or not an integer
      }
    } else {
      date = DateTime.now(); // Fallback to current date if neither is valid
    }

    // Format the date using the intl package (without time)
    String formattedDate = DateFormat('MMMM dd, yyyy').format(date);

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: $title', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Description: $description'),
            SizedBox(height: 10),
            Text('Location: $location'),
            SizedBox(height: 10),
            Text('Organizer: $organizer'),
            SizedBox(height: 10),
            Text('Event Type: $eventType'),
            SizedBox(height: 10),
            Text('Date: $formattedDate'), // Display the formatted date
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Navigate to Create/Edit Event screen
                    final updatedEventDetails = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateEditEventScreen(eventId: widget.eventId),
                      ),
                    );

                    // After editing, re-fetch the event details
                    if (updatedEventDetails != null) {
                      setState(() {
                        eventDetails = updatedEventDetails;
                      });
                    } else {
                      // If no updated event details are returned, re-fetch from backend
                      _fetchEventDetails();
                    }
                  },
                  child: Text('Edit'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Show a confirmation dialog before deleting the event
                    bool? confirmed = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Event'),
                        content: Text('Are you sure you want to delete this event?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    // If confirmed, proceed with deletion
                    if (confirmed == true) {
                      await deleteEvent(eventProvider); // Delete the event using the provider
                    }
                  },
                  child: Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
