import 'package:dio/dio.dart';
import 'package:progress_group/features/contact/data/models/contact_model.dart';
import '../models/contact_response_model.dart';
import '../models/activity_api_model.dart';
import '../models/prospect_status_model.dart';
import '../models/contact_property_model.dart';
import '../../domain/entities/create_activity_params.dart';
import '../../domain/entities/create_contact_params.dart';

abstract class ContactRemoteDataSource {
  Future<ContactResponseModel> getContacts({
    int page = 1,
    int perPage = 10,
    String? search,
    String? startDate,
    String? endDate,
    List<int>? ownerIds,
    List<int>? statusProspectIds,
  });

  Future<ContactModel> getContactDetail(int id);

  Future<List<ProspectStatusModel>> getProspectStatuses();
  Future<List<ContactPropertyGroupModel>> getContactProperties();
  Future<void> createContact(CreateContactParams params);
  Future<void> updateContact(int id, CreateContactParams params);
  Future<void> deleteContact(int id);
  Future<ActivityResponseModel> getActivities({
    required int contactId,
    int? dealId,
    String? activityType,
    int page = 1,
    int perPage = 15,
  });
  Future<void> createActivity(CreateActivityParams params);
}

class ContactRemoteDataSourceImpl implements ContactRemoteDataSource {
  final Dio dio;

  ContactRemoteDataSourceImpl(this.dio);

  @override
  Future<ContactResponseModel> getContacts({
    int page = 1,
    int perPage = 10,
    String? search,
    String? startDate,
    String? endDate,
    List<int>? ownerIds,
    List<int>? statusProspectIds,
  }) async {
    try {
      final response = await dio.get(
        '/contacts',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (search != null && search.isNotEmpty) 'search': search,
          if (startDate != null && startDate.isNotEmpty)
            'start_date': startDate,
          if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
          if (ownerIds != null && ownerIds.isNotEmpty)
            'sales_executive_id': ownerIds.join(','),
          if (statusProspectIds != null && statusProspectIds.isNotEmpty)
            'status_prospect_id': statusProspectIds.join(','),
        },
      );

      if (response.data['status'] == true) {
        return ContactResponseModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load contacts');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to load contacts');
    }
  }

  @override
  Future<ContactModel> getContactDetail(int id) async {
    try {
      final url = '/contacts/$id';
      print('API GET: $url');
      final response = await dio.get(url);
      print('API RESPONSE for getContactDetail: ${response.data}');
      if (response.data['status'] == true) {
        return ContactModel.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to load contact details',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to load contact details');
    }
  }

  @override
  Future<ActivityResponseModel> getActivities({
    required int contactId,
    int? dealId,
    String? activityType,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await dio.get(
        '/activities',
        queryParameters: {
          'contact_id': contactId,
          if (dealId != null) 'deal_id': dealId,
          if (activityType != null) 'activity_type': activityType,
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.data['status'] == true) {
        return ActivityResponseModel.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to load activities',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to load activities');
    }
  }

  @override
  Future<void> createActivity(CreateActivityParams params) async {
    try {
      final response = await dio.post(
        '/activities/create',
        data: params.toJson(),
      );
      if (response.data['status'] != true) {
        throw Exception(
          response.data['message'] ?? 'Failed to create activity',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to create activity');
    }
  }

  @override
  Future<List<ProspectStatusModel>> getProspectStatuses() async {
    try {
      final response = await dio.get('/sales/statuses');
      if (response.data['status'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ProspectStatusModel.fromJson(json)).toList();
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to load prospect statuses',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to load prospect statuses');
    }
  }

  @override
  Future<List<ContactPropertyGroupModel>> getContactProperties() async {
    try {
      final response = await dio.get('/contacts/properties');
      if (response.data['status'] == true) {
        final List<dynamic> data = response.data['data'];
        return data
            .map((json) => ContactPropertyGroupModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to load contact properties',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to load contact properties');
    }
  }

  @override
  Future<void> createContact(CreateContactParams params) async {
    try {
      final response = await dio.post(
        '/contacts/create',
        data: params.toJson(),
      );
      if (response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to create contact');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to create contact');
    }
  }

  @override
  Future<void> updateContact(int id, CreateContactParams params) async {
    try {
      final response = await dio.patch('/contacts/$id', data: params.toJson());
      if (response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to update contact');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to update contact');
    }
  }

  @override
  Future<void> deleteContact(int id) async {
    try {
      final url = '/contacts/delete/$id';
      print('API DELETE: $url');
      final response = await dio.delete(url);
      print('API RESPONSE for deleteContact: ${response.data}');
      if (response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete contact');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to delete contact');
    }
  }
}
