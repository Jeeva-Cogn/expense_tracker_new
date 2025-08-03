import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/biometric_auth_service.dart';
import '../services/settings_service.dart';
import 'modern_cred_dashboard.dart';

class BiometricLockScreen extends StatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  
  final BiometricAuthService _biometricService = BiometricAuthService();
  bool _isAuthenticating = false;
  String _statusMessage = 'Touch the fingerprint sensor';
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _pulseController.repeat(reverse: true);
    _fadeController.forward();
    
    // Initialize biometric service and try authentication
    _initializeAndAuthenticate();
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeAndAuthenticate() async {
    await _biometricService.initialize();
    _authenticate();
  }
  
  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    
    setState(() {
      _isAuthenticating = true;
      _statusMessage = 'Authenticating...';
    });
    
    try {
      final bool isAvailable = await _biometricService.isAvailable();
      
      if (!isAvailable) {
        setState(() {
          _statusMessage = _biometricService.getStatusMessage();
          _isAuthenticating = false;
        });
        
        // If biometric is not available, go to main screen after delay
        await Future.delayed(const Duration(seconds: 2));
        _navigateToMainScreen();
        return;
      }
      
      final bool authenticated = await _biometricService.authenticate(
        reason: 'Please authenticate to access your expense tracker',
        biometricOnly: false,
        stickyAuth: false,
      );
      
      if (authenticated) {
        setState(() {
          _statusMessage = 'Authentication successful!';
        });
        
        // Add success haptic feedback
        HapticFeedback.mediumImpact();
        
        // Delay for success message then navigate
        await Future.delayed(const Duration(milliseconds: 800));
        _navigateToMainScreen();
      } else {
        setState(() {
          _statusMessage = 'Authentication failed. Tap to retry.';
          _isAuthenticating = false;
        });
        
        // Add error haptic feedback
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Authentication error. Tap to retry.';
        _isAuthenticating = false;
      });
      
      HapticFeedback.heavyImpact();
    }
  }
  
  void _navigateToMainScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const ModernCREDDashboard(),
      ),
    );
  }
  
  void _onRetry() {
    if (!_isAuthenticating) {
      _authenticate();
    }
  }
  
  void _onSkip() {
    _navigateToMainScreen();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // App logo/title
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Expense Tracker',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Secure Access Required',
                      style: TextStyle(
                        color: Color(0xFF8B8B8B),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(flex: 1),
              
              // Biometric icon
              GestureDetector(
                onTap: _onRetry,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isAuthenticating ? _pulseAnimation.value : 1.0,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1A1A1A),
                          border: Border.all(
                            color: _isAuthenticating 
                                ? const Color(0xFF6366F1)
                                : const Color(0xFF2A2A2A),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.fingerprint,
                          size: 60,
                          color: _isAuthenticating 
                              ? const Color(0xFF6366F1)
                              : const Color(0xFF8B8B8B),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Status message
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Available biometric types
              if (_biometricService.availableTypes.isNotEmpty)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Available: ${_biometricService.getAvailableTypesString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF8B8B8B),
                      fontSize: 14,
                    ),
                  ),
                ),
              
              const Spacer(flex: 2),
              
              // Action buttons
              if (!_isAuthenticating) ...[
                // Retry button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Skip button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _onSkip,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF8B8B8B),
                      side: const BorderSide(
                        color: Color(0xFF2A2A2A),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Skip for Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
              
              // Loading indicator
              if (_isAuthenticating)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widget to decide which screen to show
class AuthenticationGate extends StatelessWidget {
  const AuthenticationGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settingsService, child) {
        // Check if biometric is enabled in settings
        if (settingsService.settings.biometricEnabled) {
          return const BiometricLockScreen();
        } else {
          return const ModernCREDDashboard();
        }
      },
    );
  }
}
