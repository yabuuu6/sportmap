import 'package:flutter/material.dart';
import 'package:sportmap/data/models/field.dart';
import 'package:sportmap/presentation/admin/pages/admin_dashboard.dart';
import 'package:sportmap/presentation/auth/pages/login_page.dart';
import 'package:sportmap/presentation/auth/pages/register_page.dart';
import 'package:sportmap/presentation/dashboard/pages/dashboard_page.dart';
import 'package:sportmap/presentation/field/components/add_field.dart';
import 'package:sportmap/presentation/field/components/edit_field.dart';
import 'package:sportmap/presentation/field/components/field_detail.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String adminDashboard = '/adminDashboard'; 
  static const String detailField = '/detailField';
  static const String addField = '/addField';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardPage());
      case detailField:
        final field = settings.arguments as Field;
        return MaterialPageRoute(
          builder: (_) => FieldDetailPage(field: field),
        );
      case addField:
        return MaterialPageRoute(builder: (_) => const AddFieldPage());
      case '/editField':
        final field = settings.arguments as Field;
        return MaterialPageRoute(
          builder: (_) => EditFieldPage(field: field),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('404 - Halaman tidak ditemukan')),
          ),
        );
    }
  }
}
