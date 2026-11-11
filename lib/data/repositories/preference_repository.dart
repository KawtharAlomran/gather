import '../../models/preference_model.dart';

abstract class PreferenceRepository {
  Future<void> savePreferences(PreferenceModel preferences);
}

class MockPreferenceRepository implements PreferenceRepository {
  PreferenceModel? _preferences;

  @override
  Future<void> savePreferences(PreferenceModel preferences) async {
    _preferences = preferences;
  }

  PreferenceModel? get savedPreferences => _preferences;
}