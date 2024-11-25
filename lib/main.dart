import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:event_management_app/event_screen.dart';

 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyBygYHoVwlNnGabdCn6b-XXGadlUQGVYe0",
    authDomain: "event-management-backend-7022a.firebaseapp.com",
    projectId: "event-management-backend-7022a",
    storageBucket: "event-management-backend-7022a.firebasestorage.app",
    messagingSenderId: "900117377579",
    appId: "1:900117377579:web:1504b0755faa0a2e95b06e",
    measurementId: "G-Y8HNSMQT4K"
    ),
  );
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EventScreen(),  // Display events in this screen
    );
  }
}
