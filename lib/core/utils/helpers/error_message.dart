 import 'package:dio/dio.dart';

String getErrorMessage(DioException e, String defaultMessage) {
    try {
      final data = e.response?.data;

      print("DIO ERROR DATA: $data");

      if (data is Map<String, dynamic>) {
        if (data['message'] != null && data['message'].toString().isNotEmpty) {
          return data['message'].toString();
        }

        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map;

          final firstError = errors.values.first;

          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }

          return firstError.toString();
        }
      }

      if (data is String && data.isNotEmpty) {
        return data;
      }

      return e.message ?? defaultMessage;
    } catch (_) {
      return defaultMessage;
    }
  }