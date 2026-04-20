
import 'dart:convert';
import 'package:dio/dio.dart';

abstract class MessageRemoteDataSource {
  Future<Map<String, dynamic>> getMessages(String sessionId, String jid);
}

class MessageRemoteDataSourceImpl implements MessageRemoteDataSource {
  final Dio dio;

  MessageRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> getMessages(String sessionId, String jid) async {
    try {
      final response = await dio.get('/whatsapp/messages/$sessionId/$jid');

      if (response.data is String) {
        return jsonDecode(response.data) as Map<String, dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        throw Exception("Format response tidak didukung");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data is String 
            ? jsonDecode(e.response!.data) 
            : e.response!.data;
      } else {
        throw Exception("Tidak dapat terhubung ke server");
      }
    }
  }
}