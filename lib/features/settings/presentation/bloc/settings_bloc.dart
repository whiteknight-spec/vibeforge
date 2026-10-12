import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';

// ── Events ──────────────────────────────────────────────────────
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class ToggleTheme extends SettingsEvent {
  const ToggleTheme();
}

class ChangeColorTheme extends SettingsEvent {
  final String colorTheme;
  const ChangeColorTheme(this.colorTheme);
  @override
  List<Object?> get props => [colorTheme];
}

class ChangeLanguage extends SettingsEvent {
  final String languageCode;
  const ChangeLanguage(this.languageCode);
  @override
  List<Object?> get props => [languageCode];
}

class ToggleCloudBackup extends SettingsEvent {
  const ToggleCloudBackup();
}

class ToggleAI extends SettingsEvent {
  const ToggleAI();
}

class UpdateUserName extends SettingsEvent {
  final String name;
  const UpdateUserName(this.name);
  @override
  List<Object?> get props => [name];
}

class UpdateProfilePicture extends SettingsEvent {
  final String? path;
  const UpdateProfilePicture(this.path);
  @override
  List<Object?> get props => [path];
}

// ── State ───────────────────────────────────────────────────────
class SettingsState extends Equatable {
  final bool isDarkMode;
  final String colorTheme;
  final String languageCode;
  final bool isCloudBackupEnabled;
  final bool isAiEnabled;
  final String userName;
  final String? profilePicturePath;

  const SettingsState({
    this.isDarkMode = true,
    this.colorTheme = 'cyber_neon',
    this.languageCode = 'en',
    this.isCloudBackupEnabled = false,
    this.isAiEnabled = true,
    this.userName = 'Champion',
    this.profilePicturePath,
  });

  bool get isTamil => languageCode == 'ta';

  SettingsState copyWith({
    bool? isDarkMode,
    String? colorTheme,
    String? languageCode,
    bool? isCloudBackupEnabled,
    bool? isAiEnabled,
    String? userName,
    String? profilePicturePath,
    bool clearProfilePicture = false,
  }) => SettingsState(
    isDarkMode: isDarkMode ?? this.isDarkMode,
    colorTheme: colorTheme ?? this.colorTheme,
    languageCode: languageCode ?? this.languageCode,
    isCloudBackupEnabled: isCloudBackupEnabled ?? this.isCloudBackupEnabled,
    isAiEnabled: isAiEnabled ?? this.isAiEnabled,
    userName: userName ?? this.userName,
    profilePicturePath: clearProfilePicture ? null : (profilePicturePath ?? this.profilePicturePath),
  );

  @override
  List<Object?> get props => [
    isDarkMode,
    colorTheme,
    languageCode,
    isCloudBackupEnabled,
    isAiEnabled,
    userName,
    profilePicturePath,
  ];
}

// ── BLoC ────────────────────────────────────────────────────────
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<LoadSettings>(_onLoad);
    on<ToggleTheme>(_onToggleTheme);
    on<ChangeColorTheme>(_onChangeColorTheme);
    on<ChangeLanguage>(_onChangeLanguage);
    on<ToggleCloudBackup>(_onToggleCloud);
    on<ToggleAI>(_onToggleAI);
    on<UpdateUserName>(_onUpdateName);
    on<UpdateProfilePicture>(_onUpdateProfilePicture);
  }

  Box get _box => Hive.box(AppConstants.hiveSettingsBox);

  Future<void> _onLoad(LoadSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsState(
      isDarkMode: _box.get('isDarkMode', defaultValue: true),
      colorTheme: _box.get('colorTheme', defaultValue: 'cyber_neon'),
      languageCode: _box.get('languageCode', defaultValue: 'en'),
      isCloudBackupEnabled: _box.get('cloudBackup', defaultValue: false),
      isAiEnabled: _box.get('aiEnabled', defaultValue: true),
      userName: _box.get('userName', defaultValue: 'Champion'),
      profilePicturePath: _box.get('profilePicturePath'),
    ));
  }

  Future<void> _onToggleTheme(ToggleTheme event, Emitter<SettingsState> emit) async {
    final newVal = !state.isDarkMode;
    await _box.put('isDarkMode', newVal);
    emit(state.copyWith(isDarkMode: newVal));
  }

  Future<void> _onChangeColorTheme(ChangeColorTheme event, Emitter<SettingsState> emit) async {
    await _box.put('colorTheme', event.colorTheme);
    emit(state.copyWith(colorTheme: event.colorTheme));
  }

  Future<void> _onChangeLanguage(ChangeLanguage event, Emitter<SettingsState> emit) async {
    await _box.put('languageCode', event.languageCode);
    emit(state.copyWith(languageCode: event.languageCode));
  }

  Future<void> _onToggleCloud(ToggleCloudBackup event, Emitter<SettingsState> emit) async {
    final newVal = !state.isCloudBackupEnabled;
    await _box.put('cloudBackup', newVal);
    emit(state.copyWith(isCloudBackupEnabled: newVal));
  }

  Future<void> _onToggleAI(ToggleAI event, Emitter<SettingsState> emit) async {
    final newVal = !state.isAiEnabled;
    await _box.put('aiEnabled', newVal);
    emit(state.copyWith(isAiEnabled: newVal));
  }

  Future<void> _onUpdateName(UpdateUserName event, Emitter<SettingsState> emit) async {
    await _box.put('userName', event.name);
    emit(state.copyWith(userName: event.name));
  }

  Future<void> _onUpdateProfilePicture(UpdateProfilePicture event, Emitter<SettingsState> emit) async {
    if (event.path != null) {
      await _box.put('profilePicturePath', event.path);
      emit(state.copyWith(profilePicturePath: event.path));
    } else {
      await _box.delete('profilePicturePath');
      emit(state.copyWith(clearProfilePicture: true));
    }
  }
}
