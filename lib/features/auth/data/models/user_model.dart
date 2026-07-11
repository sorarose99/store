import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.uuid,
    required super.firstName,
    required super.lastName,
    super.email,
    super.phone,
    super.avatar,
    super.gender,
    super.birthDate,
    super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userData =
        json['user'] is Map ? json['user'] as Map<String, dynamic> : json;

    final token = json['token']?.toString() ??
        json['access_token']?.toString() ??
        userData['token']?.toString();

    String avatarUrl = userData['avatar']?.toString() ?? '';
    if (avatarUrl.isNotEmpty) {
      avatarUrl = ApiEndpoints.mediaUrl(avatarUrl);
    }

    return UserModel(
      id: (userData['id'] ?? '').toString(),
      uuid: userData['uuid']?.toString() ?? '',
      firstName: userData['first_name']?.toString() ??
          userData['name']?.toString() ??
          '',
      lastName: userData['last_name']?.toString() ?? '',
      email: userData['email']?.toString(),
      phone: userData['phone']?.toString(),
      avatar: avatarUrl,
      gender: userData['gender']?.toString(),
      birthDate: userData['birth_date']?.toString(),
      token: token,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'gender': gender,
      'birth_date': birthDate,
      'token': token,
    };
  }
}
