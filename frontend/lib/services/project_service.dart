import '../models/project.dart';
import 'api_client.dart';

class ProjectService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Project>> getProjects() async {
    try {
      final response = await _apiClient.dio.get('/api/projects');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final List<dynamic> owned = data['owned'] ?? [];
        final List<dynamic> collaborated = data['collaborated'] ?? [];
        
        final allProjects = [...owned, ...collaborated];
        return allProjects.map((json) => Project.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load projects');
      }
    } catch (e) {
      throw Exception('Error fetching projects: $e');
    }
  }

  Future<Project> createProject(String title, String description) async {
    try {
      final response = await _apiClient.dio.post('/api/projects', data: {
        'title': title,
        'description': description,
      });
      if (response.statusCode == 201) {
        return Project.fromJson(response.data);
      } else {
        throw Exception('Failed to create project');
      }
    } catch (e) {
      throw Exception('Error creating project: $e');
    }
  }

  /// Deletes a project by its ID via the API.
  Future<void> deleteProject(String projectId) async {
    try {
      final response = await _apiClient.dio.delete('/api/projects/$projectId');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete project');
      }
    } catch (e) {
      throw Exception('Error deleting project: $e');
    }
  }

  /// Fetches a single project by its ID.
  Future<Project> getProject(String projectId) async {
    try {
      final response = await _apiClient.dio.get('/api/projects/$projectId');
      if (response.statusCode == 200) {
        return Project.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch project');
      }
    } catch (e) {
      throw Exception('Error fetching project: $e');
    }
  }
}
