import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<dynamic>> getNotifications();
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final SharedPreferences sharedPreferences;

  NotificationsRemoteDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<dynamic>> getNotifications() async {
    final List<String> notificationsJson = sharedPreferences.getStringList('local_notifications') ?? [];
    
    return notificationsJson.map((jsonStr) {
      final data = jsonDecode(jsonStr);
      return {
        'id': DateTime.now().millisecondsSinceEpoch.toString(), // Generating a temporary ID
        'title': data['title'],
        'message': data['body'],
        'date': data['time'],
      };
    }).toList();
  }
}
