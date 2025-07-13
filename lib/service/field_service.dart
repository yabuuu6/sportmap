import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sportmap/data/models/review.dart';
import '../data/models/field.dart';

class FieldService {
  final _baseUrl = 'http://10.0.2.2:8000/api';
  final _storage = const FlutterSecureStorage();

  Future<List<Field>> getRecommendedFields() async {
    final token = await _storage.read(key: 'token');
    final response = await http.get(
      Uri.parse('$_baseUrl/fields/recommendation'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((e) => Field.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data rekomendasi');
    }
  }
      Future<void> addField({
    required String name,
    required String location,
    required String type,
    required double latitude,
    required double longitude,
    required File imageFile,
  }) async {
    final token = await _storage.read(key: 'token');
    final uri = Uri.parse('$_baseUrl/fields');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = name
      ..fields['location'] = location
      ..fields['type'] = type
      ..fields['latitude'] = latitude.toString()
      ..fields['longitude'] = longitude.toString()
      ..files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Gagal menambahkan lapangan');
    }
  }

  Future<List<Field>> getAllFields() async {
    final token = await _storage.read(key: 'token');
    final response = await http.get(
      Uri.parse('$_baseUrl/fields'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((e) => Field.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data lapangan');
    }
  }

  Future<void> toggleBookmark(int fieldId) async {
    final token = await _storage.read(key: 'token');
    final response = await http.post(
      Uri.parse('$_baseUrl/bookmarks/$fieldId/toggle'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal toggle bookmark');
    }
  }
  Future<List<Review>> getReviews(int fieldId) async {
    final token = await _storage.read(key: 'token');
    final response = await http.get(
      Uri.parse('$_baseUrl/fields/$fieldId/reviews'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'];
      return data.map((r) => Review.fromJson(r)).toList();
    } else {
      throw Exception('Gagal memuat review');
    }
  }

  Future<void> submitReview({
  required int fieldId,
  required int rating,
  String? comment,
  }) async {
    final token = await _storage.read(key: 'token');
    final response = await http.post(
    Uri.parse('$_baseUrl/fields/$fieldId/reviews'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'rating': rating,
      'comment': comment,
    }),
  );
    if (response.statusCode != 201) {
      print(response.body);
      throw Exception('Gagal menyimpan review');
    }
  }

  Future<Field> getFieldDetail(int fieldId) async {
    final token = await _storage.read(key: 'token');
    final response = await http.get(
      Uri.parse('$_baseUrl/fields/$fieldId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return Field.fromJson(data);
    } else {
      final error = jsonDecode(response.body)['message'] ?? 'Gagal memuat detail lapangan';
      throw Exception(error);
    }
  }
    Future<void> deleteField(int fieldId) async {
    final token = await _storage.read(key: 'token');
    final response = await http.delete(
      Uri.parse('$_baseUrl/fields/$fieldId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['message'] ?? 'Gagal menghapus lapangan';
      throw Exception(error);
    }
  }
  Future<void> updateField({
  required int id,
  required String name,
  required String location,
  required String type,
  required double latitude,
  required double longitude,
  File? imageFile,
}) async {
  final token = await _storage.read(key: 'token');

  final uri = Uri.parse('$_baseUrl/fields/$id');
  final request = http.MultipartRequest('POST', uri)
    ..fields['name'] = name
    ..fields['location'] = location
    ..fields['type'] = type
    ..fields['latitude'] = latitude.toString()
    ..fields['longitude'] = longitude.toString()
    ..headers['Authorization'] = 'Bearer $token'
    ..headers['Accept'] = 'application/json'
    ..headers['X-HTTP-Method-Override'] = 'PUT';

  if (imageFile != null) {
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
  }

  final response = await request.send();

  if (response.statusCode != 200) {
    final respStr = await response.stream.bytesToString();
    throw Exception('Gagal update: $respStr');
  }
}
Future<List<Field>> getBookmarkedFields() async {
  final token = await _storage.read(key: 'token');
  
  final response = await http.get(
    Uri.parse('$_baseUrl/bookmarks'),
    headers: {
      HttpHeaders.authorizationHeader: 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(response.body)['data'];
    return jsonList.map((json) => Field.fromJson(json)).toList();
  } else {
    throw Exception('Gagal memuat bookmark');
  }
}
Future<void> verifyField(int fieldId) async {
  final token = await _storage.read(key: 'token');
  final response = await http.put(
    Uri.parse('$_baseUrl/fields/$fieldId'),
    headers: {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.contentTypeHeader: 'application/json',
    },
    body: jsonEncode({
      'is_verified': true,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Gagal memverifikasi lapangan');
  }
}
Future<Field> uploadFieldPhoto({
  required int fieldId,
  required File imageFile,
}) async {
  final token = await _storage.read(key: 'token');

  final uri = Uri.parse('$_baseUrl/fields/$fieldId/photos');
  final request = http.MultipartRequest('POST', uri)
    ..headers['Authorization'] = 'Bearer $token'
    ..headers['Accept'] = 'application/json'
    ..files.add(await http.MultipartFile.fromPath('image_path', imageFile.path));

  final response = await request.send();

  final respStr = await response.stream.bytesToString();

  if (response.statusCode != 200) {
    throw Exception('Gagal upload foto: $respStr');
  }

  final json = jsonDecode(respStr);
  final updatedField = Field.fromJson(json['data']['field']);
  return updatedField;
}

}
