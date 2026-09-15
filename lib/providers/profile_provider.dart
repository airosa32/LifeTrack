import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/category_icons.dart';
import 'theme_provider.dart';

class ProfileState {
  final String name;
  final int avatarColorValue;

  const ProfileState({required this.name, required this.avatarColorValue});

  Color get avatarColor => Color(avatarColorValue);

  ProfileState copyWith({String? name, int? avatarColorValue}) {
    return ProfileState(
      name: name ?? this.name,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  static const _nameKey = 'pref_profile_name';
  static const _colorKey = 'pref_profile_avatar_color';

  @override
  ProfileState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return ProfileState(
      name: prefs.getString(_nameKey) ?? 'Tiago',
      avatarColorValue: prefs.getInt(_colorKey) ?? CategoryIconRegistry.colorPalette[4].value,
    );
  }

  void setName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(name: trimmed);
    ref.read(sharedPreferencesProvider).setString(_nameKey, trimmed);
  }

  void setAvatarColor(Color color) {
    state = state.copyWith(avatarColorValue: color.value);
    ref.read(sharedPreferencesProvider).setInt(_colorKey, color.value);
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
