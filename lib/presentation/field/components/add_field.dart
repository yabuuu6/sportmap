import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sportmap/service/field_service.dart';

class AddFieldPage extends StatefulWidget {
  const AddFieldPage({super.key});

  @override
  State<AddFieldPage> createState() => _AddFieldPageState();
}

class _AddFieldPageState extends State<AddFieldPage> {
  final _formKey = GlobalKey<FormState>();
  final _fieldService = FieldService();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _typeController = TextEditingController();

  File? _image;
  LatLng _selectedLocation = const LatLng(-7.7956, 110.3695);
  late GoogleMapController _mapController;

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
                  final savedImage = await _saveImageToLocal(picked); // opsional
                  setState(() => _image = savedImage);
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
                  final savedImage = await _saveImageToLocal(picked); // opsional
                  setState(() => _image = savedImage);
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<File> _saveImageToLocal(XFile image) async {
    final dir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${dir.path}/images');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    final newPath = p.join(imageDir.path, p.basename(image.path));
    return File(image.path).copy(newPath);
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _image != null) {
      try {
        await _fieldService.addField(
          name: _nameController.text,
          location: _locationController.text,
          type: _typeController.text,
          latitude: _selectedLocation.latitude,
          longitude: _selectedLocation.longitude,
          imageFile: _image!,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lapangan berhasil ditambahkan')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data dan pilih lokasi & gambar')),
      );
    }
  }

  void _onMapTap(LatLng position) {
    setState(() => _selectedLocation = position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Lapangan')),
      body: SingleChildScrollView(
        child: Padding(
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
                  decoration: const InputDecoration(labelText: 'Jenis Lapangan (futsal, basket, dll)'),
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
                    child: _image == null
                        ? const Center(child: Text('Pilih Gambar'))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_image!, fit: BoxFit.cover),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Lapangan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
