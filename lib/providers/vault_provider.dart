import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/iap_constants.dart';
import '../core/services/hive_service.dart';
import '../models/vault_item.dart';

class VaultProvider extends ChangeNotifier {
  static const _uuid = Uuid();

  List<VaultItem> _items = [];
  bool _loaded = false;
  String _searchQuery = '';

  List<VaultItem> get items => _items;
  bool get isLoaded => _loaded;
  String get searchQuery => _searchQuery;

  List<VaultItem> get passwords => _filtered(VaultItemType.password);
  List<VaultItem> get notes => _filtered(VaultItemType.note);
  List<VaultItem> get documents => _filtered(VaultItemType.document);
  List<VaultItem> get favorites => _items.where((i) => i.favorite).toList();
  List<VaultItem> get recentItems {
    final sorted = List<VaultItem>.from(_items)..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.take(5).toList();
  }

  int countOf(VaultItemType type) => _items.where((i) => i.type == type).length;

  List<VaultItem> _filtered(VaultItemType type) {
    final list = _items.where((i) => i.type == type).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((i) {
      return i.title.toLowerCase().contains(q) ||
          (i.username?.toLowerCase().contains(q) ?? false) ||
          (i.content?.toLowerCase().contains(q) ?? false) ||
          (i.notes?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<void> load() async {
    final raw = HiveService.instance.getAllJson();
    _items = raw.map((json) => VaultItem.fromJson(jsonDecode(json) as Map<String, dynamic>)).toList();
    _loaded = true;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  bool canAdd(VaultItemType type, {required bool unlimited}) {
    if (unlimited) return true;
    return switch (type) {
      VaultItemType.password => countOf(type) < IapConstants.freePasswordLimit,
      VaultItemType.note => countOf(type) < IapConstants.freeNoteLimit,
      VaultItemType.document => countOf(type) < IapConstants.freeDocumentLimit,
    };
  }

  int limitFor(VaultItemType type) => switch (type) {
        VaultItemType.password => IapConstants.freePasswordLimit,
        VaultItemType.note => IapConstants.freeNoteLimit,
        VaultItemType.document => IapConstants.freeDocumentLimit,
      };

  Future<VaultItem?> saveItem({
    String? id,
    required VaultItemType type,
    required String title,
    String? username,
    String? password,
    String? url,
    String? content,
    String? filePath,
    String? fileName,
    String? notes,
    bool favorite = false,
  }) async {
    final now = DateTime.now();
    final existing = id != null ? _items.where((i) => i.id == id).firstOrNull : null;
    final item = VaultItem(
      id: id ?? _uuid.v4(),
      type: type,
      title: title.trim(),
      username: username?.trim(),
      password: password,
      url: url?.trim(),
      content: content,
      filePath: filePath,
      fileName: fileName,
      notes: notes?.trim(),
      favorite: favorite,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    await HiveService.instance.saveItem(item.id, jsonEncode(item.toJson()));
    final idx = _items.indexWhere((i) => i.id == item.id);
    if (idx >= 0) {
      _items[idx] = item;
    } else {
      _items.add(item);
    }
    notifyListeners();
    return item;
  }

  Future<void> deleteItem(String id) async {
    final item = _items.where((i) => i.id == id).firstOrNull;
    if (item == null) return;

    if (item.filePath != null) {
      try {
        final file = File(item.filePath!);
        if (await file.exists()) await file.delete();
      } catch (e) {
        debugPrint('Delete file error: $e');
      }
    }

    await HiveService.instance.deleteItem(id);
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx < 0) return;
    final updated = _items[idx].copyWith(favorite: !_items[idx].favorite, updatedAt: DateTime.now());
    await HiveService.instance.saveItem(updated.id, jsonEncode(updated.toJson()));
    _items[idx] = updated;
    notifyListeners();
  }

  Future<String?> copyDocumentToVault(String sourcePath, String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final vaultDir = Directory('${dir.path}/vault_docs');
      if (!await vaultDir.exists()) await vaultDir.create(recursive: true);
      final dest = File('${vaultDir.path}/$fileName');
      await File(sourcePath).copy(dest.path);
      return dest.path;
    } catch (e) {
      debugPrint('Copy document error: $e');
      return null;
    }
  }

  String exportAll(String Function(String key) t) {
    if (_items.isEmpty) return '';
    final buffer = StringBuffer();
    buffer.writeln('=== ${t('appName')} Export ===');
    buffer.writeln('${t('exportDate')}: ${DateTime.now()}');
    buffer.writeln();

    for (final item in _items) {
      buffer.writeln('--- ${item.title} (${item.type.name}) ---');
      if (item.username != null) buffer.writeln('${t('fieldUsername')}: ${item.username}');
      if (item.password != null) buffer.writeln('${t('fieldPassword')}: ${item.password}');
      if (item.url != null) buffer.writeln('URL: ${item.url}');
      if (item.content != null) buffer.writeln('${t('fieldContent')}: ${item.content}');
      if (item.fileName != null) buffer.writeln('${t('fieldFile')}: ${item.fileName}');
      if (item.notes != null) buffer.writeln('${t('logNotes')}: ${item.notes}');
      buffer.writeln();
    }
    return buffer.toString();
  }

  Future<void> clearAll() async {
    for (final item in List<VaultItem>.from(_items)) {
      if (item.filePath != null) {
        try {
          final file = File(item.filePath!);
          if (await file.exists()) await file.delete();
        } catch (_) {}
      }
    }
    await HiveService.instance.clearAll();
    _items.clear();
    notifyListeners();
  }
}
