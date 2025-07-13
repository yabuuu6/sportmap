import 'package:flutter/material.dart';
import 'package:sportmap/presentation/field/components/bookmark_page.dart';
import 'package:sportmap/presentation/dashboard/components/top_app_bar.dart';
import 'package:sportmap/presentation/dashboard/components/home_page.dart';
import 'package:sportmap/presentation/field/pages/field_list.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    FieldList(),
    BookmarkedFieldsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _handleLogout() async {
    Navigator.pushReplacementNamed(context, '/login');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Berhasil keluar')),
    );
  }

  void _handleAccount() {
    Navigator.pushNamed(context, '/account');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: 'SportMap Dashboard',
        onLogout: _handleLogout,
        onAccount: _handleAccount,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Lapangan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmark',
          ),
        ],
      ),
    );
  }
}