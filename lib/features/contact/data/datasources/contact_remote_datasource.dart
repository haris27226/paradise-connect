import 'package:dio/dio.dart';
import 'package:progress_group/features/contact/data/models/contact_model.dart';
import 'package:progress_group/features/contact/data/models/sales_manager_model.dart';
import '../models/contact_response_model.dart';
import '../models/owner_model.dart';
import '../models/activity_api_model.dart';
import '../models/prospect_status_model.dart';
import '../models/sales_executive_model.dart';
import '../../domain/entities/create_activity_params.dart';
import '../../domain/entities/create_contact_params.dart';

abstract class ContactRemoteDataSource {
  Future<ContactResponseModel> getContacts({  int page = 1,  int perPage = 10,  String? search,  String? startDate,  String? endDate,  int? ownerId,  int? statusProspectId,});

  Future<ContactModel> getContactDetail(int id);

  Future<List<OwnerModel>> getOwners({String search, int page});
  Future<List<ProspectStatusModel>> getProspectStatuses();
  Future<List<SalesExecutiveModel>> getSalesExecutives({String search, int page});
  Future<List<SalesManagerModel>> getSalesManagers({String search, int page});
  Future<void> createContact(CreateContactParams params);
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
  Future<ContactResponseModel> getContacts({  int page = 1,  int perPage = 10,  String? search,  String? startDate,    String? endDate,
    int? ownerId,
    int? statusProspectId,
  }) async {
    try {
      final response = await dio.get('/contacts', queryParameters: {
        'page': page,
        'per_page': perPage,
        if (search != null && search.isNotEmpty) 'search': search,
        if (startDate != null && startDate.isNotEmpty) 'start_date': startDate,
        if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
        if (ownerId != null) 'sales_executive_id': ownerId,
        if (statusProspectId != null) 'status_prospect_id': statusProspectId,
      });

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
      final response = await dio.get('/contacts/$id');
      if (response.data['status'] == true) {
        return ContactModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load contact details');
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
      final response = await dio.get('/activities', queryParameters: {
        'contact_id': contactId,
        if (dealId != null) 'deal_id': dealId,
        if (activityType != null) 'activity_type': activityType,
        'page': page,
        'per_page': perPage,
      });

      if (response.data['status'] == true) {
        return ActivityResponseModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load activities');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to load activities');
    }
  }

  @override
  Future<void> createActivity(CreateActivityParams params) async {
    try {
      final response = await dio.post('/activities/create', data: params.toJson());
      if (response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to create activity');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to create activity');
    }
  }



  @override
  Future<List<OwnerModel>> getOwners({String search = '', int page = 1}) async {
    try {
      final response = await dio.get(
        '/sales/owners',
        queryParameters: {
          'search': search,
          'per_page': 10,
          'page': page,
        },
      );
      if (response.data['status'] == true) {
        final dynamic outerData = response.data['data'];
        List listData = [];
        
        if (outerData is Map && outerData.containsKey('data')) {
          listData = outerData['data'];
        } else if (outerData is List) {
          listData = outerData;
        }
        
        return listData.map((json) => OwnerModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load owners');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to load owners');
    }
  }

  @override
  Future<List<SalesExecutiveModel>> getSalesExecutives({String search = '', int page = 1}) async {
    try {
      final response = await dio.get(
        '/sales/executives',
        queryParameters: {
          'search': search,
          'per_page': 10,
          'page': page,
        },
      );
      if (response.data['status'] == true) {
        final dynamic outerData = response.data['data'];
        List listData = [];
        if (outerData is Map && outerData.containsKey('data')) {
          listData = outerData['data'];
        } else if (outerData is List) {
          listData = outerData;
        }
        return listData.map((json) => SalesExecutiveModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load sales executives');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to load sales executives');
    }
  }

  @override
  Future<List<SalesManagerModel>> getSalesManagers({String search = '', int page = 1}) async {
    try {
      final response = await dio.get(
        '/sales/managers',
        queryParameters: {
          'search': search,
          'per_page': 10,
          'page': page,
        },
      );
      if (response.data['status'] == true) {
        final dynamic outerData = response.data['data'];
        List listData = [];
        if (outerData is Map && outerData.containsKey('data')) {
          listData = outerData['data'];
        } else if (outerData is List) {
          listData = outerData;
        }
        return listData.map((json) => SalesManagerModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load sales managers');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to load sales managers');
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
        throw Exception(response.data['message'] ?? 'Failed to load prospect statuses');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to load prospect statuses');
    }
  }


  @override
  Future<void> createContact(CreateContactParams params) async {
    try {
      final response = await dio.post('/contacts/create', data: params.toJson());
      if (response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to create contact');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to create contact');
    }
  }
}

