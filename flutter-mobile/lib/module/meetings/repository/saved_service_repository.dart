import 'dart:convert';
import 'package:Appointly/module/meetings/model/saved_service_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedServiceRepository {
  // Key used for storing saved services in SharedPreferences
  static const String _key = 'saved_services';

  /// Retrieves all saved services from SharedPreferences
  Future<List<SavedServiceModel>> getSavedServices() async {
    /// 1. Gets SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    /// 2. Retrieves JSON string using the _key
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    /// 3. Converts JSON string to list of SavedServiceModel objects

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => SavedServiceModel.fromJson(json)).toList();
  }

  Future<void> saveService(SavedServiceModel service) async {
    /// 1. Gets existing saved services

    final prefs = await SharedPreferences.getInstance();

    final savedServices = await getSavedServices();

    /// 2. Checks if service with same ID already exists
    /// /// 3. If not exists:
    ///    - Adds new service to list
    ///    - Converts updated list to JSON
    ///    - Saves JSON string to SharedPreferences
    if (!savedServices.any((s) => s.id == service.id)) {
      savedServices.add(service);
      final jsonString =
          json.encode(savedServices.map((s) => s.toJson()).toList());
      await prefs.setString(_key, jsonString);
    }
  }

  /// Checks if a service is already saved in SharedPreferences
  Future<bool> isServiceSaved(int serviceId) async {
    final savedServices = await getSavedServices();
    return savedServices.any((s) => s.id == serviceId);
  }

  /// Removes a service from SharedPreferences
  Future<void> removeService(int serviceId) async {
    /// 1. Gets existing saved services

    final prefs = await SharedPreferences.getInstance();
    final savedServices = await getSavedServices();

    /// 2. Removes service with matching ID

    savedServices.removeWhere((s) => s.id == serviceId);

    /// 3. Converts updated list to JSON

    final jsonString =
        json.encode(savedServices.map((s) => s.toJson()).toList());

    /// 4. Saves updated JSON string to SharedPreferences

    await prefs.setString(_key, jsonString);
  }

  Future<List<SavedServiceModel>> getOnlineServices() async {
    final services = await getSavedServices();
    return services.where((s) => s.option.contains('Online')).toList();
  }

  Future<List<SavedServiceModel>> getOfflineServices() async {
    final services = await getSavedServices();
    return services.where((s) => s.option.contains('Offline')).toList();
  }
}
