// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/health_record.dart';
import '../providers/health_provider.dart';

class RecordCard extends StatelessWidget {
  final HealthRecord record;

  const RecordCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date row (title)
          Text(
            record.date,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

         
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.start,
            children: [
              _infoChip(Icons.directions_walk, record.steps.toString(), Colors.green),
              _infoChip(Icons.local_fire_department, record.calories.toString(), Colors.orange),
              _infoChip(Icons.water_drop, "${record.water} ml", Colors.blue),
            ],
          ),

          const SizedBox(height: 12),

          
          Row(
            children: [
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showEditDialog(context, provider, record),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context, provider, record.id!),
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // chip widget
  Widget _infoChip(IconData icon, String value, Color color) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 80, maxWidth: 180),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // delete confirmation
  void _confirmDelete(BuildContext context, HealthProvider provider, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Delete Record"),
        content: const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("No"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await provider.deleteRecord(id);
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Record deleted successfully!"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Yes", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // edit dialog with no-change detection
  void _showEditDialog(BuildContext context, HealthProvider provider, HealthRecord record) {
    final formKey = GlobalKey<FormState>();

    int updatedSteps = record.steps;
    int updatedCalories = record.calories;
    int updatedWater = record.water;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Edit Record"),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: record.steps.toString(),
                  decoration: const InputDecoration(labelText: "Steps"),
                  keyboardType: TextInputType.number,
                  onSaved: (v) => updatedSteps = int.parse(v!.trim()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: record.calories.toString(),
                  decoration: const InputDecoration(labelText: "Calories"),
                  keyboardType: TextInputType.number,
                  onSaved: (v) => updatedCalories = int.parse(v!.trim()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: record.water.toString(),
                  decoration: const InputDecoration(labelText: "Water (ml)"),
                  keyboardType: TextInputType.number,
                  onSaved: (v) => updatedWater = int.parse(v!.trim()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              formKey.currentState!.save();

              // no changes
              if (updatedSteps == record.steps &&
                  updatedCalories == record.calories &&
                  updatedWater == record.water) {
                Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Record wasn't updated — no changes detected."),
                      backgroundColor: Colors.grey,
                    ),
                  );
                }
                return;
              }

              // proceed update
              final updatedRecord = HealthRecord(
                id: record.id,
                date: record.date,
                steps: updatedSteps,
                calories: updatedCalories,
                water: updatedWater,
              );

              provider.updateRecord(updatedRecord);
              Navigator.pop(ctx);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Record updated successfully!"),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
