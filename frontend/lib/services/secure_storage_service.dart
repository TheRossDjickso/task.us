import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service responsible for securely storing sensitive user credentials and tokens
/// (such as OAuth / JWT auth tokens) using platform-specific hardware-backed storage.
///
/// Under the hood, this uses Android Keystore / EncryptedSharedPreferences on Android
/// and Keychain Services on iOS.
class SecureStorageService {
  // Singleton pattern implementation
  static final SecureStorageService _instance = SecureStorageService._internal();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  factory SecureStorageService() {
    return _instance;
  }

  SecureStorageService._internal();

  // Keys used for persistence
  static const String _authTokenKey = 'auth_token';

  /// Standard Android options configuring EncryptedSharedPreferences.
  /// Requires minSdkVersion 23+.
  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  /// Standard iOS options configuring Keychain accessibility.
  /// KeychainAccessibility.first_unlock ensures data is accessible after the first
  /// device unlock, which is optimal for background tasks/fetch operations.
  IOSOptions _getIOSOptions() => const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      );

  /// Saves the authentication token securely.
  Future<void> saveAuthToken(String token) async {
    try {
      await _secureStorage.write(
        key: _authTokenKey,
        value: token,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde sécurisée du token : $e');
    }
  }

  /// Retrieves the securely stored authentication token.
  /// Returns `null` if no token is stored or on error.
  Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(
        key: _authTokenKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
    } catch (e) {
      // Return null and log gracefully if there's any keystore/keychain corruption
      return null;
    }
  }

  /// Deletes the securely stored authentication token.
  Future<void> deleteAuthToken() async {
    try {
      await _secureStorage.delete(
        key: _authTokenKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
    } catch (e) {
      throw Exception('Erreur lors de la suppression sécurisée du token : $e');
    }
  }
}
