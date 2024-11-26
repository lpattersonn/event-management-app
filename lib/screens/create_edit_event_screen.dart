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

  // Load data if editing an existing event
  void _loadEventData() async {
    try {
      DocumentSnapshot snapshot = await eventRef.get();
      if (snapshot.exists) {
        Map<String, dynamic> event = snapshot.data() as Map<String, dynamic>;
        _titleController.text = event['title'];
        _descriptionController.text = event['description'];
        _locationController.text = event['location'];
        _organizerController.text = event['organizer'];
        _eventTypeController.text = event['eventType'];
        _dateController.text = (event['date'] as Timestamp).toDate().toString().split(' ')[0]; // Formatting date to 'yyyy-mm-dd'
      }
    } catch (e) {
      // Handle any errors during data loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading event data: $e')));
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

      try {
        if (widget.eventId == null) {
          // Create a new event
          await FirebaseFirestore.instance.collection('events').add(event);
        } else {
          // Update existing event
          await eventRef.update(event);
        }
        Navigator.pop(context); // Go back to the previous screen after saving
      } catch (e) {
        // Handle errors when saving/updating the event
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving event: $e')));
      }
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
          child: ListView(
            children: [
              // Event Title Field
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
              // Event Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Event Description'),
              ),
              // Event Location Field
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              // Event Organizer Field
              TextFormField(
                controller: _organizerController,
                decoration: InputDecoration(labelText: 'Organizer'),
              ),
              // Event Type Field
              TextFormField(
                controller: _eventTypeController,
                decoration: InputDecoration(labelText: 'Event Type'),
              ),
              // Event Date Field
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Event Date (yyyy-mm-dd)'),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date';
                  }
                  try {
                    DateTime.parse(value);
                  } catch (e) {
                    return 'Invalid date format. Use yyyy-mm-dd';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Save Button
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
