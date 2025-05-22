import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/bucket_list_item.dart';
import 'add_destination_screen.dart'; // For editing trips

class SavedDestinationsScreen extends StatefulWidget {
  const SavedDestinationsScreen({super.key});

  @override
  _SavedDestinationsScreenState createState() =>
      _SavedDestinationsScreenState();
}

class _SavedDestinationsScreenState extends State<SavedDestinationsScreen> {
  late Box<BucketListItem> bucketListBox;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    bucketListBox = Hive.box<BucketListItem>('bucket_list');
  }

  void _deleteTrip(int index) {
    setState(() {
      bucketListBox.deleteAt(index);
    });
  }

  void _editTrip(int index) {
    final trip = bucketListBox.getAt(index);
    if (trip != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddDestinationScreen(
            existingTrip: trip,
            tripIndex: index,
          ),
        ),
      ).then((_) {
        setState(() {}); // Refresh UI after editing
      });
    }
  }

  List<BucketListItem> _getFilteredTrips() {
    if (_selectedCategory == 'All') {
      return bucketListBox.values.toList();
    }
    return bucketListBox.values
        .where((trip) => trip.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    List<BucketListItem> filteredTrips = _getFilteredTrips();

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Destinations')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: ['All', 'Upcoming', 'Dream Trips', 'Visited']
                  .map((category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Filter by Category',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredTrips.isEmpty
                ? const Center(child: Text('No trips found!'))
                : ListView.builder(
                    itemCount: filteredTrips.length,
                    itemBuilder: (context, index) {
                      final trip = filteredTrips[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(trip.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              trip.description ?? 'No description available'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editTrip(bucketListBox.values
                                    .toList()
                                    .indexOf(trip)),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTrip(bucketListBox
                                    .values
                                    .toList()
                                    .indexOf(trip)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
