class Field {
  final int id;
  final String name;
  final String location;
  final String type;
  final String? imagePath;
  final double latitude;
  final double longitude;
  final bool isVerified;
  final double rating;
  final double averageRating;
  final bool isBookmarked;

  Field({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.isVerified,
    required this.rating,
    required this.averageRating,
    required this.isBookmarked,
  });

  String? get imageUrl => imagePath != null
      ? 'http://10.0.2.2:8000/storage/$imagePath'
      : null;

  factory Field.fromJson(Map<String, dynamic> json) => Field(
        id: json['id'],
        name: json['name'],
        location: json['location'],
        type: json['type'],
        imagePath: json['image_path'],
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        rating: _toDouble(json['rating'] ?? 0),
        averageRating: _toDouble(json['average_rating'] ?? 0),
        isBookmarked:
            json['is_bookmarked'] == true || json['is_bookmarked'] == 1,
        isVerified:
            json['is_verified'] == true || json['is_verified'] == 1,
      );

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}