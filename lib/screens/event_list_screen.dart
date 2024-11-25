import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'event_detail_screen.dart';

class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  String _selectedEventType = 'All'; // Default to 'All'
  final List<String> eventTypes = ['All', 'Conference', 'Workshop', 'Webinar'];

  // Reference to Firestore collection
  final CollectionReference eventsCollection = FirebaseFirestore.instance.collection('events');

  // Function to fetch events from Firestore with real-time updates
  Stream<List<Map<String, dynamic>>> getEvents(String eventType) {
    Query query = eventsCollection.orderBy('date', descending: true);
    if (eventType != 'All') {
      query = query.where('eventType', isEqualTo: eventType);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedEventType,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEventType = newValue!;
                });
              },
              items: eventTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getEvents(_selectedEventType),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No events available.'));
          }

          List<Map<String, dynamic>> events = snapshot.data!;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final title = event['title'];
              final description = event['description'];
              final date = (event['date'] as Timestamp).toDate();
              final location = event['location'];
              final organizer = event['organizer'];
              final eventId = event['id'];

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(title),
                  subtitle: Text('$description\n$location\n$organizer'),
                  trailing: Text('${date.toLocal()}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailScreen(eventId: eventId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
