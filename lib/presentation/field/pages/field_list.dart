import 'package:flutter/material.dart';
import 'package:sportmap/data/models/field.dart';
import 'package:sportmap/service/field_service.dart';

class FieldList extends StatefulWidget {
  const FieldList({super.key});

  @override
  State<FieldList> createState() => _FieldListState();
}

class _FieldListState extends State<FieldList> {
  final FieldService _fieldService = FieldService();
  late Future<List<Field>> _futureFields;
  List<Field> _allFields = [];
  List<Field> _filteredFields = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFields();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadFields() async {
    try {
      final fields = await _fieldService.getAllFields();
      setState(() {
        _allFields = fields;
        _filteredFields = fields;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFields = _allFields
          .where((f) => f.name.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _handleBookmark(Field field) async {
    try {
      await _fieldService.toggleBookmark(field.id);
      _loadFields();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(field.isBookmarked
              ? 'Bookmark dihapus'
              : 'Ditambahkan ke bookmark'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal toggle bookmark: $e')),
      );
    }
  }

  void _showUnverifiedOptions(BuildContext context, Field field) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lapangan belum diverifikasi',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit Lapangan'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/editField', arguments: field);
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Batalkan Tambah Lapangan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Konfirmasi'),
                      content: const Text('Yakin ingin menghapus lapangan ini?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal')),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Ya, hapus')),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    try {
                      await _fieldService.deleteField(field.id);
                      _loadFields();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lapangan dihapus')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal hapus: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Lapangan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cari nama lapangan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredFields.isEmpty
                ? const Center(child: Text('Lapangan tidak ditemukan'))
                : ListView.builder(
                    itemCount: _filteredFields.length,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index) {
                      final field = _filteredFields[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: const Icon(
                            Icons.sports_soccer,
                            color: Colors.deepPurple,
                            size: 32,
                          ),
                          title: Text(
                            field.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(field.location),
                              const SizedBox(height: 6),
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    i < field.rating.round()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 18,
                                  );
                                }),
                              ),
                              if (!field.isVerified)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Chip(
                                    label: const Text('Belum Diverifikasi'),
                                    backgroundColor: Colors.red.shade100,
                                    labelStyle:
                                        const TextStyle(color: Colors.red),
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  field.isBookmarked
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  size: 20,
                                  color: Colors.deepPurple,
                                ),
                                onPressed: () => _handleBookmark(field),
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Colors.grey),
                            ],
                          ),
                          onTap: () {
                            if (!field.isVerified) {
                              _showUnverifiedOptions(context, field);
                            } else {
                              Navigator.pushNamed(
                                context,
                                '/detailField',
                                arguments: field,
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addField');
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
