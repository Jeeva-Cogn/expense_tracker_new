import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

class EnhancedSettingsTab extends StatefulWidget {
  const EnhancedSettingsTab({super.key});

  @override
  State<EnhancedSettingsTab> createState() => _EnhancedSettingsTabState();
}

class _EnhancedSettingsTabState extends State<EnhancedSettingsTab>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _fadeController.forward();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settingsService, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              _buildUserProfileSection(),
              const SizedBox(height: 20),
              _buildSecuritySection(settingsService),
              const SizedBox(height: 20),
              _buildPreferencesSection(settingsService),
              const SizedBox(height: 20),
              _buildAboutSection(),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserProfileSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jeeva Kumar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'jeeva@example.com',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showEditProfileDialog(),
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          // Profile Status
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        color: Color(0xFF10B981),
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showSignOutDialog(),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection(SettingsService settingsService) {
    return _buildSection(
      'Security & Privacy',
      Icons.security_rounded,
      [
        SwitchListTile(
          secondary: const Icon(Icons.fingerprint, color: Colors.purple),
          title: const Text('Biometric Lock', style: TextStyle(color: Colors.white)),
          subtitle: const Text('Use fingerprint to unlock app', style: TextStyle(color: Color(0xFF8B8B8B))),
          value: settingsService.settings.biometricEnabled,
          onChanged: (value) => settingsService.toggleBiometric(value),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.privacy_tip, color: Colors.red),
          title: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
          subtitle: const Text('View our privacy policy', style: TextStyle(color: Color(0xFF8B8B8B))),
          trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF8B8B8B), size: 16),
          onTap: () => _showInfoDialog('Privacy Policy', 'Your privacy is important to us...'),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(SettingsService settingsService) {
    return _buildSection(
      'Preferences',
      Icons.tune_rounded,
      [
        SwitchListTile(
          secondary: const Icon(Icons.notifications, color: Colors.orange),
          title: const Text('Push Notifications', style: TextStyle(color: Colors.white)),
          subtitle: const Text('Get notified about spending', style: TextStyle(color: Color(0xFF8B8B8B))),
          value: settingsService.settings.notificationsEnabled,
          onChanged: (value) => settingsService.toggleNotifications(value),
        ),
        const Divider(height: 1),
        SwitchListTile(
          secondary: const Icon(Icons.sync, color: Colors.blue),
          title: const Text('Cloud Sync', style: TextStyle(color: Colors.white)),
          subtitle: const Text('Sync data with cloud', style: TextStyle(color: Color(0xFF8B8B8B))),
          value: settingsService.settings.cloudSyncEnabled,
          onChanged: (value) => settingsService.toggleCloudSync(value),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.palette, color: Colors.pink),
          title: const Text('Theme', style: TextStyle(color: Colors.white)),
          subtitle: const Text('Dark Mode', style: TextStyle(color: Color(0xFF8B8B8B))),
          trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF8B8B8B), size: 16),
          onTap: () => _showInfoDialog('Theme', 'Currently using Dark Mode theme'),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      'About',
      Icons.info_outline_rounded,
      [
        ListTile(
          leading: const Icon(Icons.info, color: Colors.blue),
          title: const Text('App Version', style: TextStyle(color: Colors.white)),
          subtitle: const Text('v1.0.0 (Build 1)', style: TextStyle(color: Color(0xFF8B8B8B))),
          trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF8B8B8B), size: 16),
          onTap: () => _showInfoDialog('Version Info', 'Version: 1.0.0\nBuild: 1\nRelease Date: January 2024'),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.feedback, color: Colors.green),
          title: const Text('Send Feedback', style: TextStyle(color: Colors.white)),
          subtitle: const Text('Help us improve the app', style: TextStyle(color: Color(0xFF8B8B8B))),
          trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF8B8B8B), size: 16),
          onTap: () => _showFeedbackDialog(),
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF6366F1), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        content: const Text('Profile editing coming soon!', style: TextStyle(color: Color(0xFF8B8B8B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: Color(0xFF6366F1))),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(color: Color(0xFF8B8B8B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8B8B8B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSuccessMessage('Signed out successfully!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: const TextStyle(color: Color(0xFF8B8B8B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: Color(0xFF6366F1))),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Send Feedback', style: TextStyle(color: Colors.white)),
        content: const Text('Feedback feature coming soon!', style: TextStyle(color: Color(0xFF8B8B8B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: Color(0xFF6366F1))),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
