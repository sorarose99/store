import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String date;
  final String comment;
  final int likes;
  final String? attachedImage;

  const ReviewEntity({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.date,
    required this.comment,
    required this.likes,
    this.attachedImage,
  });

  @override
  List<Object?> get props => [
        id,
        userName,
        userAvatar,
        rating,
        date,
        comment,
        likes,
      ];
}
