import 'package:flutter/material.dart';
import 'package:sportmap/data/models/field.dart';
import 'package:sportmap/presentation/admin/components/app_bar.dart';
import 'package:sportmap/presentation/admin/components/bottom_bar.dart';
import 'package:sportmap/presentation/field/components/add_field.dart';
import 'package:sportmap/presentation/field/components/edit_field.dart';
import 'package:sportmap/presentation/field/components/field_detail.dart';
import 'package:sportmap/service/field_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;
  final FieldService _fieldService = FieldService();
  late Future<List<Field>> _futureFields;

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  void _loadFields() {
    setState(() {
      _futureFields = _fieldService.getAllFields();
    });
  }

  Future<void> _verifyField(int fieldId) async {
    try {
      await _fieldService.verifyField(fieldId);
      _loadFields();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lapangan berhasil diverifikasi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal verifikasi: $e')),
      );
    }
  }

  Future<void> _deleteField(int fieldId) async {
    try {
      await _fieldService.deleteField(fieldId);
      _loadFields();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lapangan berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: $e')),
      );
    }
  }

  Widget _buildVerifyTab() {
  return FutureBuilder<List<Field>>(
    future: _futureFields,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }
      final fields = snapshot.data ?? [];
      final unverified = fields.where((f) => !f.isVerified).toList();
      if (unverified.isEmpty) {
        return const Center(child: Text('Tidak ada lapangan yang perlu diverifikasi'));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: unverified.length,
        itemBuilder: (context, index) {
          final field = unverified[index];
          return InkWell(
            onTap: () {
              Navigator.push<int?>(
                context,
                MaterialPageRoute(
                  builder: (_) => FieldDetailPage(field: field),
                ),
              ).then((verifiedId) {
                if (verifiedId != null) {
                  _verifyField(verifiedId);
                }
              });
            },
            child: Card(
              child: ListTile(
                leading: field.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          field.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.image, size: 40),
                title: Text(field.name),
                subtitle: Text(field.location),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              ),
            ),
          );
        },
      );
    },
  );
}

 Widget _buildManageTab() {
  return FutureBuilder<List<Field>>(
    future: _futureFields,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }
      final fields = snapshot.data ?? [];
      if (fields.isEmpty) return const Center(child: Text('Belum ada lapangan'));

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: fields.length,
        itemBuilder: (context, index) {
          final field = fields[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FieldDetailPage(field: field),
                ),
              );
            },
            child: Card(
              child: ListTile(
                leading: field.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          field.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.image_not_supported, size: 40),
                title: Text(field.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(field.location),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          field.isVerified ? Icons.verified : Icons.warning_amber,
                          size: 16,
                          color: field.isVerified ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          field.isVerified ? 'Terverifikasi' : 'Belum diverifikasi',
                          style: TextStyle(
                            fontSize: 12,
                            color: field.isVerified ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditFieldPage(field: field),
                          ),
                        ).then((_) => _loadFields());
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteField(field.id),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildVerifyTab(),
      const AddFieldPage(),
      _buildManageTab(),
    ];

    return Scaffold(
      appBar: const AdminAppBar(title: 'Admin Dashboard'),
      body: pages[_selectedIndex],
      bottomNavigationBar: AdminBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}