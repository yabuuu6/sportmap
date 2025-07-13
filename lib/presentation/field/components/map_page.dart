// routes/map_page.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _selectedLatLng;
  GoogleMapController? _controller;

  static const LatLng _defaultCenter = LatLng(-7.7956, 110.3695); // Yogyakarta

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Lokasi")),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _defaultCenter,
          zoom: 14,
        ),
        onMapCreated: (controller) => _controller = controller,
        onTap: (position) {
          setState(() => _selectedLatLng = position);
        },
        markers: _selectedLatLng != null
            ? {
                Marker(
                  markerId: const MarkerId("selected"),
                  position: _selectedLatLng!,
                )
              }
            : {},
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_selectedLatLng != null) {
            Navigator.pop(context, _selectedLatLng);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Silakan pilih lokasi dulu')),
            );
          }
        },
        icon: const Icon(Icons.check),
        label: const Text("Pilih Lokasi"),
      ),
    );
  }
}
