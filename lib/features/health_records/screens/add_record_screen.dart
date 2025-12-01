import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/health_record.dart';
import '../providers/health_provider.dart';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  int _steps = 0;
  int _calories = 0;
  int _water = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Health Record'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //  Date Field
              TextFormField(
                initialValue: _date,
                decoration: InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                  prefixIcon: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onSaved: (value) => _date = value!,
              ),
              const SizedBox(height: 20),

              //  Steps Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Steps',
                  prefixIcon: const Icon(Icons.directions_walk, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter steps' : null,
                onSaved: (value) => _steps = int.parse(value!),
              ),
              const SizedBox(height: 20),

              //  Calories Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Calories',
                  prefixIcon: const Icon(Icons.local_fire_department, color: Colors.orange),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter calories' : null,
                onSaved: (value) => _calories = int.parse(value!),
              ),
              const SizedBox(height: 20),

              //  Water Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Water (ml)',
                  prefixIcon: const Icon(Icons.water_drop, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter water amount' : null,
                onSaved: (value) => _water = int.parse(value!),
              ),
              const SizedBox(height: 30),

              //  Save Button
              ElevatedButton.icon(
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'Save Record',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    provider.addRecord(HealthRecord(
                      date: _date,
                      steps: _steps,
                      calories: _calories,
                      water: _water,
                    ));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Health record added successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
