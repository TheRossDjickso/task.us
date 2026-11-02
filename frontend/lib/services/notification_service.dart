import '../models/notification_model.dart';
import 'api_client.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches notifications for the logged-in user.
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiClient.dio.get('/api/notifications');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  /// Marks a specific notification as read.
  Future<void> markAsRead(String id) async {
    try {
      final response = await _apiClient.dio.patch('/api/notifications/$id/read');
      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  /// Marks all notifications for the user as read.
  Future<void> markAllAsRead() async {
    try {
      final response =
          await _apiClient.dio.patch('/api/notifications/read-all');
      if (response.statusCode != 200) {
        throw Exception('Failed to mark all notifications as read');
      }
    } catch (e) {
      throw Exception('Error marking all notifications as read: $e');
    }
  }

  /// Accepts a project invitation invitation.
  Future<void> acceptInvitation(String projectId) async {
    try {
      final response = await _apiClient.dio.post('/api/projects/$projectId/members/accept');
      if (response.statusCode != 200) {
        throw Exception('Failed to accept invitation');
      }
    } catch (e) {
      throw Exception('Error accepting invitation: $e');
    }
  }

  /// Declines a project invitation.
  Future<void> declineInvitation(String projectId) async {
    try {
      final response = await _apiClient.dio.post('/api/projects/$projectId/members/decline');
      if (response.statusCode != 200) {
        throw Exception('Failed to decline invitation');
      }
    } catch (e) {
      throw Exception('Error declining invitation: $e');
    }
  }

  /// Registers an FCM device token.
  Future<void> registerDeviceToken(String token) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/notifications/devices',
        data: {'token': token, 'platform': 'android'},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to register device token');
      }
    } catch (e) {
      throw Exception('Error registering device token: $e');
    }
  }

  /// Unregisters an FCM device token.
  Future<void> unregisterDeviceToken(String token) async {
    try {
      final response = await _apiClient.dio.delete(
        '/api/notifications/devices',
        data: {'token': token},
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to unregister device token');
      }
    } catch (e) {
      throw Exception('Error unregistering device token: $e');
    }
  }
}
