import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/bucket_list_item.dart';
import 'view_trip_screen.dart'; // Import the view trip screen

class LiveTripsScreen extends StatefulWidget {
  const LiveTripsScreen({super.key});

  @override
  _LiveTripsScreenState createState() => _LiveTripsScreenState();
}

class _LiveTripsScreenState extends State<LiveTripsScreen> {
  late Box<BucketListItem> _liveTripBox;

  @override
  void initState() {
    super.initState();
    _liveTripBox = Hive.box<BucketListItem>('live_trips');
  }

  void _deleteTrip(int index) {
    setState(() {
      _liveTripBox.deleteAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<BucketListItem> trips = _liveTripBox.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Completed trips")),
      body: trips.isEmpty
          ? const Center(child: Text("No live trips found!"))
          : ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return ListTile(
                  title: Text(trip.name),
                  subtitle: Text("Status: ${trip.category}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTrip(index),
                      ),
                      TextButton(
                        child: const Text("View"),
                        onPressed: () {
                          // Navigate to a new screen to view trip
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewTripScreen(trip: trip),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
