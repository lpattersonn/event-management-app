import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../event_provider.dart'; // Import the EventProvider
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'event_list_screen.dart';  // Import the event list screen

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

  bool _isLoading = false;
  List<String> eventTypes = ['All', 'Conference', 'Workshop', 'Webinar'];
  String? _selectedEventType;

  // Load data if editing an existing event
  void _loadEventData() async {
    if (widget.eventId != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.get(
          Uri.parse('https://us-central1-event-management-backend-7022a.cloudfunctions.net/api/getEventById/${widget.eventId}'),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> eventData = json.decode(response.body);

          if (eventData != null && eventData is Map<String, dynamic>) {
            _titleController.text = eventData['title'] ?? '';
            _descriptionController.text = eventData['description'] ?? '';
            _locationController.text = eventData['location'] ?? '';
            _organizerController.text = eventData['organizer'] ?? '';
            _selectedEventType = eventData['eventType'] ?? eventTypes[0]; // Default to 'All' if not provided

            // Parse the date safely, defaulting to the current date if invalid
            try {
              _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.parse(eventData['date']));
            } catch (e) {
              _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Default to current date if parsing fails
            }
          } else {
            throw Exception("Unexpected response format");
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load event data')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading event data: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedEventType = eventTypes[0]; // Default to 'All' if not loaded
    if (widget.eventId != null) {
      _loadEventData(); // Load event data if editing
    }
  }

  // Show date picker and set the selected date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime initialDate = _dateController.text.isEmpty
        ? DateTime.now()
        : DateTime.parse(_dateController.text);
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != initialDate) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  // Save event to Cloud Function or Firestore using EventProvider
Future<void> _saveEvent() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;  // Show the loading spinner
    });

    final event = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'location': _locationController.text,
      'organizer': _organizerController.text,
      'eventType': _selectedEventType!,
      'date': _dateController.text,
      'requestId': DateTime.now().millisecondsSinceEpoch.toString(),  // Unique requestId based on timestamp
    };

    try {
      if (widget.eventId == null) {
        // Disable the submit button to prevent multiple submissions
        setState(() {
          _isLoading = true;
        });

        // Create a new event
        final response = await http.post(
          Uri.parse('https://us-central1-event-management-backend-7022a.cloudfunctions.net/api/createEvent'),
          body: json.encode(event),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final newEvent = json.decode(response.body);

          // Update provider with the new event
          Provider.of<EventProvider>(context, listen: false).addEvent(newEvent);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Event created successfully!')));

          // Navigate to Event List screen after event creation
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EventListScreen()), // Replaces current screen with the EventListScreen
          );
        } else {
          final errorResponse = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create event: ${errorResponse['message']}')));
        }
      } else {
        // Update existing event
        final response = await http.put(
          Uri.parse('https://us-central1-event-management-backend-7022a.cloudfunctions.net/api/updateEvent/${widget.eventId}'),
          body: json.encode(event),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          // Update provider with the new event data
          Provider.of<EventProvider>(context, listen: false).updateEvent(widget.eventId!, event);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Event updated successfully!')));
        } else {
          final errorResponse = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update event: ${errorResponse['message']}')));
        }
      }

      Navigator.pop(context); // Go back after saving (to the list screen)
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving event: $e')));
    } finally {
      setState(() {
        _isLoading = false; // Re-enable button when request is complete
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventId == null ? 'Create Event' : 'Edit Event'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show a loading spinner while saving
          : Padding(
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    // Event Location Field
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(labelText: 'Location'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    // Event Organizer Field
                    TextFormField(
                      controller: _organizerController,
                      decoration: InputDecoration(labelText: 'Organizer'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an organizer';
                        }
                        return null;
                      },
                    ),
                    // Event Type Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedEventType,
                      decoration: InputDecoration(labelText: 'Event Type'),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedEventType = newValue!;
                        });
                      },
                      items: eventTypes.map((eventType) {
                        return DropdownMenuItem<String>(
                          value: eventType,
                          child: Text(eventType),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an event type';
                        }
                        return null;
                      },
                    ),
                    // Event Date Field with Date Picker
                    TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(labelText: 'Event Date (yyyy-mm-dd)'),
                      keyboardType: TextInputType.datetime,
                      readOnly: true,
                      onTap: () => _selectDate(context),
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