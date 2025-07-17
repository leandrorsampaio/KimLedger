// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/data_provider.dart';
import 'services/database_service.dart';

void main() async {
  // Ensure that Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Delete the old database to start fresh
  await DatabaseService.instance.deleteDB();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap the entire app with ChangeNotifierProvider to make the data
    // available to all descendant widgets.
    return ChangeNotifierProvider(
      create: (context) => DataProvider(),
      child: MaterialApp(
        title: 'KimLedger',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}