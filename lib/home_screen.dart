import 'package:flutter/material.dart';
import 'package:event_management_app/event_model.dart';
import 'package:event_management_app/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Event>> _events;

  @override
  void initState() {
    super.initState();
    _events = _firestoreService.getAllEvents();  // Fetch events from Firestore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Management App'),
      ),
      body: FutureBuilder<List<Event>>(
        future: _events,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No events available.'));
          } else {
            final events = snapshot.data!;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(events[index].title),
                  subtitle: Text(events[index].location),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _firestoreService.deleteEvent(events[index].id);  // Delete event
                      setState(() {
                        _events = _firestoreService.getAllEvents();  // Refresh list
                      });
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Event newEvent = Event(
            id: '',  // Firestore will generate the ID
            title: 'New Event',
            description: 'New event description',
            location: 'New Location',
            organizer: 'New Organizer',
            eventType: 'New Type',
            date: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          _firestoreService.addEvent(newEvent);  // Add new event
          setState(() {
            _events = _firestoreService.getAllEvents();  // Refresh list
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
