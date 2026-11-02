import 'package:dio/dio.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final token = response.data['token'];
        final user = User.fromJson(userData);
        return {'user': user, 'token': token};
      } else {
        throw Exception('Login failed');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Identifiants invalides');
      }
      throw Exception('Erreur de connexion : ${e.message}');
    } catch (e) {
      throw Exception('Erreur de connexion : $e');
    }
  }

  Future<Map<String, dynamic>> register(String fullName, String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/api/auth/register', data: {
        'full_name': fullName,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201) {
        final userData = response.data['user'];
        final token = response.data['token'];
        final user = User.fromJson(userData);
        return {'user': user, 'token': token};
      } else {
        throw Exception('Registration failed');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Cet email est déjà utilisé');
      }
      throw Exception('Erreur d\'inscription : ${e.message}');
    } catch (e) {
      throw Exception('Erreur d\'inscription : $e');
    }
  }

  Future<User> getMe() async {
    try {
      final response = await _apiClient.dio.get('/api/auth/me');
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Failed to load profile');
      }
    } on DioException catch (e) {
      throw Exception('Erreur de profil : ${e.message}');
    } catch (e) {
      throw Exception('Erreur de profil : $e');
    }
  }
}
