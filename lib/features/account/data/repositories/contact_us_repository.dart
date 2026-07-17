import 'package:get_it/get_it.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class ContactUsRepository {
  final ApiClient _apiClient;

  ContactUsRepository() : _apiClient = GetIt.instance<ApiClient>();

  Future<void> submitContactForm({
    required String name,
    required String email,
    required String phone,
    required String type,
    required String subject,
    required String message,
  }) async {
    await _apiClient.post(
      ApiEndpoints.contactUs,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'type': type,
        'subject': subject,
        'message': message,
      },
    );
  }
}
