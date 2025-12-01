import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../widgets/record_card.dart';
import 'dashboard.dart';
import 'welcome_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();

   
    final provider = Provider.of<HealthProvider>(context, listen: false);
    provider.loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
        centerTitle: true,
      ),

      body: Column(
        children: [
          //  Search Bar 
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Date (YYYY-MM-DD)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onChanged: (value) {
                provider.filterByDate(value.trim());  // ✔ No reload
              },
            ),
          ),

          //  Records List
          Expanded(
            child: StreamBuilder<List>(
              stream: provider.recordsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final records = snapshot.data!;
                if (records.isEmpty) {
                  return const Center(
                    child: Text(
                      'No records found for this date',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    return RecordCard(record: records[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar 
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _selectedIndex = index);

          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          } 
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Welcome',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Records',
          ),
        ],
      ),
    );
  }
}
