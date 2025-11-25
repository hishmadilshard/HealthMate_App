import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database/database_helper.dart';
import 'features/health_records/providers/health_provider.dart';
import 'features/health_records/screens/user_setup_screen.dart';
import 'features/health_records/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize DB
  await DatabaseHelper().init();

  // Check if setup is done
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool setupDone = prefs.getBool("is_setup_done") ?? false;

  // Run App
  runApp(MyApp(startSetup: setupDone));
}

/// 🚀 MyApp MUST be StatelessWidget (NOT StatefulWidget!)
class MyApp extends StatelessWidget {
  final bool startSetup;

  const MyApp({super.key, required this.startSetup});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HealthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "HealthMate",
        theme: ThemeData(primarySwatch: Colors.blue),
        home: startSetup ? const WelcomeScreen() : const UserSetupScreen(),
      ),
    );
  }
}

