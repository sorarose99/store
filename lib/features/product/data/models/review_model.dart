import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.userName,
    required super.userAvatar,
    required super.rating,
    required super.date,
    required super.comment,
    required super.likes,
    super.attachedImage,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final firstName = user?['first_name'] as String? ?? '';
    final lastName = user?['last_name'] as String? ?? '';
    final userNameStr = (firstName.isEmpty && lastName.isEmpty)
        ? (json['user_name'] as String? ?? 'عميل')
        : '$firstName $lastName'.trim();

    final avatarStr =
        user?['avatar'] as String? ?? (json['user_avatar'] as String? ?? '');

    // Format date from created_at
    String dateStr = json['date'] as String? ?? '';
    if (dateStr.isEmpty && json['created_at'] != null) {
      final createdAt = DateTime.tryParse(json['created_at'].toString());
      if (createdAt != null) {
        dateStr = '${createdAt.year}/${createdAt.month}/${createdAt.day}';
      }
    }

    return ReviewModel(
      id: json['id']?.toString() ?? '',
      userName: userNameStr,
      userAvatar:
          avatarStr.isNotEmpty ? avatarStr : 'https://i.pravatar.cc/100',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      date: dateStr,
      comment: json['comment'] as String? ?? '',
      likes: json['likes'] as int? ?? 0,
      attachedImage: json['attached_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'user_avatar': userAvatar,
      'rating': rating,
      'date': date,
      'comment': comment,
      'likes': likes,
      'attached_image': attachedImage,
    };
  }
}
