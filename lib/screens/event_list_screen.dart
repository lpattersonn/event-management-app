import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'event_detail_screen.dart';
import 'create_edit_event_screen.dart'; // Import the screen where new events are created

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
      return snapshot.docs.map((doc) {
        // Get document data and also capture the document ID
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID to the data map
        return data;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Management App'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Dropdown Button (styled like Bootstrap) with max width of 200px
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                width: 200, // Set the width of the dropdown to 200px
                child: DropdownButton<String>(
                  value: _selectedEventType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedEventType = newValue!;
                    });
                  },
                  isExpanded: true, // Make it expand to full width of the container
                  dropdownColor: Colors.white, // Set the dropdown's background color
                  style: TextStyle(color: Colors.black, fontSize: 16), // Text style for dropdown button
                  underline: Container(
                    height: 2,
                    color: Colors.blue, // Add an underline like Bootstrap dropdown
                  ),
                  items: eventTypes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
                        child: Text(value),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          
          // Event list displayed below the centered dropdown
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
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
                    final eventId = event['id']; // Now 'id' is part of the data map

                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(title),
                        subtitle: Text('$description\n$location\n$organizer'),
                        trailing: Text('${date.toLocal()}'),
                        onTap: () {
                          // Navigate to EventDetailScreen with the eventId
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
          ),
        ],
      ),
      
      // Create Event button (FAB)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Create/Edit Event screen with null eventId for new event creation
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateEditEventScreen(eventId: null), // Pass null for creating a new event
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Create Event',
      ),
    );
  }
}
