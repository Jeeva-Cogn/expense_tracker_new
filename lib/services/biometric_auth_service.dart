import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricAuthService {
  static final BiometricAuthService _instance = BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;
  BiometricAuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  // Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } on PlatformException catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  // Authenticate using biometrics
  Future<bool> authenticate({
    String localizedReason = 'Please authenticate to continue',
    bool biometricOnly = false,
  }) async {
    try {
      final bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );
      return isAuthenticated;
    } on PlatformException catch (e) {
      print('Error during authentication: $e');
      return false;
    }
  }

  // Check if biometric authentication is enabled in settings
  Future<bool> isBiometricEnabled() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get biometric type string for display
  String getBiometricTypeString(List<BiometricType> biometricTypes) {
    if (biometricTypes.isEmpty) return 'None';
    
    final Set<String> types = {};
    
    for (final type in biometricTypes) {
      switch (type) {
        case BiometricType.fingerprint:
          types.add('Fingerprint');
          break;
        case BiometricType.face:
          types.add('Face');
          break;
        case BiometricType.iris:
          types.add('Iris');
          break;
        case BiometricType.weak:
          types.add('Weak');
          break;
        case BiometricType.strong:
          types.add('Strong');
          break;
      }
    }
    
    return types.join(', ');
  }

  // Authenticate for specific actions
  Future<bool> authenticateForExpenseEntry() async {
    return await authenticate(
      localizedReason: 'Authenticate to add expense',
      biometricOnly: false,
    );
  }

  Future<bool> authenticateForSettings() async {
    return await authenticate(
      localizedReason: 'Authenticate to access settings',
      biometricOnly: false,
    );
  }

  Future<bool> authenticateForReports() async {
    return await authenticate(
      localizedReason: 'Authenticate to view financial reports',
      biometricOnly: false,
    );
  }

  Future<bool> authenticateForBudgetManagement() async {
    return await authenticate(
      localizedReason: 'Authenticate to manage budgets',
      biometricOnly: false,
    );
  }

  // Stop authentication if in progress
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } on PlatformException catch (e) {
      print('Error stopping authentication: $e');
    }
  }

  // Get authentication status information
  Future<Map<String, dynamic>> getAuthStatus() async {
    final isAvailable = await isBiometricAvailable();
    final availableBiometrics = await getAvailableBiometrics();
    final isEnabled = await isBiometricEnabled();

    return {
      'isAvailable': isAvailable,
      'availableBiometrics': availableBiometrics,
      'isEnabled': isEnabled,
      'biometricTypesString': getBiometricTypeString(availableBiometrics),
    };
  }
}
