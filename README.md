# Event Management Application - Frontend Setup (Flutter)
This repository contains the frontend for the Event Management Application built using Flutter. The frontend integrates with the Firebase backend to display, manage, and filter events in real-time. The application provides users with an interface to create, view, edit, and delete events, while also enabling filtering based on event type.

## Project Overview
The frontend of the Event Management Application allows users to interact with events by:

Viewing a list of events.
Filtering events based on event type (e.g., Conference, Workshop, Webinar).
Viewing detailed event information.
Creating or editing events via a form.
Handling network requests and error states properly.
Features
Event List Screen: Displays events fetched from Firebase Firestore with real-time updates.
Event Detail Screen: Shows detailed information for a selected event, with options to edit or delete.
Create/Edit Event Screen: A form to create new events or edit existing ones, with form validation.
Filtering: Allows filtering events by event type such as "Conference", "Workshop", and "Webinar".
State Management: Uses the Provider package to manage the app's state.
Error Handling: Includes error handling for network requests and form validation.
Technologies Used
Flutter: Framework for building the cross-platform mobile app.
Firebase: Backend as a service for authentication, Firestore database, and real-time event data.
Provider: State management solution for handling app data and UI updates.
Dart: Programming language used in Flutter development.
Prerequisites
Before you begin, make sure you have the following tools installed:

## Flutter SDK
### Firebase CLI
Android Studio or VS Code with Flutter and Dart plugins
Firebase Project linked to your app
Setup Instructions
1. Clone the Repository
git clone https://github.com/lpattersonn/event-management-frontend.git
cd event-management-frontend
2. Install Dependencies
Run the following command to install the necessary dependencies for the Flutter app:

flutter pub get
3. Firebase Setup
You need to integrate your Flutter app with Firebase. Follow the steps below to set up Firebase in your Flutter project:

Go to the Firebase Console and create a new project.

Add your Flutter app to the Firebase project:

In the Firebase console, click on the "Web" or "iOS/Android" icon to register your app.
Follow the instructions to download the google-services.json (Android) or GoogleService-Info.plist (iOS) and place it in the appropriate directory of your Flutter project.
Install Firebase packages:

Add the following Firebase dependencies to your pubspec.yaml:

dependencies:
  firebase_core: latest_version
  cloud_firestore: latest_version
  firebase_auth: latest_version (optional for authentication)
  provider: latest_version
Configure Firebase in your Flutter app:

Import and initialize Firebase in your main.dart:

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
4. Configure Firestore Database
You should already have a Firestore instance set up in your Firebase project. If not, follow the Firebase Firestore setup guide to create collections and documents for storing event data.

5. Implement State Management
For state management, we use the Provider package to manage the state of the app. In the lib/ folder, you will find a provider/ directory that contains the following files:

event_provider.dart: This file manages the state for events and is responsible for fetching, updating, and filtering event data from Firestore.
event_model.dart: The data model for an event.
Example usage of Provider in your app:

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_provider.dart';
import 'event_model.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => EventProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EventListScreen(),
    );
  }
}
6. UI Screens
The app consists of the following screens:

## Event List Screen
Displays a list of events fetched from Firestore.
Allows filtering events by type using a dropdown or segmented control.
Updates the event list in real-time as data changes in Firestore.
Event Detail Screen
Displays detailed information about a specific event.
Provides options to edit or delete the event.
Create/Edit Event Screen
A form to create a new event or edit an existing one.
Input fields for event name, type, date, and location.
Data validation before submission to Firestore.
7. Filtering Events
Filtering by Event Type: In the Event List Screen, a dropdown or segmented control allows users to filter events by type. This filter updates the displayed event list dynamically based on the selected event type (e.g., "Conference", "Workshop", "Webinar").
Example code for filtering events by type:

DropdownButton<String>(
  value: selectedEventType,
  onChanged: (newType) {
    setState(() {
      selectedEventType = newType;
      // Call method to fetch filtered events
      _fetchFilteredEvents(selectedEventType);
    });
  },
  items: ['Conference', 'Workshop', 'Webinar']
      .map((type) => DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          ))
      .toList(),
)
8. Error Handling
Network errors and form submission errors are properly handled with error messages displayed to the user.
Firebase network errors or Firestore write failures are caught and displayed as user-friendly messages.
Example error handling in the EventProvider:

try {
  await FirebaseFirestore.instance.collection('events').add(eventData);
} catch (e) {
  // Show error message to the user
  showError("Failed to add event. Please try again.");
}
9. Running the App
To run the app on your emulator or physical device:

flutter run
Make sure to use flutter doctor to check if everything is set up correctly and there are no issues with your environment.

Folder Structure
/event-management-frontend
├── /lib
│   ├── /models            # Event data models
│   ├── /providers         # State management (Provider)
│   ├── /screens           # UI screens (Event List, Event Detail, Create/Edit)
│   ├── main.dart          # Entry point for the app
├── /assets                # Images, fonts, and other static files
├── /android               # Android-specific code
├── /ios                   # iOS-specific code
├── pubspec.yaml           # Flutter project dependencies
└── README.md              # Project documentation
Next Steps
Integrate user authentication (if needed) using Firebase Authentication.
Enhance the UI for better user experience (UX/UI improvements).
Set up production Firebase Firestore security rules.
Deploy the Flutter app to the Google Play Store or Apple App Store.
License
This project is licensed under the MIT License. See the LICENSE file for details.

# event-management-app
