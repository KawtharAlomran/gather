import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:gather/Pages/home_page.dart';
import 'package:gather/Pages/time_preference_screen.dart';
import 'package:gather/data/repositories/preference_repository.dart';
import 'package:gather/models/preference_model.dart';
import 'package:gather/shared_widgets/app_button.dart';
import 'package:gather/shared_widgets/app_card.dart';
import 'package:gather/shared_widgets/app_message.dart';

class LocationPreferenceScreen extends StatefulWidget {
  final Map<DateTime, String> selectedTimes; // Stores the selected time for each date
  final List<String> selectedActivities; // Stores the selected activities
  final List<DateTime> selectedDates; // Stores the selected dates
  
  // Constructor for the LocationPreferenceScreen
  const LocationPreferenceScreen({
    super.key,
    required this.selectedDates,
    required this.selectedTimes,
    required this.selectedActivities,
  });

  @override
  State<LocationPreferenceScreen> createState() =>
      _LocationPreferenceScreenState();
}

class _LocationPreferenceScreenState
    extends State<LocationPreferenceScreen> {
  final PreferenceRepository repository = MockPreferenceRepository(); 
  final MapController mapController = MapController();
  final TextEditingController suggestedLocationController =
      TextEditingController(); // Controller for the suggested location input field

  LatLng selectedLocation = const LatLng(24.7136, 46.6753); // Default location (Riyadh, Saudi Arabia)

  String locationName = 'Finding your location...';

  final List<String> suggestedLocations = []; // List to store suggested locations
  
  // Function to get the name of a location based on its coordinates
  Future<String> getLocationName(LatLng point) async {
    try {
      final Geocoding geocoding = Geocoding();
      final List<Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      if (placemarks.isEmpty) {
        return '${point.latitude}, ${point.longitude}';
      }

      final Placemark place = placemarks.first;

      final List<String> parts = [
        place.name,
        place.street,
        place.locality,
        place.country,
      ].whereType<String>().where((value) {
        return value.trim().isNotEmpty;
      }).toList();

      return parts.isEmpty
          ? '${point.latitude}, ${point.longitude}'
          : parts.join(', ');
    } catch (_) {
      return '${point.latitude}, ${point.longitude}';
    }
  }

  // Initialize the state of the LocationPreferenceScreen
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserLocation();
    });
  }

  // Dispose of the controllers when the widget is removed from the widget tree
  @override
  void dispose() {
    suggestedLocationController.dispose();
    super.dispose();
  }

  // Function to get the user's current location
  Future<void> getUserLocation() async {
    try {
      final bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        setState(() {
          locationName = 'Please enable location services';
        });
        return;
      }
      
      // Check and request location permissions
      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          locationName =
              'Location permission was denied. Tap the map to select.';
        });
        return;
      }

      // Get the current position of the user
      final Position position =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final LatLng userLocation = LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        selectedLocation = userLocation;
      });

      mapController.move(userLocation, 15);

      await selectLocation(userLocation);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        locationName =
            'Could not find your location. Tap the map to select.';
      });
    }
  }

  // Function to select a location on the map and get its name
  Future<void> selectLocation(LatLng point) async {
    if (!mounted) return;

    setState(() {
      selectedLocation = point;
      locationName = 'Loading location...';
    });

    try {
      final Geocoding geocoding = Geocoding();

      final List<Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;

        final List<String> parts = [
          place.name,
          place.street,
          place.locality,
          place.country,
        ].whereType<String>().where((value) {
          return value.trim().isNotEmpty;
        }).toList();

        setState(() {
          locationName = parts.isEmpty
              ? '${point.latitude}, ${point.longitude}'
              : parts.join(', ');
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        locationName =
            '${point.latitude.toStringAsFixed(5)}, '
            '${point.longitude.toStringAsFixed(5)}';
      });
    }
  }

  // Function to add a suggested location to the list
  void addSuggestedLocation() {
    final String location =
        suggestedLocationController.text.trim();

    if (location.isEmpty) return;

    if (!suggestedLocations.contains(location)) {
      setState(() {
        suggestedLocations.add(location);
      });
    }

    suggestedLocationController.clear();
  }
  
  // Function to select a suggested location from the map
  Future<void> selectSuggestedLocation() async {
    final LatLng? selectedPoint = await showDialog<LatLng>(
      context: context,
      builder: (context) {
        LatLng temporaryLocation = selectedLocation;

        return AlertDialog(
          title: const Text('Select suggested location'),
          content: SizedBox(
            width: double.maxFinite,
            height: 350,
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return FlutterMap(
                  options: MapOptions(
                    initialCenter: temporaryLocation,
                    initialZoom: 13,
                    onTap: (_, point) {
                      setDialogState(() {
                        temporaryLocation = point;
                      });
                    },
                  ),
                  children: [
                    // Display the map tiles from OpenStreetMap
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.gather',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: temporaryLocation,
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                    // Display attribution for OpenStreetMap contributors
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, temporaryLocation);
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );

    if (selectedPoint == null) return;

    final String location = await getLocationName(selectedPoint);

    if (!mounted) return;

    setState(() {
      if (!suggestedLocations.contains(location)) {
        suggestedLocations.add(location);
      }
    });
  }

  // Function to save the user's preferences, including selected dates, times, activities, and location
  Future<void> savePreferences() async {
    if (locationName == 'Finding your location...' ||
        locationName == 'Loading location...' ||
        locationName.startsWith('Please enable') ||
        locationName.startsWith('Location permission') ||
        locationName.startsWith('Could not find')) {
      AppMessage.show(
        context,
        message: 'Please select a valid location',
        type: MessageType.error,
      );
      return;
    }

    // Create a PreferenceModel instance with the selected preferences
    final PreferenceModel preferences = PreferenceModel(
      dates: widget.selectedDates,
      times: widget.selectedTimes,
      activities: widget.selectedActivities,
      location: locationName,
      suggestedLocations: suggestedLocations,
    );

    await repository.savePreferences(preferences);

    if (!mounted) return;
    // Show a success message to the user
    AppMessage.show(
      context,
      message: 'Preferences saved successfully!',
      type: MessageType.success,
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomePage(),
      ),
    );
  }
  
  // Build the UI for the LocationPreferenceScreen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Preferences',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const TimePreferenceScreen(),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your location',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),

            AppCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 300,
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: selectedLocation,
                      initialZoom: 12,
                      onTap: (_, point) {
                        selectLocation(point);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.gather',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selectedLocation,
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 50,
                            ),
                          ),
                        ],
                      ),
                      RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution(
                            'OpenStreetMap contributors',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(locationName),

            const SizedBox(height: 24),

            Text(
              'Suggested locations',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 10),

            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select location',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Optional',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  InkWell(
                    onTap: selectSuggestedLocation,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey.shade600,
                            size: 30,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Select from the map',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: selectSuggestedLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF755C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestedLocations.map((location) {
                return Chip(
                  label: Text(location),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      suggestedLocations.remove(location);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            AppButton(
              text: 'Save Preferences',
              onPressed: savePreferences,
            ),
          ],
        ),
      ),
    );
  }
}