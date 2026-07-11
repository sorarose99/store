import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String uuid;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? gender;
  final String? birthDate;
  final String? token;

  const User({
    required this.id,
    required this.uuid,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.avatar,
    this.gender,
    this.birthDate,
    this.token,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
        id,
        uuid,
        firstName,
        lastName,
        email,
        phone,
        avatar,
        gender,
        birthDate,
        token
      ];
}
