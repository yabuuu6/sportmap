import 'package:sportmap/data/models/user.dart';

class Review {
  final int id;
  final int userId;
  final int sportsFieldId;
  final int rating;
  final String? comment;
  final User? user; 

  Review({
    required this.id,
    required this.userId,
    required this.sportsFieldId,
    required this.rating,
    this.comment,
    this.user,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['user_id'],
      sportsFieldId: json['sports_field_id'],
      rating: json['rating'],
      comment: json['comment'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
