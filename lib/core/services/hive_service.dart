import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const _vaultBoxName = 'dv_vault_items';

  static final HiveService _instance = HiveService._internal();
  static HiveService get instance => _instance;
  HiveService._internal();

  Box<String>? _vaultBox;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _vaultBox = await Hive.openBox<String>(_vaultBoxName);
    _initialized = true;
  }

  Box<String> get vaultBox {
    if (_vaultBox == null) {
      throw StateError('HiveService not initialized');
    }
    return _vaultBox!;
  }

  Future<void> saveItem(String id, String json) async {
    await vaultBox.put(id, json);
  }

  Future<void> deleteItem(String id) async {
    await vaultBox.delete(id);
  }

  List<String> getAllJson() => vaultBox.values.toList();

  Future<void> clearAll() async {
    await vaultBox.clear();
  }
}
