import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'wrapper.dart'; // Use the wrapper instead of directly using ConnexionScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase with appropriate options
    if (kIsWeb) {
      // Web-specific Firebase initialization
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyD-9EAMlSOKwkhieKTt_KJN4-Ay167axVA",
          authDomain: "testbakoapp.firebaseapp.com",
          databaseURL: "https://testbakoapp-default-rtdb.firebaseio.com",
          projectId: "testbakoapp",
          storageBucket: "testbakoapp.firebasestorage.app",
          messagingSenderId: "656732856109",
          appId: "1:656732856109:web:dfe239ae86b4cd1504fda4",
          measurementId: "G-PRT3LWFRRJ",
        ),
      );
      
      // Explicitly set the database URL for web
      FirebaseDatabase.instance.databaseURL = "https://testbakoapp-default-rtdb.firebaseio.com";
      
      print("Firebase initialized for web successfully");
    } else {
      // For non-web platforms, use the default options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Make sure database URL is set for mobile too
      if (FirebaseDatabase.instance.databaseURL == null) {
        FirebaseDatabase.instance.databaseURL = "https://testbakoapp-default-rtdb.firebaseio.com";
      }
      
      print("Firebase initialized for mobile successfully");
    }
    
    print("Firebase Database URL: ${FirebaseDatabase.instance.databaseURL}");
    
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bako App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF577F65)),
        useMaterial3: true,
      ),
      home: const AuthWrapper(), // Use AuthWrapper instead of ConnexionScreen
      debugShowCheckedModeBanner: false,
    );
  }
}