import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_bucket_list/models/bucket_list_item.dart';
import 'package:travel_bucket_list/providers/trip_provider.dart';
import 'gomaps_pro_service.dart';
import 'add_destination_screen.dart';
import 'saved_destinations_screen.dart';
import 'start_live_trip_screen.dart';
import 'live_trips_screen.dart';
import 'currency_converter_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isFabExpanded = false;
  bool _isNavigating = false; // Track whether navigation is active

  late GoogleMapController mapController;
  final LatLng _initialPosition =
      const LatLng(37.42796133580664, -122.085749655962);
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _currentLocation;

  TextEditingController _startLocationController = TextEditingController();
  TextEditingController _destinationLocationController =
      TextEditingController();

  final GoMapsProService _goMapsProService = GoMapsProService();

  @override
  Widget build(BuildContext context) {
    // Access ongoing trips from the TripProvider
    final ongoingTrips = Provider.of<TripProvider>(context).ongoingTrips;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "Menu",
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true, // Enable default current location button
            myLocationButtonEnabled: true, // Show the default location button
            zoomControlsEnabled: true,
          ),
          Positioned(
            top: 180,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                _showNavigationDialog();
              },
              child: const Icon(Icons.navigation),
              backgroundColor: Colors.blue,
            ),
          ),
          if (_isNavigating) // Show "Stop Navigation" button when navigating
            Positioned(
              top: 100,
              right: 20,
              child: FloatingActionButton(
                onPressed: _stopNavigation,
                child: const Icon(Icons.stop),
                backgroundColor: Colors.red,
              ),
            ),
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.1,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 3,
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: ListView(
                  controller: scrollController,
                  children: [
                    const Text(
                      "Trips",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Ongoing Trips",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    // Display ongoing trips using the provider
                    ...ongoingTrips.map((trip) {
                      return ListTile(
                        title: Text(trip.name),
                        subtitle: Text(trip.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final updatedTrip = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StartLiveTripScreen(
                                      trip: trip, // Pass the trip to edit
                                    ),
                                  ),
                                );

                                if (updatedTrip != null) {
                                  // Update the trip in the provider
                                  Provider.of<TripProvider>(context,
                                          listen: false)
                                      .updateOngoingTrip(updatedTrip);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                // Delete the trip from the provider
                                Provider.of<TripProvider>(context,
                                        listen: false)
                                    .deleteOngoingTrip(trip);
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isFabExpanded) ...[
            FloatingActionButton.extended(
              heroTag: "addTrip",
              onPressed: () {
                setState(() => _isFabExpanded = false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddDestinationScreen()),
                );
              },
              icon: const Icon(Icons.add_location),
              label: const Text("Add Featured Trip"),
              backgroundColor: Colors.blue,
            ),
            const SizedBox(height: 8),
            FloatingActionButton.extended(
              heroTag: "startLiveTrip",
              onPressed: () async {
                setState(() => _isFabExpanded = false);
                final trip = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StartLiveTripScreen()),
                );

                if (trip != null) {
                  // Add the trip to the ongoing trips list using the provider
                  Provider.of<TripProvider>(context, listen: false)
                      .addOngoingTrip(trip);
                }
              },
              icon: const Icon(Icons.directions_run),
              label: const Text("Start Live Trip"),
              backgroundColor: Colors.green,
            ),
            const SizedBox(height: 8),
          ],
          FloatingActionButton(
            onPressed: _toggleFab,
            child: Icon(_isFabExpanded ? Icons.close : Icons.add),
            backgroundColor: const Color.fromARGB(255, 56, 96, 128),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 56, 91, 121),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'completed Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_travel),
            label: 'Saved Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_exchange),
            label: 'Currency',
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LiveTripsScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const SavedDestinationsScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const CurrencyConverterScreen()),
      );
    }
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _startNavigation() async {
    String startLocation = _startLocationController.text;
    String destinationLocation = _destinationLocationController.text;

    if (startLocation.isNotEmpty && destinationLocation.isNotEmpty) {
      try {
        var directions = await _goMapsProService.getNavigationDirections(
            startLocation, destinationLocation);

        if (directions.isNotEmpty) {
          var route = directions['routes'][0];
          var polylinePoints = route['overview_polyline']['points'];

          List<LatLng> polylineCoordinates = _decodePoly(polylinePoints);

          setState(() {
            _markers.clear();
            _markers.add(
              Marker(
                markerId: MarkerId('start'),
                position: _currentLocation ?? _initialPosition,
                infoWindow: InfoWindow(title: 'Start'),
              ),
            );
            _markers.add(
              Marker(
                markerId: MarkerId('destination'),
                position: LatLng(route['legs'][0]['end_location']['lat'],
                    route['legs'][0]['end_location']['lng']),
                infoWindow: InfoWindow(title: 'Destination'),
              ),
            );
            _polylines.clear();
            _polylines.add(
              Polyline(
                polylineId: PolylineId('route'),
                points: polylineCoordinates,
                color: Colors.blue,
                width: 5,
              ),
            );
            _isNavigating = true; // Set navigation state to active
          });

          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Navigation Started")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter valid start and destination")));
    }
  }

  void _stopNavigation() {
    setState(() {
      _markers.clear(); // Clear markers
      _polylines.clear(); // Clear polylines
      _isNavigating = false; // Set navigation state to inactive
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Navigation Stopped")));
  }

  List<LatLng> _decodePoly(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0;
      int result = 0;
      while (true) {
        int byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
        if (byte < 0x20) break;
      }
      int dLat = (result & 0x01) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;

      shift = 0;
      result = 0;
      while (true) {
        int byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
        if (byte < 0x20) break;
      }
      int dLng = (result & 0x01) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polylineCoordinates;
  }

  // Navigation dialog box
  void _showNavigationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Start Navigation"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _startLocationController,
                decoration: const InputDecoration(
                  labelText: "Start Location",
                ),
              ),
              TextField(
                controller: _destinationLocationController,
                decoration: const InputDecoration(
                  labelText: "Destination Location",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: _startNavigation,
              child: const Text("Start"),
            ),
          ],
        );
      },
    );
  }
}
