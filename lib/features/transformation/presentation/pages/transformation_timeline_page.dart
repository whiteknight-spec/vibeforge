import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_card.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';

/// Transformation timeline showing daily selfie progress photos.
class TransformationTimelinePage extends StatefulWidget {
  const TransformationTimelinePage({super.key});

  @override
  State<TransformationTimelinePage> createState() => _TransformationTimelinePageState();
}

class _TransformationTimelinePageState extends State<TransformationTimelinePage> {
  List<Map<String, dynamic>> _photos = [];
  bool _isLoading = true;
  bool _isUploading = false;

  Box get _photosBox => Hive.box(AppConstants.hiveProgressPhotosBox);

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  void _loadPhotos() {
    final List<Map<String, dynamic>> photos = [];
    final stored = _photosBox.get('photos', defaultValue: []) as List;
    for (final p in stored) {
      if (p is Map) {
        photos.add(Map<String, dynamic>.from(p));
      }
    }
    // Sort chronologically (newest first for display)
    photos.sort((a, b) => (b['dateKey'] ?? '').compareTo(a['dateKey'] ?? ''));
    setState(() {
      _photos = photos;
      _isLoading = false;
    });
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _uploadPhoto(ImageSource source) async {
    setState(() => _isUploading = true);

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked == null) {
        setState(() => _isUploading = false);
        return;
      }

      // Save to app documents
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${appDir.path}/progress_photos');
      if (!photosDir.existsSync()) photosDir.createSync(recursive: true);

      final dateKey = _todayKey();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = picked.path.split('.').last;
      final fileName = 'progress_${dateKey}_$timestamp.$ext';
      final destPath = '${photosDir.path}/$fileName';
      await File(picked.path).copy(destPath);

      // Update Hive storage
      final stored = _photosBox.get('photos', defaultValue: []) as List;

      // Check if today already has a photo — replace it
      int existingIdx = -1;
      for (int i = 0; i < stored.length; i++) {
        if (stored[i] is Map && stored[i]['dateKey'] == dateKey) {
          existingIdx = i;
          break;
        }
      }

      final photoEntry = {
        'dateKey': dateKey,
        'photoPath': destPath,
        'timestamp': timestamp,
      };

      if (existingIdx >= 0) {
        // Delete old file if it exists safely within sandbox
        final oldPath = stored[existingIdx]['photoPath'] as String?;
        await _safeDeletePhotoFile(oldPath);
        stored[existingIdx] = photoEntry;
      } else {
        stored.add(photoEntry);
      }

      await _photosBox.put('photos', stored);
      _loadPhotos();

      if (mounted) {
        final settings = context.read<SettingsBloc>().state;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(existingIdx >= 0
              ? (settings.isTamil ? 'இன்றைய படம் மாற்றப்பட்டது!' : "Today's photo replaced!")
              : (settings.isTamil ? 'படம் சேர்க்கப்பட்டது!' : 'Photo added!')),
          backgroundColor: AppColors.success.withAlpha(200),
        ));
      }
    } catch (e) {
      if (mounted) {
        final settings = context.read<SettingsBloc>().state;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(settings.isTamil ? 'படம் சேர்ப்பு தோல்வி' : 'Failed to add photo'),
          backgroundColor: AppColors.error.withAlpha(200),
        ));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showSourcePicker() {
    final settings = context.read<SettingsBloc>().state;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: Text(settings.isTamil ? 'கேலரி' : 'Gallery'),
              onTap: () { Navigator.pop(ctx); _uploadPhoto(ImageSource.gallery); },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.accent),
              title: Text(settings.isTamil ? 'கேமரா' : 'Camera'),
              onTap: () { Navigator.pop(ctx); _uploadPhoto(ImageSource.camera); },
            ),
          ],
        ),
      ),
    );
  }

  void _showFullPhoto(Map<String, dynamic> photo) {
    final file = File(photo['photoPath'] ?? '');
    if (!file.existsSync()) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(photo['dateKey'] ?? ''),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () {
                _deletePhoto(photo);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: Center(
          child: InteractiveViewer(
            child: Image.file(file, fit: BoxFit.contain),
          ),
        ),
      ),
    ));
  }

  /// Security: Ensures file deletion cannot escape the transformation_photos sandbox directory
  Future<void> _safeDeletePhotoFile(String? rawPath) async {
    if (rawPath == null || rawPath.isEmpty) return;
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${appDir.path}/transformation_photos');
      if (!photosDir.existsSync()) return;
      final canonicalDir = photosDir.resolveSymbolicLinksSync();
      final targetFile = File(rawPath);
      if (targetFile.existsSync()) {
        final canonicalTarget = targetFile.resolveSymbolicLinksSync();
        if (canonicalTarget.startsWith(canonicalDir)) {
          targetFile.deleteSync();
        }
      }
    } catch (_) {}
  }

  void _deletePhoto(Map<String, dynamic> photo) async {
    final stored = _photosBox.get('photos', defaultValue: []) as List;
    stored.removeWhere((p) => p is Map && p['dateKey'] == photo['dateKey']);
    await _photosBox.put('photos', stored);

    // Delete file safely inside sandbox
    final path = photo['photoPath'] as String?;
    await _safeDeletePhotoFile(path);

    _loadPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        return Scaffold(
          appBar: AppBar(
            title: Text(settings.isTamil ? 'மாற்ற காலவரிசை' : 'Transformation Timeline'),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _photos.isEmpty
                  ? _buildEmptyState(context, settings)
                  : _buildPhotoTimeline(context, settings),
          floatingActionButton: FloatingActionButton(
            onPressed: _isUploading ? null : _showSourcePicker,
            child: _isUploading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.add_a_photo),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, SettingsState settings) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primarySurface,
                border: Border.all(color: AppColors.primary.withAlpha(77), width: 2),
              ),
              child: const Center(child: Text('📸', style: TextStyle(fontSize: 48))),
            ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: 24),
            Text(
              settings.isTamil ? 'உங்கள் மாற்ற பயணம்' : 'Your Transformation Journey',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            Text(
              settings.isTamil
                  ? 'ஒவ்வொரு நாளும் ஒரு செல்ஃபி எடுத்து உங்கள் முன்னேற்றத்தைக் காணுங்கள்!'
                  : 'Take a daily photo to track your transformation!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryDark),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _showSourcePicker,
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(settings.isTamil ? 'முதல் படம் சேர்' : 'Add First Photo'),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoTimeline(BuildContext context, SettingsState settings) {
    // Check if today's photo exists
    final todayKey = _todayKey();
    final hasTodayPhoto = _photos.any((p) => p['dateKey'] == todayKey);

    return CustomScrollView(
      slivers: [
        // Today's status
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: NeonCard(
              showGlow: true,
              glowColor: hasTodayPhoto ? AppColors.success : AppColors.primary,
              glowIntensity: 0.3,
              child: Row(
                children: [
                  Icon(
                    hasTodayPhoto ? Icons.check_circle : Icons.camera_alt_outlined,
                    color: hasTodayPhoto ? AppColors.success : AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasTodayPhoto
                          ? (settings.isTamil ? 'இன்றைய படம் எடுக்கப்பட்டது ✓' : "Today's photo captured ✓")
                          : (settings.isTamil ? 'இன்றைய படம் எடுக்கவும்' : "Take today's photo"),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: hasTodayPhoto ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    '${_photos.length} ${settings.isTamil ? 'படங்கள்' : 'photos'}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 400.ms),
        ),

        // Photo grid
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final photo = _photos[index];
                final file = File(photo['photoPath'] ?? '');
                final exists = file.existsSync();

                return GestureDetector(
                  onTap: exists ? () => _showFullPhoto(photo) : null,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: photo['dateKey'] == todayKey
                            ? AppColors.primary.withAlpha(128)
                            : AppColors.borderDark.withAlpha(77),
                        width: photo['dateKey'] == todayKey ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (exists)
                            Image.file(file, fit: BoxFit.cover)
                          else
                            Container(
                              color: AppColors.surfaceAltDark,
                              child: const Center(child: Icon(Icons.broken_image_outlined, color: AppColors.textTertiaryDark)),
                            ),
                          // Date label
                          Positioned(
                            left: 0, right: 0, bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black.withAlpha(179), Colors.transparent],
                                ),
                              ),
                              child: Text(
                                _formatDate(photo['dateKey'] ?? ''),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms);
              },
              childCount: _photos.length,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateKey) {
    try {
      final parts = dateKey.split('-');
      if (parts.length == 3) {
        final months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final month = int.parse(parts[1]);
        return '${months[month]} ${parts[2]}';
      }
    } catch (_) {}
    return dateKey;
  }
}
