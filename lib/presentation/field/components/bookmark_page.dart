import 'package:flutter/material.dart';
import 'package:sportmap/data/models/field.dart';
import 'package:sportmap/service/field_service.dart';

class BookmarkedFieldsPage extends StatefulWidget {
  const BookmarkedFieldsPage({super.key});

  @override
  State<BookmarkedFieldsPage> createState() => _BookmarkedFieldsPageState();
}

class _BookmarkedFieldsPageState extends State<BookmarkedFieldsPage> {
  final _fieldService = FieldService();
  late Future<List<Field>> _futureBookmarks;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() {
    _futureBookmarks = _fieldService.getBookmarkedFields();
  }

  Future<void> _toggleBookmark(Field field) async {
    try {
      await _fieldService.toggleBookmark(field.id);
      setState(() {
        _loadBookmarks();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bookmark ${field.isBookmarked ? 'dihapus' : 'ditambahkan'}',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah bookmark: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lapangan yang Disukai')),
      body: FutureBuilder<List<Field>>(
        future: _futureBookmarks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }

          final fields = snapshot.data ?? [];

          if (fields.isEmpty) {
            return const Center(child: Text('Belum ada bookmark.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: fields.length,
            itemBuilder: (context, index) {
              final field = fields[index];
              return Card(
                color: const Color(0xFFF8F4FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(
                    Icons.sports_soccer,
                    color: Colors.deepPurple,
                    size: 32,
                  ),
                  title: Text(
                    field.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        field.location,
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (i) => Icon(
                              i < field.rating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 18,
                            )),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.bookmark,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () => _toggleBookmark(field),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/detailField',
                            arguments: field,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
