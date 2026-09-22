import 'package:equatable/equatable.dart';

/// Represents user profile data from Google Sign-In.
class UserEntity extends Equatable {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final String preferredLanguage; // 'en' or 'ta'
  final bool isDarkMode;
  final bool isCloudBackupEnabled;
  final bool isAiEnabled;

  const UserEntity({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.preferredLanguage = 'en',
    this.isDarkMode = true,
    this.isCloudBackupEnabled = false,
    this.isAiEnabled = true,
  });

  UserEntity copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    String? preferredLanguage,
    bool? isDarkMode,
    bool? isCloudBackupEnabled,
    bool? isAiEnabled,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isCloudBackupEnabled: isCloudBackupEnabled ?? this.isCloudBackupEnabled,
      isAiEnabled: isAiEnabled ?? this.isAiEnabled,
    );
  }

  /// The user's first name for greetings.
  String get firstName => displayName.split(' ').first;

  @override
  List<Object?> get props => [
        uid,
        displayName,
        email,
        photoUrl,
        createdAt,
        preferredLanguage,
        isDarkMode,
        isCloudBackupEnabled,
        isAiEnabled,
      ];
}
