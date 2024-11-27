import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider package
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import '../event_provider.dart'; // Import the event provider
import 'event_detail_screen.dart';
import 'create_edit_event_screen.dart'; // Import the screen where new events are created

class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  @override
  void initState() {
    super.initState();
    // Load all events when the screen is first loaded (without any filter).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      // Fetch all events by setting the event type to "All"
      eventProvider.setEventType('All');
      eventProvider.fetchFilteredEvents();
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
                child: Consumer<EventProvider>( // Use Consumer to rebuild when event type changes
                  builder: (context, eventProvider, child) {
                    return DropdownButton<String>(
                      value: eventProvider.selectedEventType, // Reflect selected event type
                      onChanged: (String? newValue) {
                        // Update selected event type in the provider
                        if (newValue != null) {
                          eventProvider.setEventType(newValue);
                          // Fetch the filtered events whenever the event type changes
                          eventProvider.fetchFilteredEvents();
                        }
                      },
                      isExpanded: true,
                      dropdownColor: Colors.white, // Set the dropdown's background color
                      style: TextStyle(color: Colors.black, fontSize: 16), // Text style for dropdown button
                      underline: Container(
                        height: 2,
                        color: Colors.blue, 
                      ),
                      items: eventProvider.eventTypes.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
                            child: Text(value),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Event list displayed below the centered dropdown
          Expanded(
            child: Consumer<EventProvider>(
              builder: (context, eventProvider, child) {
                // Handle error message if available
                if (eventProvider.errorMessage != null) {
                  return Center(child: Text(eventProvider.errorMessage!));
                }

                // Show a message if there are no events
                if (eventProvider.events.isEmpty) {
                  return Center(child: Text('No events found'));
                }

                return ListView.builder(
                  itemCount: eventProvider.events.length,
                  itemBuilder: (context, index) {
                    final event = eventProvider.events[index];
                    final title = event['title'];
                    final description = event['description'];
                    final location = event['location'];
                    final organizer = event['organizer'];
                    final eventId = event['id']; // Now 'id' is part of the data map
                    
                    // Use 'date' instead of 'updatedAt'
                    var dateValue = event['date']; // Ensure this is the correct 'date' field

                    DateTime date;
                    if (dateValue is String) {
                      try {
                        // Try parsing the string into a DateTime
                        date = DateTime.parse(dateValue); // ISO 8601 string to DateTime
                      } catch (e) {
                        // If parsing fails, use current date
                        date = DateTime.now();
                      }
                    } else if (dateValue is int) {
                      // If it's a timestamp (in milliseconds), convert it to DateTime
                      date = DateTime.fromMillisecondsSinceEpoch(dateValue);
                    } else {
                      date = DateTime.now(); // Default to current date if something goes wrong
                    }

                    // Format the date using intl package without time
                    String formattedDate = DateFormat('MMMM dd, yyyy').format(date);

                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(title),
                        subtitle: Text('$description\n$location\n$organizer'),
                        trailing: Text(formattedDate), // Display human-readable date without time
                        onTap: () {
                          // Navigate to EventDetailScreen with the eventId
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailScreen(eventId: eventId),
                            ),
                          );
                        },
                        // Add delete action in the trailing or onTap
                        onLongPress: () {
                          // Call the deleteEvent method from the EventProvider
                          eventProvider.deleteEvent(eventId).then((_) {
                            // If delete succeeds, show a success message
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Event deleted successfully'),
                            ));

                            // After successful deletion, refetch the events
                            eventProvider.fetchFilteredEvents();
                          }).catchError((e) {
                            // If error occurs during delete, show error message
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Error deleting event: $e'),
                            ));
                          });
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
