class ServerException implements Exception {
  final String? message;
  ServerException({this.message});
  @override
  String toString() => message ?? 'خطأ في الخادم';
}

class CacheException implements Exception {
  final String? message;
  CacheException({this.message});
  @override
  String toString() => message ?? 'خطأ في التخزين المحلي';
}

class ConnectionException implements Exception {
  final String? message;
  ConnectionException({this.message});
  @override
  String toString() => message ?? 'تعذّر الاتصال بالخادم';
}

/// 401 — Token invalid or expired
class UnauthorizedException implements Exception {
  final String? message;
  UnauthorizedException({this.message});
  @override
  String toString() => message ?? 'الجلسة منتهية. يرجى تسجيل الدخول مجدداً.';
}

/// 404 — Resource not found
class NotFoundException implements Exception {
  final String? message;
  NotFoundException({this.message});
  @override
  String toString() => message ?? 'لم يتم العثور على المورد المطلوب';
}

/// 422 — Laravel validation errors
class ValidationException implements Exception {
  final String? message;
  final Map<String, dynamic>? errors;
  ValidationException({this.message, this.errors});
  @override
  String toString() => message ?? 'بيانات غير صالحة';
}
