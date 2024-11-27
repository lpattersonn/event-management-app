import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider package
import 'package:intl/intl.dart'; // Import intl for date formatting
import 'create_edit_event_screen.dart';
import '../event_provider.dart'; // Import your EventProvider

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  // Constructor for EventDetailScreen
  EventDetailScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late DocumentReference eventRef;

  @override
  void initState() {
    super.initState();
    eventRef = FirebaseFirestore.instance.collection('events').doc(widget.eventId);
  }

  // Delete event function
  Future<void> deleteEvent(EventProvider eventProvider) async {
    try {
      await eventRef.delete();
      eventProvider.removeEvent(widget.eventId); // Remove event from provider list
      Navigator.pop(context); // Go back after deletion
    } catch (e) {
      print("Error deleting event: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context); // Access EventProvider

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: eventRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Event not found.'));
          }

          final event = snapshot.data!.data() as Map<String, dynamic>;
          final title = event['title'];
          final description = event['description'];
          final date = (event['date'] as Timestamp).toDate(); // Convert Firestore Timestamp to DateTime
          final location = event['location'];
          final organizer = event['organizer'];
          final eventType = event['eventType'];

          // Format the date using the intl package (without time)
          String formattedDate = DateFormat('MMMM dd, yyyy').format(date);

          return Padding(
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
                      onPressed: () {
                        // Navigate to Create/Edit Event screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateEditEventScreen(eventId: widget.eventId),
                          ),
                        );
                      },
                      child: Text('Edit'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        deleteEvent(eventProvider); // Delete the event using the provider
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
          );
        },
      ),
    );
  }
}
