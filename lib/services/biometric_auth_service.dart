import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

enum BiometricStatus {
  unknown,
  available,
  notAvailable,
  notEnrolled,
  disabled,
}

enum BiometricType {
  fingerprint,
  face,
  iris,
  weak,
  strong,
}

class BiometricAuthService {
  static final BiometricAuthService _instance = BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;
  BiometricAuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  BiometricStatus _status = BiometricStatus.unknown;
  List<BiometricType> _availableTypes = [];
  String? _lastError;

  BiometricStatus get status => _status;
  List<BiometricType> get availableTypes => _availableTypes;
  String? get lastError => _lastError;

  /// Initialize biometric authentication service
  Future<void> initialize() async {
    try {
      await _checkBiometricStatus();
      await _getAvailableBiometrics();
    } catch (e) {
      _lastError = e.toString();
      if (kDebugMode) {
        print('BiometricAuthService initialization failed: $e');
      }
    }
  }

  /// Check if biometric authentication is available on the device
  Future<bool> isAvailable() async {
    try {
      final bool isAvailable = await _localAuth.isDeviceSupported();
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      
      if (!isAvailable || !canCheckBiometrics) {
        _status = BiometricStatus.notAvailable;
        return false;
      }

      final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        _status = BiometricStatus.notEnrolled;
        return false;
      }

      _status = BiometricStatus.available;
      return true;
    } catch (e) {
      _lastError = e.toString();
      _status = BiometricStatus.notAvailable;
      if (kDebugMode) {
        print('Biometric availability check failed: $e');
      }
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final List<BiometricType> biometricTypes = <BiometricType>[];
      final List<BiometricType> availableBiometrics = 
          (await _localAuth.getAvailableBiometrics()).cast<BiometricType>();
      
      biometricTypes.addAll(availableBiometrics);
      _availableTypes = biometricTypes;
      return biometricTypes;
    } catch (e) {
      _lastError = e.toString();
      if (kDebugMode) {
        print('Failed to get available biometrics: $e');
      }
      return [];
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticate({
    required String reason,
    bool biometricOnly = false,
    bool stickyAuth = false,
    bool sensitiveTransaction = true,
  }) async {
    try {
      // Check if biometric is available first
      if (!await isAvailable()) {
        _lastError = 'Biometric authentication is not available';
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        authMessages: [
          const AndroidAuthMessages(
            signInTitle: 'Biometric Authentication Required',
            cancelButton: 'No thanks',
            deviceCredentialsRequiredTitle: 'Device credential required',
            deviceCredentialsSetupDescription: 'Device credential required',
            goToSettingsButton: 'Go to settings',
            goToSettingsDescription: 'Please set up your biometric authentication',
            biometricHint: 'Touch sensor',
            biometricNotRecognized: 'Biometric not recognized, try again',
            biometricRequiredTitle: 'Biometric required',
            biometricSuccess: 'Biometric authentication successful',
          ),
          const IOSAuthMessages(
            cancelButton: 'No thanks',
            goToSettingsButton: 'Go to settings',
            goToSettingsDescription: 'Please set up your biometric authentication',
            lockOut: 'Please reenable your biometric authentication',
          ),
        ],
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: stickyAuth,
          sensitiveTransaction: sensitiveTransaction,
        ),
      );

      if (!didAuthenticate) {
        _lastError = 'Authentication was cancelled or failed';
      }

      return didAuthenticate;
    } catch (e) {
      _lastError = e.toString();
      if (kDebugMode) {
        print('Biometric authentication failed: $e');
      }
      return false;
    }
  }

  /// Check biometric status without authentication
  Future<void> _checkBiometricStatus() async {
    try {
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;

      if (!isDeviceSupported) {
        _status = BiometricStatus.notAvailable;
        return;
      }

      if (!canCheckBiometrics) {
        _status = BiometricStatus.disabled;
        return;
      }

      final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        _status = BiometricStatus.notEnrolled;
        return;
      }

      _status = BiometricStatus.available;
    } catch (e) {
      _lastError = e.toString();
      _status = BiometricStatus.unknown;
      if (kDebugMode) {
        print('Failed to check biometric status: $e');
      }
    }
  }

  /// Get available biometrics and cache them
  Future<void> _getAvailableBiometrics() async {
    try {
      _availableTypes = await getAvailableBiometrics();
    } catch (e) {
      _lastError = e.toString();
      _availableTypes = [];
      if (kDebugMode) {
        print('Failed to get available biometrics: $e');
      }
    }
  }

  /// Map platform specific biometric types to our enum
  BiometricType _mapBiometricType(BiometricType biometric) {
    return biometric; // Direct mapping since enums are the same
  }

  /// Get biometric status message for UI
  String getStatusMessage() {
    switch (_status) {
      case BiometricStatus.available:
        return 'Biometric authentication is available';
      case BiometricStatus.notAvailable:
        return 'Biometric authentication is not supported on this device';
      case BiometricStatus.notEnrolled:
        return 'No biometric credentials are enrolled';
      case BiometricStatus.disabled:
        return 'Biometric authentication is disabled';
      case BiometricStatus.unknown:
        return 'Biometric status is unknown';
    }
  }

  /// Get available biometric types as string for UI
  String getAvailableTypesString() {
    if (_availableTypes.isEmpty) {
      return 'None';
    }
    
    return _availableTypes.map((type) {
      switch (type) {
        case BiometricType.fingerprint:
          return 'Fingerprint';
        case BiometricType.face:
          return 'Face ID';
        case BiometricType.iris:
          return 'Iris';
        case BiometricType.weak:
          return 'Weak Biometric';
        case BiometricType.strong:
          return 'Strong Biometric';
      }
    }).join(', ');
  }

  /// Stop authentication (if possible)
  Future<bool> stopAuthentication() async {
    try {
      return await _localAuth.stopAuthentication();
    } catch (e) {
      _lastError = e.toString();
      if (kDebugMode) {
        print('Failed to stop authentication: $e');
      }
      return false;
    }
  }

  /// Clear any cached error messages
  void clearError() {
    _lastError = null;
  }

  /// Quick check if biometric auth can be used right now
  Future<bool> canUseNow() async {
    try {
      final bool deviceSupported = await _localAuth.isDeviceSupported();
      final bool canCheck = await _localAuth.canCheckBiometrics;
      final List<BiometricType> available = await getAvailableBiometrics();
      
      return deviceSupported && canCheck && available.isNotEmpty;
    } catch (e) {
      _lastError = e.toString();
      return false;
    }
  }
}
