import 'package:flutter/material.dart';
import 'package:travel_bucket_list/models/bucket_list_item.dart'; // Assuming BucketListItem is defined in this file.

class TripProvider with ChangeNotifier {
  List<BucketListItem> _ongoingTrips = [];

  // Getter to access the list of ongoing trips
  List<BucketListItem> get ongoingTrips => _ongoingTrips;

  // Method to add a trip to the list
  void addOngoingTrip(BucketListItem trip) {
    _ongoingTrips.add(trip);
    notifyListeners(); // Notify listeners that the state has changed
  }

  // Method to update an existing trip in the list
  void updateOngoingTrip(BucketListItem updatedTrip) {
    final index =
        _ongoingTrips.indexWhere((trip) => trip.name == updatedTrip.name);
    if (index != -1) {
      _ongoingTrips[index] = updatedTrip; // Update the trip at the found index
      notifyListeners(); // Notify listeners that the state has changed
    }
  }

  // Method to delete a trip from the list
  void deleteOngoingTrip(BucketListItem trip) {
    _ongoingTrips.remove(trip);
    notifyListeners(); // Notify listeners that the state has changed
  }
}
