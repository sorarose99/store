import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final String date;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
  });

  @override
  List<Object?> get props => [id, title, message, date];
}
