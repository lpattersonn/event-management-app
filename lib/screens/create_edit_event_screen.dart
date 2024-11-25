import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateEditEventScreen extends StatefulWidget {
  final String? eventId;

  CreateEditEventScreen({this.eventId});

  @override
  _CreateEditEventScreenState createState() => _CreateEditEventScreenState();
}

class _CreateEditEventScreenState extends State<CreateEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _organizerController = TextEditingController();
  final _eventTypeController = TextEditingController();
  final _dateController = TextEditingController();

  late DocumentReference eventRef;

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) {
      eventRef = FirebaseFirestore.instance.collection('events').doc(widget.eventId);
      _loadEventData();
    }
  }

  // Load data if editing
  void _loadEventData() async {
    DocumentSnapshot snapshot = await eventRef.get();
    if (snapshot.exists) {
      Map<String, dynamic> event = snapshot.data() as Map<String, dynamic>;
      _titleController.text = event['title'];
      _descriptionController.text = event['description'];
      _locationController.text = event['location'];
      _organizerController.text = event['organizer'];
      _eventTypeController.text = event['eventType'];
      _dateController.text = (event['date'] as Timestamp).toDate().toString();
    }
  }

  // Save event to Firestore
  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      final event = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'organizer': _organizerController.text,
        'eventType': _eventTypeController.text,
        'date': Timestamp.fromDate(DateTime.parse(_dateController.text)),
        'updatedAt': Timestamp.now(),
      };

      if (widget.eventId == null) {
        // Create a new event
        await FirebaseFirestore.instance.collection('events').add(event);
      } else {
        // Update existing event
        await eventRef.update(event);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventId == null ? 'Create Event' : 'Edit Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Event Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Event Description'),
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextFormField(
                controller: _organizerController,
                decoration: InputDecoration(labelText: 'Organizer'),
              ),
              TextFormField(
                controller: _eventTypeController,
                decoration: InputDecoration(labelText: 'Event Type'),
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Event Date (yyyy-mm-dd)'),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEvent,
                child: Text(widget.eventId == null ? 'Create Event' : 'Update Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
