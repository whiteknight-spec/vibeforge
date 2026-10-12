import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_card.dart';
import '../bloc/settings_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(state.isTamil ? 'அமைப்புகள்' : 'Settings')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Profile ──────────────────────────────────
              NeonCard(
                showGlow: true,
                glowColor: AppColors.primary,
                glowIntensity: 0.2,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _pickProfilePicture(context, state),
                      child: Stack(
                        children: [
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: state.profilePicturePath == null ? AppColors.primaryGradient : null,
                              image: state.profilePicturePath != null && File(state.profilePicturePath!).existsSync()
                                  ? DecorationImage(
                                      image: FileImage(File(state.profilePicturePath!)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: state.profilePicturePath == null || !File(state.profilePicturePath!).existsSync()
                                ? Center(
                                    child: Text(state.userName[0].toUpperCase(),
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.backgroundDark)),
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0, bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.surfaceDark, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, size: 10, color: AppColors.backgroundDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(state.userName, style: Theme.of(context).textTheme.titleLarge),
                          Text('VibeForge v1.0.0', style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => _editName(context, state),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 16),
              _SectionHeader(title: state.isTamil ? 'தோற்றம்' : 'Appearance'),

              // Theme toggle
              _SettingsTile(
                icon: state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                iconColor: AppColors.secondary,
                title: state.isTamil ? 'தீம்' : 'Theme',
                subtitle: state.isDarkMode
                    ? (state.isTamil ? 'இருள் பயன்முறை' : 'Dark Mode')
                    : (state.isTamil ? 'ஒளி பயன்முறை' : 'Light Mode'),
                trailing: Switch(
                  value: state.isDarkMode,
                  onChanged: (_) => context.read<SettingsBloc>().add(const ToggleTheme()),
                ),
              ),

              // Language toggle
              _SettingsTile(
                icon: Icons.language,
                iconColor: AppColors.primary,
                title: state.isTamil ? 'மொழி' : 'Language',
                subtitle: state.isTamil ? 'தமிழ்' : 'English',
                trailing: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'en', label: Text('EN', style: TextStyle(fontSize: 12))),
                    ButtonSegment(value: 'ta', label: Text('தமிழ்', style: TextStyle(fontSize: 12))),
                  ],
                  selected: {state.languageCode},
                  onSelectionChanged: (v) => context.read<SettingsBloc>().add(ChangeLanguage(v.first)),
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              _SectionHeader(title: state.isTamil ? 'அம்சங்கள்' : 'Features'),

              // AI toggle
              _SettingsTile(
                icon: Icons.auto_awesome,
                iconColor: AppColors.accent,
                title: state.isTamil ? 'AI அம்சங்கள்' : 'AI Features',
                subtitle: state.isTamil
                    ? 'AI இயக்கப்படும் பரிந்துரைகள்'
                    : 'AI-powered suggestions & analysis',
                trailing: Switch(
                  value: state.isAiEnabled,
                  onChanged: (_) => context.read<SettingsBloc>().add(const ToggleAI()),
                ),
              ),

              // Cloud backup toggle
              _SettingsTile(
                icon: Icons.cloud_outlined,
                iconColor: AppColors.primary,
                title: state.isTamil ? 'கிளவுட் காப்புப்பிரதி' : 'Cloud Backup',
                subtitle: state.isTamil
                    ? 'Firebase-க்கு ஒத்திசை (மறைகுறியாக்கப்பட்டது)'
                    : 'Sync to Firebase (encrypted)',
                trailing: Switch(
                  value: state.isCloudBackupEnabled,
                  onChanged: (_) => context.read<SettingsBloc>().add(const ToggleCloudBackup()),
                ),
              ),

              // Transformation Photos tile
              _SettingsTile(
                icon: Icons.photo_library_outlined,
                iconColor: AppColors.secondary,
                title: state.isTamil ? 'மாற்ற காலவரிசை' : 'Transformation Photos',
                subtitle: state.isTamil ? 'தினசரி முன்னேற்ற கேலரி' : 'Daily selfie progress gallery',
                trailing: IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20, color: AppColors.textTertiaryDark),
                  onPressed: () => context.push('/transformation'),
                ),
              ),

              // App Walkthrough tile
              _SettingsTile(
                icon: Icons.explore_outlined,
                iconColor: AppColors.primary,
                title: state.isTamil ? 'அறிமுக சுற்றுலா' : 'App Walkthrough',
                subtitle: state.isTamil ? 'அம்சங்களை மீண்டும் காண்க' : 'Revisit onboarding tour',
                trailing: IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20, color: AppColors.textTertiaryDark),
                  onPressed: () => context.push('/onboarding'),
                ),
              ),

              const SizedBox(height: 16),
              _SectionHeader(title: state.isTamil ? 'தனியுரிமை' : 'Privacy'),

              // Privacy info
              NeonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppColors.success, size: 20),
                        const SizedBox(width: 8),
                        Text(state.isTamil ? 'தனியுரிமை & பாதுகாப்பு' : 'Privacy & Security',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.success)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _PrivacyItem(
                      icon: Icons.lock_outline,
                      text: state.isTamil
                          ? 'அனைத்து மீடியாவும் AES-256 மூலம் மறைகுறியாக்கப்படுகிறது'
                          : 'All media encrypted with AES-256 on device',
                    ),
                    _PrivacyItem(
                      icon: Icons.photo_camera_outlined,
                      text: state.isTamil
                          ? 'கிளவுட் காப்புப்பிரதி இயக்காத வரை புகைப்படங்கள் சாதனத்தை விட்டு வெளியேறாது'
                          : 'Photos never leave device unless cloud backup enabled',
                    ),
                    _PrivacyItem(
                      icon: Icons.visibility_off_outlined,
                      text: state.isTamil
                          ? 'மூன்றாம் தரப்பு பகுப்பாய்வு இல்லை'
                          : 'No third-party analytics tracking photos',
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

              const SizedBox(height: 80),
            ].animate(interval: 60.ms).fadeIn(duration: 300.ms).slideX(begin: 0.05),
          ),
        );
      },
    );
  }

  void _editName(BuildContext context, SettingsState state) {
    final controller = TextEditingController(text: state.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(state.isTamil ? 'பெயர் மாற்று' : 'Change Name'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.isTamil ? 'ரத்துசெய்' : 'Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<SettingsBloc>().add(UpdateUserName(controller.text));
                Navigator.pop(ctx);
              }
            },
            child: Text(state.isTamil ? 'சேமி' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _pickProfilePicture(BuildContext context, SettingsState state) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: Text(state.isTamil ? 'கேலரி' : 'Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.accent),
              title: Text(state.isTamil ? 'கேமரா' : 'Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            if (state.profilePicturePath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: Text(state.isTamil ? 'நீக்கு' : 'Remove Photo',
                  style: const TextStyle(color: AppColors.error)),
                onTap: () {
                  context.read<SettingsBloc>().add(const UpdateProfilePicture(null));
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );

    if (source == null || !context.mounted) return;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked == null || !context.mounted) return;

      // Copy to app documents directory for persistence
      final appDir = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${appDir.path}/profile');
      if (!profileDir.existsSync()) profileDir.createSync(recursive: true);

      final ext = picked.path.split('.').last;
      final destPath = '${profileDir.path}/profile_picture.$ext';
      final destFile = await File(picked.path).copy(destPath);

      if (context.mounted) {
        context.read<SettingsBloc>().add(UpdateProfilePicture(destFile.path));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(state.isTamil ? 'படம் தேர்வு தோல்வி' : 'Failed to pick image'),
        ));
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textTertiaryDark)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final Widget trailing;
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: NeonCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _PrivacyItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PrivacyItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.success.withAlpha(179)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}
