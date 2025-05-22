import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/bucket_list_item.dart';
import 'package:provider/provider.dart'; // Import the provider package
import 'providers/trip_provider.dart'; // Import the TripProvider class

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/add_destination_screen.dart'; // Import the new screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: kIsWeb
        ? const FirebaseOptions(
            apiKey: "AIzaSyC9ZorWTxU2TDY6L_MS5WSIvIY3lUBzwfQ",
            authDomain: "travel-bucket-list-f25a1.firebaseapp.com",
            projectId: "travel-bucket-list-f25a1",
            storageBucket: "travel-bucket-list-f25a1",
            messagingSenderId: "809024111738",
            appId: "1:809024111738:web:c8a7c8e42fa0a729b627c3",
          )
        : null,
  );

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters for Custom Objects
  Hive.registerAdapter(BucketListItemAdapter());
  Hive.registerAdapter(ExpenseAdapter()); // Ensure Expense model is registered
  Hive.registerAdapter(GoalAdapter());

  // Open Hive Boxes
  await Hive.openBox<BucketListItem>('bucket_list'); // Existing Box
  await Hive.openBox<BucketListItem>('live_trips'); // Added live_trips box

  runApp(
    // Wrap the app with ChangeNotifierProvider to provide TripProvider to the entire app
    ChangeNotifierProvider(
      create: (context) =>
          TripProvider(), // Provide an instance of TripProvider
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Bucket List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/add-destination': (context) => const AddDestinationScreen(),
      },
    );
  }
}
