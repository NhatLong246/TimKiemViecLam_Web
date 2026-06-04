import 'package:flutter/material.dart';
import '../data/models/config_model.dart';
import '../data/services/config_service.dart';

class SettingsController extends ChangeNotifier {
  final ConfigService _service = ConfigService();

  ConfigModel? _config;
  bool isLoading = false;
  String? errorMessage;

  ConfigModel? get config => _config;

  Future<void> fetchConfig() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _config = await _service.fetchConfig();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateConfig(ConfigModel newConfig) async {
    try {
      await _service.updateConfig(newConfig);
      _config = newConfig;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
