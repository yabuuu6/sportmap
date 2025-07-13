import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sportmap/core/utils/appstorage.dart';
import 'package:sportmap/data/models/field.dart';
import 'package:sportmap/service/field_service.dart';

class EditFieldPage extends StatefulWidget {
  final Field field;
  const EditFieldPage({super.key, required this.field});

  @override
  State<EditFieldPage> createState() => _EditFieldPageState();
}

class _EditFieldPageState extends State<EditFieldPage> {
  final _formKey = GlobalKey<FormState>();
  final _fieldService = FieldService();

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _typeController;
  File? _newImage;
  late LatLng _selectedLocation;
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.field.name);
    _locationController = TextEditingController(text: widget.field.location);
    _typeController = TextEditingController(text: widget.field.type);
    _selectedLocation = LatLng(widget.field.latitude, widget.field.longitude);
  }

  Future<void> _pickImage() async {
  showModalBottomSheet(
    context: context,
    builder: (_) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Kamera'),
            onTap: () async {
              final picked = await ImagePicker().pickImage(source: ImageSource.camera);
              if (picked != null) {
                final saved = await saveImageToLocal(picked); // simpan lokal
                setState(() => _newImage = saved);
              }
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Galeri'),
            onTap: () async {
              final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (picked != null) {
                final saved = await saveImageToLocal(picked); // simpan lokal
                setState(() => _newImage = saved);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}

  void _onMapTap(LatLng position) {
    setState(() => _selectedLocation = position);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data')),
      );
      return;
    }

    try {
      await _fieldService.updateField(
        id: widget.field.id,
        name: _nameController.text,
        location: _locationController.text,
        type: _typeController.text,
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        imageFile: _newImage,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lapangan berhasil diperbarui')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui lapangan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.field;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Lapangan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lapangan'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Alamat / Lokasi'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Jenis Lapangan'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _selectedLocation,
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('selected'),
                        position: _selectedLocation,
                      )
                    },
                    onTap: _onMapTap,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Lokasi: ${_selectedLocation.latitude.toStringAsFixed(4)}, ${_selectedLocation.longitude.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _newImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_newImage!, fit: BoxFit.cover),
                        )
                      : field.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(field.imageUrl!, fit: BoxFit.cover),
                            )
                          : const Center(child: Text('Pilih Gambar Baru')),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}