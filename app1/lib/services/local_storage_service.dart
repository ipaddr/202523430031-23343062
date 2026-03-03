import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service untuk mengelola Local Storage dengan operasi CRUD
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();

  late SharedPreferences _prefs;

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  /// Inisialisasi service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== CREATE ====================

  /// Menyimpan data string
  Future<bool> saveString(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (e) {
      debugPrint('Error saving string: $e');
      return false;
    }
  }

  /// Menyimpan data integer
  Future<bool> saveInt(String key, int value) async {
    try {
      return await _prefs.setInt(key, value);
    } catch (e) {
      debugPrint('Error saving int: $e');
      return false;
    }
  }

  /// Menyimpan data double
  Future<bool> saveDouble(String key, double value) async {
    try {
      return await _prefs.setDouble(key, value);
    } catch (e) {
      debugPrint('Error saving double: $e');
      return false;
    }
  }

  /// Menyimpan data boolean
  Future<bool> saveBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (e) {
      debugPrint('Error saving bool: $e');
      return false;
    }
  }

  /// Menyimpan list string
  Future<bool> saveStringList(String key, List<String> value) async {
    try {
      return await _prefs.setStringList(key, value);
    } catch (e) {
      debugPrint('Error saving string list: $e');
      return false;
    }
  }

  /// Menyimpan object sebagai JSON
  Future<bool> saveObject(String key, Map<String, dynamic> value) async {
    try {
      String jsonString = jsonEncode(value);
      return await _prefs.setString(key, jsonString);
    } catch (e) {
      debugPrint('Error saving object: $e');
      return false;
    }
  }

  /// Menyimpan list object sebagai JSON
  Future<bool> saveObjectList(
    String key,
    List<Map<String, dynamic>> value,
  ) async {
    try {
      String jsonString = jsonEncode(value);
      return await _prefs.setString(key, jsonString);
    } catch (e) {
      debugPrint('Error saving object list: $e');
      return false;
    }
  }

  // ==================== READ ====================

  /// Membaca data string
  String? getString(String key, {String defaultValue = ''}) {
    try {
      return _prefs.getString(key) ?? defaultValue;
    } catch (e) {
      debugPrint('Error reading string: $e');
      return defaultValue;
    }
  }

  /// Membaca data integer
  int? getInt(String key, {int defaultValue = 0}) {
    try {
      return _prefs.getInt(key) ?? defaultValue;
    } catch (e) {
      debugPrint('Error reading int: $e');
      return defaultValue;
    }
  }

  /// Membaca data double
  double? getDouble(String key, {double defaultValue = 0.0}) {
    try {
      return _prefs.getDouble(key) ?? defaultValue;
    } catch (e) {
      debugPrint('Error reading double: $e');
      return defaultValue;
    }
  }

  /// Membaca data boolean
  bool? getBool(String key, {bool defaultValue = false}) {
    try {
      return _prefs.getBool(key) ?? defaultValue;
    } catch (e) {
      debugPrint('Error reading bool: $e');
      return defaultValue;
    }
  }

  /// Membaca list string
  List<String>? getStringList(
    String key, {
    List<String> defaultValue = const [],
  }) {
    try {
      return _prefs.getStringList(key) ?? defaultValue;
    } catch (e) {
      debugPrint('Error reading string list: $e');
      return defaultValue;
    }
  }

  /// Membaca object dari JSON
  Map<String, dynamic>? getObject(String key) {
    try {
      String? jsonString = _prefs.getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error reading object: $e');
      return null;
    }
  }

  /// Membaca list object dari JSON
  List<Map<String, dynamic>>? getObjectList(String key) {
    try {
      String? jsonString = _prefs.getString(key);
      if (jsonString == null) return null;
      return List<Map<String, dynamic>>.from(jsonDecode(jsonString) as List);
    } catch (e) {
      debugPrint('Error reading object list: $e');
      return null;
    }
  }

  // ==================== UPDATE ====================

  /// Update data (sama dengan save, tapi untuk kejelasan semantik)
  Future<bool> updateString(String key, String value) => saveString(key, value);

  Future<bool> updateInt(String key, int value) => saveInt(key, value);

  Future<bool> updateDouble(String key, double value) => saveDouble(key, value);

  Future<bool> updateBool(String key, bool value) => saveBool(key, value);

  Future<bool> updateObject(String key, Map<String, dynamic> value) =>
      saveObject(key, value);

  Future<bool> updateObjectList(String key, List<Map<String, dynamic>> value) =>
      saveObjectList(key, value);

  // ==================== DELETE ====================

  /// Menghapus data dengan key tertentu
  Future<bool> delete(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      debugPrint('Error deleting key: $e');
      return false;
    }
  }

  /// Menghapus semua data
  Future<bool> deleteAll() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      debugPrint('Error deleting all: $e');
      return false;
    }
  }

  /// Menghapus multiple keys
  Future<bool> deleteMultiple(List<String> keys) async {
    try {
      for (String key in keys) {
        await _prefs.remove(key);
      }
      return true;
    } catch (e) {
      debugPrint('Error deleting multiple: $e');
      return false;
    }
  }

  // ==================== UTILITY ====================

  /// Cek apakah key ada
  bool containsKey(String key) {
    try {
      return _prefs.containsKey(key);
    } catch (e) {
      debugPrint('Error checking key: $e');
      return false;
    }
  }

  /// Dapatkan semua keys
  Set<String> getAllKeys() {
    try {
      return _prefs.getKeys();
    } catch (e) {
      debugPrint('Error getting all keys: $e');
      return {};
    }
  }

  /// Dapatkan ukuran storage
  int getStorageSize() {
    try {
      return _prefs.getKeys().length;
    } catch (e) {
      debugPrint('Error getting storage size: $e');
      return 0;
    }
  }

  /// Debug: Print semua data
  void debugPrintAll() {
    try {
      final keys = _prefs.getKeys();
      for (String key in keys) {
        final value = _prefs.get(key);
        debugPrint('$key: $value');
      }
    } catch (e) {
      debugPrint('Error printing all: $e');
    }
  }
}

void debugPrint(String message) {
  print('[LocalStorageService] $message');
}
