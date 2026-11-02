/// Modèle représentant un utilisateur dans l'application.
/// Basé sur la structure de la table 'user' de la base de données.
class UserModel {
  final int? id;
  final String fullName;
  final String email;
  final String password;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.password,
    this.createdAt,
    this.updatedAt,
  });

  /// Convertit une instance de UserModel en Map pour l'insertion en base de données.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'password': password,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Crée une instance de UserModel à partir d'un Map (depuis la base de données).
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      fullName: map['full_name'],
      email: map['email'],
      password: map['password'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
}
