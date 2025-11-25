import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome_screen.dart';

class UserSetupScreen extends StatefulWidget {
  const UserSetupScreen({super.key});

  @override
  State<UserSetupScreen> createState() => _UserSetupScreenState();
}

class _UserSetupScreenState extends State<UserSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  int _age = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Let’s get to know you 👋",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // NAME
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Your Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Please enter your name" : null,
                onSaved: (v) => _name = v!,
              ),
              const SizedBox(height: 20),

              // AGE
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Your Age",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Please enter your age" : null,
                onSaved: (v) => _age = int.parse(v!),
              ),
              const SizedBox(height: 30),

              // BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  _formKey.currentState!.save();

                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setString("user_name", _name);
                  await prefs.setInt("user_age", _age);
                  await prefs.setBool("is_setup_done", true);

                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WelcomeScreen(),
                      ),
                    );
                  }
                },
                child: const Text(
                  "Start",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
