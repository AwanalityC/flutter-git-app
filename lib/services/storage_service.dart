import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';

// Handles saving and loading DiaryEntry objects to the device's local
// storage. SharedPreferences only stores simple types (String, int, bool,
// List<String>, etc) — so we convert each entry to a JSON string first.
class StorageService {
  static const String _storageKey = 'diary_entries';

  // Reads the raw list of JSON strings, decodes each one, and returns
  // a list of DiaryEntry objects.
  Future<List<DiaryEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_storageKey) ?? [];

    return rawList.map((jsonString) {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return DiaryEntry.fromJson(map);
    }).toList();
  }

  // Loads the existing list, adds the new entry, and saves it back.
  Future<void> saveEntry(DiaryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_storageKey) ?? [];

    final newJsonString = jsonEncode(entry.toJson());
    existing.add(newJsonString);

    await prefs.setStringList(_storageKey, existing);
  }

  // Optional but handy while testing — wipes all saved entries.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}