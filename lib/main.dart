import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/event_list_screen.dart';
import 'screens/event_detail_screen.dart';
import 'screens/create_edit_event_screen.dart';

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
      measurementId: "G-Y8HNSMQT4K",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',  // Home route (Event List Screen)
      routes: {
        '/': (context) => EventListScreen(),
        '/eventDetail': (context) => EventDetailScreen(eventId: ModalRoute.of(context)!.settings.arguments as String),
        '/createEditEvent': (context) => CreateEditEventScreen(),
      },
    );
  }
}