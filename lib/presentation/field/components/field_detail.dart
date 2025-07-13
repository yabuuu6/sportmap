import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sportmap/data/models/field.dart';
import 'package:sportmap/data/models/review.dart';
import 'package:sportmap/service/field_service.dart';

class FieldDetailPage extends StatefulWidget {
  final Field field;

  const FieldDetailPage({Key? key, required this.field}) : super(key: key);

  @override
  State<FieldDetailPage> createState() => _FieldDetailPageState();
}

class _FieldDetailPageState extends State<FieldDetailPage> {
  final FieldService _fieldService = FieldService();
  final _commentController = TextEditingController();
  int _selectedRating = 0;
  late Future<List<Review>> _futureReviews;
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    setState(() {
      _futureReviews = _fieldService.getReviews(widget.field.id);
    });
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan beri rating terlebih dahulu')),
      );
      return;
    }

    try {
      await _fieldService.submitReview(
        fieldId: widget.field.id,
        rating: _selectedRating,
        comment: _commentController.text.trim(),
      );

      _commentController.clear();
      _selectedRating = 0;
      _loadReviews();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review berhasil dikirim')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim review: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.field;
    final LatLng fieldLocation = LatLng(field.latitude, field.longitude);

    return Scaffold(
      appBar: AppBar(title: Text(field.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Gambar lapangan dengan error fallback
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: field.imageUrl != null
                  ? Image.network(
                      field.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Center(child: Text('Gagal memuat gambar')),
                      ),
                    )
                  : Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Center(child: Text('Tidak ada gambar')),
                    ),
            ),
            const SizedBox(height: 12),

            // ✅ Lokasi Google Maps
            SizedBox(
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: fieldLocation,
                    zoom: 16,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('field_location'),
                      position: fieldLocation,
                    ),
                  },
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  zoomControlsEnabled: false,
                  liteModeEnabled: true,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ✅ Informasi dasar
            Text(field.location, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) => Icon(
                    i < field.rating.round()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                  )),
            ),
            const SizedBox(height: 24),

            // ✅ Form Ulasan
            const Text('Beri Ulasan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) => IconButton(
                    icon: Icon(
                      i < _selectedRating
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () => setState(() => _selectedRating = i + 1),
                  )),
            ),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Komentar',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _selectedRating > 0 ? _submitReview : null,
              child: const Text('Kirim Review'),
            ),

            const SizedBox(height: 24),
            const Text('Review Pengguna',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // ✅ Review dari pengguna
            FutureBuilder<List<Review>>(
              future: _futureReviews,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Gagal memuat review: ${snapshot.error}');
                } else if (snapshot.data!.isEmpty) {
                  return const Text('Belum ada review.');
                }
                return Column(
                  children: snapshot.data!.map((review) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(review.user?.name ?? 'User'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(5, (i) => Icon(
                                    i < review.rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 16,
                                    color: Colors.amber,
                                  )),
                            ),
                            const SizedBox(height: 4),
                            Text(review.comment ?? ''),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}