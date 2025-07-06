import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/services/api_service.dart';

class CandidateSettingsScreen extends StatefulWidget {
  const CandidateSettingsScreen({super.key});

  @override
  _CandidateSettingsScreenState createState() =>
      _CandidateSettingsScreenState();
}

class _CandidateSettingsScreenState extends State<CandidateSettingsScreen>
    with TickerProviderStateMixin {
  // ThisAble Colors
  static const Color primaryColor = Color(0xFF257180);
  static const Color secondaryColor = Color(0xFFF2E5BF);
  static const Color accentColor = Color(0xFFFD8B51);
  static const Color sidebarColor = Color(0xFF2F8A99);

  // Current View State
  String _currentView = 'main';
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;

  // Loading States
  bool _isLoadingSettings = true;
  bool _isUpdatingSettings = false;
  bool _isDisposed = false;

  // Settings State Variables from API
  Map<String, dynamic> _notificationSettings = {};
  Map<String, dynamic> _privacySettings = {};
  Map<String, dynamic> _displaySettings = {};
  Map<String, dynamic> _accessibilitySettings = {};
  Map<String, dynamic> _jobAlertSettings = {};
  Map<String, dynamic> _applicationSettings = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAllSettings();
  }

  void _initializeAnimations() {
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    print('🔧 [Settings] Disposing widget...');

    _isDisposed = true;

    // Stop animations safely
    if (_slideAnimationController.isAnimating) {
      _slideAnimationController.stop();
    }

    _slideAnimationController.dispose();

    print('🔧 [Settings] Widget disposed successfully');
    super.dispose();
  }

  Future<void> _loadAllSettings() async {
    try {
      final response = await ApiService.getUserSettings();
      if (response['success'] && mounted) {
        final data = response['data'];
        setState(() {
          _notificationSettings = data['notification_settings'] ?? {};
          _privacySettings = data['privacy_settings'] ?? {};
          _displaySettings = data['display_settings'] ?? {};
          _accessibilitySettings = data['accessibility_settings'] ?? {};
          _jobAlertSettings = data['job_alert_settings'] ?? {};
          _applicationSettings = data['application_settings'] ?? {};
          _isLoadingSettings = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSettings = false);
        _showErrorSnackBar('Failed to load settings');
      }
    }
  }

  Future<void> _updateSettings(
      String category, Map<String, dynamic> settings) async {
    setState(() => _isUpdatingSettings = true);

    try {
      final response = await ApiService.updateSettings({
        'category': category,
        'settings': settings,
      });

      if (response['success']) {
        _showSuccessSnackBar('Settings updated successfully');
        await _loadAllSettings(); // Refresh data
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to update settings');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update settings');
    } finally {
      setState(() => _isUpdatingSettings = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToView(String view) {
    setState(() {
      _currentView = view;
    });
    _slideAnimationController.forward();
  }

  void _goBack() {
    _slideAnimationController.reverse().then((_) {
      setState(() {
        _currentView = 'main';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingSettings) {
      return const Scaffold(
        backgroundColor: Colors.grey,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          _buildMainView(),
          if (_currentView != 'main')
            SlideTransition(
              position: _slideAnimation,
              child: _buildDetailView(),
            ),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildAccountSection(),
                const SizedBox(height: 16),
                _buildPreferencesSection(),
                const SizedBox(height: 16),
                _buildSecuritySection(),
                const SizedBox(height: 16),
                _buildSupportSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, sidebarColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return _buildSettingsCard(
      title: 'Account',
      icon: Icons.account_circle,
      children: [
        _buildSettingsItem(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Manage your notification preferences',
          onTap: () => _navigateToView('notifications'),
        ),
        _buildSettingsItem(
          icon: Icons.privacy_tip,
          title: 'Privacy',
          subtitle: 'Control your privacy settings',
          onTap: () => _navigateToView('privacy'),
        ),
        _buildSettingsItem(
          icon: Icons.display_settings,
          title: 'Display',
          subtitle: 'Theme, font size, and display options',
          onTap: () => _navigateToView('display'),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return _buildSettingsCard(
      title: 'Preferences',
      icon: Icons.tune,
      children: [
        _buildSettingsItem(
          icon: Icons.work_outline,
          title: 'Job Alerts',
          subtitle: 'Customize your job alert preferences',
          onTap: () => _navigateToView('job_alerts'),
        ),
        _buildSettingsItem(
          icon: Icons.assignment,
          title: 'Application Settings',
          subtitle: 'Manage application preferences',
          onTap: () => _navigateToView('application_settings'),
        ),
        _buildSettingsItem(
          icon: Icons.accessible,
          title: 'Accessibility',
          subtitle: 'Accessibility and ease of use options',
          onTap: () => _navigateToView('accessibility'),
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _buildSettingsCard(
      title: 'Security',
      icon: Icons.security,
      children: [
        _buildSettingsItem(
          icon: Icons.lock,
          title: 'Change Password',
          subtitle: 'Update your account password',
          onTap: _changePassword,
        ),
        _buildSettingsItem(
          icon: Icons.delete_forever,
          title: 'Delete Account',
          subtitle: 'Permanently delete your account',
          onTap: _deleteAccount,
          textColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSettingsCard(
      title: 'Support',
      icon: Icons.help,
      children: [
        _buildSettingsItem(
          icon: Icons.help_outline,
          title: 'Help Center',
          subtitle: 'Get help and support',
          onTap: _openHelpCenter,
        ),
        _buildSettingsItem(
          icon: Icons.feedback,
          title: 'Send Feedback',
          subtitle: 'Help us improve the app',
          onTap: _sendFeedback,
        ),
        _buildSettingsItem(
          icon: Icons.info_outline,
          title: 'About',
          subtitle: 'App version and information',
          onTap: _showAbout,
        ),
        _buildSettingsItem(
          icon: Icons.logout,
          title: 'Sign Out',
          subtitle: 'Sign out of your account',
          onTap: _signOut,
          textColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
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

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor ?? Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDetailView() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        title: Text(_getViewTitle()),
        actions: [
          if (_isUpdatingSettings)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _getDetailViewContent(),
    );
  }

  String _getViewTitle() {
    switch (_currentView) {
      case 'notifications':
        return 'Notifications';
      case 'privacy':
        return 'Privacy';
      case 'display':
        return 'Display';
      case 'job_alerts':
        return 'Job Alerts';
      case 'application_settings':
        return 'Application Settings';
      case 'accessibility':
        return 'Accessibility';
      default:
        return 'Settings';
    }
  }

  Widget _getDetailViewContent() {
    switch (_currentView) {
      case 'notifications':
        return _buildNotificationsView();
      case 'privacy':
        return _buildPrivacyView();
      case 'display':
        return _buildDisplayView();
      case 'job_alerts':
        return _buildJobAlertsView();
      case 'application_settings':
        return _buildApplicationSettingsView();
      case 'accessibility':
        return _buildAccessibilityView();
      default:
        return Container();
    }
  }

  Widget _buildNotificationsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFormCard(
            title: 'Notification Methods',
            children: [
              _buildSwitchRow(
                title: 'Email Notifications',
                subtitle: 'Receive notifications via email',
                value: _notificationSettings['email_notifications'] ?? true,
                onChanged: (value) =>
                    _updateNotificationSetting('email_notifications', value),
              ),
              _buildSwitchRow(
                title: 'SMS Notifications',
                subtitle: 'Receive notifications via SMS',
                value: _notificationSettings['sms_notifications'] ?? false,
                onChanged: (value) =>
                    _updateNotificationSetting('sms_notifications', value),
              ),
              _buildSwitchRow(
                title: 'Push Notifications',
                subtitle: 'Receive push notifications on device',
                value: _notificationSettings['push_notifications'] ?? true,
                onChanged: (value) =>
                    _updateNotificationSetting('push_notifications', value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormCard(
            title: 'Notification Categories',
            children: [
              _buildSwitchRow(
                title: 'Job Alerts',
                subtitle: 'New job opportunities matching your criteria',
                value: _notificationSettings['job_alerts'] ?? true,
                onChanged: (value) =>
                    _updateNotificationSetting('job_alerts', value),
              ),
              _buildSwitchRow(
                title: 'Application Updates',
                subtitle: 'Updates on your job applications',
                value: _notificationSettings['application_updates'] ?? true,
                onChanged: (value) =>
                    _updateNotificationSetting('application_updates', value),
              ),
              _buildSwitchRow(
                title: 'Interview Reminders',
                subtitle: 'Reminders for upcoming interviews',
                value: _notificationSettings['interview_reminders'] ?? true,
                onChanged: (value) =>
                    _updateNotificationSetting('interview_reminders', value),
              ),
              _buildSwitchRow(
                title: 'Marketing Notifications',
                subtitle: 'Tips, news, and promotional content',
                value:
                    _notificationSettings['marketing_notifications'] ?? false,
                onChanged: (value) => _updateNotificationSetting(
                    'marketing_notifications', value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFormCard(
            title: 'Profile Visibility',
            children: [
              _buildDropdownRow(
                title: 'Profile Visibility',
                value: _privacySettings['profile_visibility'] ?? 'all',
                items: ['all', 'verified', 'none'],
                itemLabels: [
                  'Visible to all employers',
                  'Visible only to verified employers',
                  'Not visible in search (private profile)',
                ],
                onChanged: (value) =>
                    _updatePrivacySetting('profile_visibility', value),
              ),
              _buildSwitchRow(
                title: 'Show in Search Results',
                subtitle: 'Allow employers to find your profile',
                value: _privacySettings['search_listing'] ?? true,
                onChanged: (value) =>
                    _updatePrivacySetting('search_listing', value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormCard(
            title: 'Data Preferences',
            children: [
              _buildSwitchRow(
                title: 'Allow Data Collection for Personalization',
                subtitle: 'Help us improve your job recommendations',
                value: _privacySettings['data_collection'] ?? true,
                onChanged: (value) =>
                    _updatePrivacySetting('data_collection', value),
              ),
              _buildSwitchRow(
                title: 'Share Data with Third-party Partners',
                subtitle: 'Allow sharing with trusted partners',
                value: _privacySettings['third_party_sharing'] ?? false,
                onChanged: (value) =>
                    _updatePrivacySetting('third_party_sharing', value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFormCard(
            title: 'Theme Preferences',
            children: [
              _buildRadioSection(
                title: 'Theme',
                value: _displaySettings['theme'] ?? 'system',
                options: ['light', 'dark', 'system'],
                labels: ['Light', 'Dark', 'System Default'],
                onChanged: (value) => _updateDisplaySetting('theme', value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormCard(
            title: 'Text Preferences',
            children: [
              _buildRadioSection(
                title: 'Font Size',
                value: _displaySettings['font_size'] ?? 'medium',
                options: ['small', 'medium', 'large', 'extra_large'],
                labels: ['Small', 'Medium', 'Large', 'Extra Large'],
                onChanged: (value) => _updateDisplaySetting('font_size', value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobAlertsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFormCard(
            title: 'Alert Frequency',
            children: [
              _buildRadioSection(
                title: 'Frequency',
                value: _jobAlertSettings['alert_frequency'] ?? 'daily',
                options: ['immediate', 'daily', 'weekly', 'never'],
                labels: ['Immediate', 'Daily', 'Weekly', 'Never'],
                onChanged: (value) =>
                    _updateJobAlertSetting('alert_frequency', value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormCard(
            title: 'Alert Methods',
            children: [
              _buildSwitchRow(
                title: 'Email Alerts',
                subtitle: 'Receive job alerts via email',
                value: _jobAlertSettings['email_alerts'] ?? true,
                onChanged: (value) =>
                    _updateJobAlertSetting('email_alerts', value),
              ),
              _buildSwitchRow(
                title: 'SMS Alerts',
                subtitle: 'Receive job alerts via SMS',
                value: _jobAlertSettings['sms_alerts'] ?? false,
                onChanged: (value) =>
                    _updateJobAlertSetting('sms_alerts', value),
              ),
              _buildSwitchRow(
                title: 'App Alerts',
                subtitle: 'Receive job alerts in the app',
                value: _jobAlertSettings['app_alerts'] ?? true,
                onChanged: (value) =>
                    _updateJobAlertSetting('app_alerts', value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationSettingsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFormCard(
            title: 'Application Preferences',
            children: [
              _buildSwitchRow(
                title: 'Auto-fill Application Forms',
                subtitle: 'Automatically fill forms with your profile data',
                value: _applicationSettings['auto_fill'] ?? true,
                onChanged: (value) =>
                    _updateApplicationSetting('auto_fill', value),
              ),
              _buildSwitchRow(
                title: 'Include Cover Letter by Default',
                subtitle: 'Automatically include cover letter when applying',
                value: _applicationSettings['include_cover_letter'] ?? false,
                onChanged: (value) =>
                    _updateApplicationSetting('include_cover_letter', value),
              ),
              _buildSwitchRow(
                title: 'Save Application History',
                subtitle: 'Keep a record of all your applications',
                value: _applicationSettings['save_history'] ?? true,
                onChanged: (value) =>
                    _updateApplicationSetting('save_history', value),
              ),
              _buildSwitchRow(
                title: 'Receive Application Feedback',
                subtitle: 'Allow employers to provide feedback on applications',
                value: _applicationSettings['receive_feedback'] ?? true,
                onChanged: (value) =>
                    _updateApplicationSetting('receive_feedback', value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilityView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFormCard(
            title: 'Visual Accessibility',
            children: [
              _buildSwitchRow(
                title: 'High Contrast Mode',
                subtitle: 'Increase contrast for better visibility',
                value: _accessibilitySettings['high_contrast'] ?? false,
                onChanged: (value) =>
                    _updateAccessibilitySetting('high_contrast', value),
              ),
              _buildSwitchRow(
                title: 'Reduce Motion',
                subtitle: 'Minimize animations and transitions',
                value: _accessibilitySettings['reduce_motion'] ?? false,
                onChanged: (value) =>
                    _updateAccessibilitySetting('reduce_motion', value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormCard(
            title: 'Interaction Accessibility',
            children: [
              _buildSwitchRow(
                title: 'Screen Reader Support',
                subtitle: 'Optimize for screen readers',
                value: _accessibilitySettings['screen_reader'] ?? false,
                onChanged: (value) =>
                    _updateAccessibilitySetting('screen_reader', value),
              ),
              _buildSwitchRow(
                title: 'Keyboard Navigation',
                subtitle: 'Enhanced keyboard navigation support',
                value: _accessibilitySettings['keyboard_navigation'] ?? false,
                onChanged: (value) =>
                    _updateAccessibilitySetting('keyboard_navigation', value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(
      {required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow({
    required String title,
    required String value,
    required List<String> items,
    required List<String> itemLabels,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: items.asMap().entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.value,
                child: Text(itemLabels[entry.key]),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioSection({
    required String title,
    required String value,
    required List<String> options,
    required List<String> labels,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...options.asMap().entries.map((entry) {
          return RadioListTile<String>(
            title: Text(labels[entry.key]),
            value: entry.value,
            groupValue: value,
            onChanged: onChanged,
            activeColor: primaryColor,
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }

  // Update methods for different setting categories
  void _updateNotificationSetting(String key, bool value) {
    setState(() {
      _notificationSettings[key] = value;
    });
    _updateSettings('notifications', {key: value});
  }

  void _updatePrivacySetting(String key, dynamic value) {
    setState(() {
      _privacySettings[key] = value;
    });
    _updateSettings('privacy', {key: value});
  }

  void _updateDisplaySetting(String key, String? value) {
    if (value != null) {
      setState(() {
        _displaySettings[key] = value;
      });
      _updateSettings('display', {key: value});
    }
  }

  void _updateJobAlertSetting(String key, dynamic value) {
    setState(() {
      _jobAlertSettings[key] = value;
    });
    _updateSettings('job_alerts', {key: value});
  }

  void _updateApplicationSetting(String key, bool value) {
    setState(() {
      _applicationSettings[key] = value;
    });
    _updateSettings('application_settings', {key: value});
  }

  void _updateAccessibilitySetting(String key, bool value) {
    setState(() {
      _accessibilitySettings[key] = value;
    });
    _updateSettings('accessibility', {key: value});
  }

  // Action methods
  void _changePassword() {
    // TODO: Implement password change
    _showSuccessSnackBar('Password change will be implemented');
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessSnackBar('Account deletion will be implemented');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openHelpCenter() {
    _showSuccessSnackBar('Help center will be implemented');
  }

  void _sendFeedback() {
    _showSuccessSnackBar('Feedback form will be implemented');
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About ThisAble'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('ThisAble - A Job Portal for PWDs and Inclusive Employers'),
            SizedBox(height: 8),
            Text('© 2025 ThisAble. All rights reserved.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Close dialog first
              Navigator.pop(dialogContext);

              try {
                print('🔧 [Settings] Starting sign out process...');

                // Clear token and user data
                await ApiService.logout();

                print('🔧 [Settings] API logout successful');

                // FIXED: Safe navigation with proper context checking
                if (mounted && context.mounted) {
                  print('🔧 [Settings] Navigating to login screen...');

                  // Use pushNamedAndRemoveUntil to clear navigation stack
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/candidate/login',
                    (route) => false,
                  );

                  print('🔧 [Settings] Navigation completed');
                }
              } catch (e) {
                print('🔧 [Settings] Error during sign out: $e');

                // Show error only if widget is still mounted
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sign out failed: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
