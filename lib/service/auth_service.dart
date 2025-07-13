import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final _baseUrl = 'http://10.0.2.2:8000/api';
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final response = await http.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
      },
      body: jsonEncode(body),
    );
    return response;
  }

Future<Map<String, dynamic>> getProfile() async {
  final token = await secureStorage.read(key: 'token');
  final url = Uri.parse('$_baseUrl/user');

  final response = await http.get(
    url,
    headers: {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.acceptHeader: 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final userData = data['data'];

    await secureStorage.write(key: 'user_id', value: userData['id'].toString());
    await secureStorage.write(key: 'name', value: userData['name']);
    await secureStorage.write(key: 'email', value: userData['email']);
    await secureStorage.write(key: 'role', value: userData['role']);

    return userData;
  } else {
    throw Exception('Gagal mengambil profil user: ${response.statusCode}');
  }
}

  Future<void> logout() async {
    await secureStorage.delete(key: 'token');
  }
}
