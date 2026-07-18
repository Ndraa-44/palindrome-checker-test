import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserPageModel> getUsers({required int page, required int perPage});
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final http.Client client;

  UserRemoteDataSourceImpl({required this.client});

  @override
  Future<UserPageModel> getUsers({required int page, required int perPage}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/users?page=$page&per_page=$perPage');
    final response = await client.get(uri, headers: {
      'x-api-key': ApiConstants.apiKey,
    });
    
    if (response.statusCode == 200) {
      return UserPageModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }
}
