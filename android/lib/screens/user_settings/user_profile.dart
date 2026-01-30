import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import '../../config/app_colors.dart';
import '../../services/settings_manager.dart';
import '../../widgets/nanosolve_logo.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _settingsManager = SettingsManager();

  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;

  bool _darkModeEnabled = true;
  bool _dataCollectionEnabled = false;
  bool _analyticsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _pushNotificationsEnabled = true;

  bool _hasChanges = false;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _displayNameController = TextEditingController(text: _settingsManager.displayName);
    _emailController = TextEditingController(text: _settingsManager.email);
    _bioController = TextEditingController(text: _settingsManager.bio);

    _darkModeEnabled = _settingsManager.darkModeEnabled;
    _dataCollectionEnabled = _settingsManager.dataCollectionEnabled;
    _analyticsEnabled = _settingsManager.analyticsEnabled;
    _emailNotificationsEnabled = _settingsManager.emailNotificationsEnabled;
    _pushNotificationsEnabled = _settingsManager.pushNotificationsEnabled;

    _displayNameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) _saveSettings();
    });
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    if (_hasChanges) {
      _saveSettingsSync();
    }
    _displayNameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveSettingsSync() {
    _settingsManager.setDisplayName(_displayNameController.text);
    _settingsManager.setEmail(_emailController.text);
    _settingsManager.setBio(_bioController.text);
    _settingsManager.setDarkModeEnabled(_darkModeEnabled);
    _settingsManager.setDataCollectionEnabled(_dataCollectionEnabled);
    _settingsManager.setAnalyticsEnabled(_analyticsEnabled);
    _settingsManager.setEmailNotificationsEnabled(_emailNotificationsEnabled);
    _settingsManager.setPushNotificationsEnabled(_pushNotificationsEnabled);
  }

  Future<void> _saveSettings() async {
    if (!_hasChanges) return;

    await _settingsManager.setDisplayName(_displayNameController.text);
    await _settingsManager.setEmail(_emailController.text);
    await _settingsManager.setBio(_bioController.text);
    await _settingsManager.setDarkModeEnabled(_darkModeEnabled);
    await _settingsManager.setDataCollectionEnabled(_dataCollectionEnabled);
    await _settingsManager.setAnalyticsEnabled(_analyticsEnabled);
    await _settingsManager.setEmailNotificationsEnabled(_emailNotificationsEnabled);
    await _settingsManager.setPushNotificationsEnabled(_pushNotificationsEnabled);

    if (mounted) {
      setState(() => _hasChanges = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              AppColors.pastelMint.withValues(alpha: 0.05),
              AppColors.pastelLavender.withValues(alpha: 0.05),
              const Color(0xFF0A0A12),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    'Back',
                    style: TextStyle(
                      color: AppColors.pastelMint,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                  Icon(
                  Icons.person,
                  size: 24,
                  color: AppColors.pastelMint,
                ),
              ],
            ),
            const SizedBox(height: 15),
            const NanosolveLogo(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSection(),
          const SizedBox(height: 30),
          _buildAvatarSection(),
          const SizedBox(height: 30),
          _buildSectionTitle('Personal Information', AppColors.pastelMint),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _displayNameController,
            label: 'Display Name',
            hint: 'Enter your full name or nickname',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _bioController,
            label: 'Bio',
            hint: 'Tell us about yourself',
            icon: Icons.description_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 30),
          _buildSectionTitle('Appearance', AppColors.pastelLavender),
          const SizedBox(height: 15),
          _buildToggleItem(
            title: 'Dark Mode',
            subtitle: 'Use dark theme throughout the app',
            icon: Icons.dark_mode_outlined,
            value: _darkModeEnabled,
            color: AppColors.pastelLavender,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
                _hasChanges = true;
              });
              _scheduleAutoSave();
            },
          ),
          const SizedBox(height: 30),
          _buildSectionTitle('Notifications', AppColors.pastelAqua),
          const SizedBox(height: 15),
          _buildToggleItem(
            title: 'Push Notifications',
            subtitle: 'Receive push notifications on your device',
            icon: Icons.notifications_outlined,
            value: _pushNotificationsEnabled,
            color: AppColors.pastelAqua,
            onChanged: (value) {
              setState(() {
                _pushNotificationsEnabled = value;
                _hasChanges = true;
              });
              _scheduleAutoSave();
            },
          ),
          const SizedBox(height: 15),
          _buildToggleItem(
            title: 'Email Notifications',
            subtitle: 'Receive updates via email',
            icon: Icons.email_outlined,
            value: _emailNotificationsEnabled,
            color: AppColors.pastelAqua,
            onChanged: (value) {
              setState(() {
                _emailNotificationsEnabled = value;
                _hasChanges = true;
              });
              _scheduleAutoSave();
            },
          ),
          const SizedBox(height: 30),
          _buildSectionTitle('Privacy', AppColors.pastelMint),
          const SizedBox(height: 15),
          _buildToggleItem(
            title: 'Analytics',
            subtitle: 'Help us improve by sharing usage data',
            icon: Icons.analytics_outlined,
            value: _analyticsEnabled,
            color: AppColors.pastelMint,
            onChanged: (value) {
              setState(() {
                _analyticsEnabled = value;
                _hasChanges = true;
              });
              _scheduleAutoSave();
            },
          ),
          const SizedBox(height: 15),
          _buildToggleItem(
            title: 'Data Collection',
            subtitle: 'Allow personalized content recommendations',
            icon: Icons.data_usage_outlined,
            value: _dataCollectionEnabled,
            color: AppColors.pastelMint,
            onChanged: (value) {
              setState(() {
                _dataCollectionEnabled = value;
                _hasChanges = true;
              });
              _scheduleAutoSave();
            },
          ),
          const SizedBox(height: 30),
          _buildDangerZone(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.pastelMint, AppColors.pastelAqua],
          ).createShader(bounds),
          child: const Text(
            'Profile Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Customize your profile and preferences',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // Avatar selection logic
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF141928),
                border: Border.all(
                  color: AppColors.pastelMint.withValues(alpha: 0.5),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pastelMint.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.person,
                size: 50,
                color: AppColors.pastelMint.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to change avatar',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.pastelMint.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.pastelMint),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.textDark,
                fontSize: 15,
              ),
              filled: true,
              fillColor: const Color(0xFF0A0A12).withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: color,
            activeTrackColor: color.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textDark,
            inactiveTrackColor: const Color(0xFF0A0A12),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Danger Zone', AppColors.neonCrimson),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF141928).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.neonCrimson.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              _buildDangerButton(
                title: 'Reset Settings',
                subtitle: 'Reset all settings to default values',
                icon: Icons.refresh,
                onTap: _showResetConfirmation,
              ),
              const SizedBox(height: 15),
              _buildDangerButton(
                title: 'Delete Account',
                subtitle: 'Permanently delete your account and data',
                icon: Icons.delete_forever,
                onTap: _showDeleteConfirmation,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDangerButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.neonCrimson.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neonCrimson.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.neonCrimson),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neonCrimson,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.neonCrimson.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141928),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Reset Settings?',
          style: TextStyle(color: AppColors.neonCrimson, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will reset all settings to their default values. This action cannot be undone.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              await _settingsManager.resetToDefaults();
              if (mounted) {
                Navigator.pop(context);
                _loadSettings();
                setState(() {});
              }
            },
            child: Text('Reset', style: TextStyle(color: AppColors.neonCrimson)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141928),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Delete Account?',
          style: TextStyle(color: AppColors.neonCrimson, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will permanently delete your account and all associated data. This action cannot be undone.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete account logic would go here
            },
            child: Text('Delete', style: TextStyle(color: AppColors.neonCrimson)),
          ),
        ],
      ),
    );
  }
}
