import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../services/storage_service.dart';
import '../widgets/room_scene.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final StorageService _storage = StorageService();
  List<DiaryEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await _storage.loadEntries();
    setState(() {
      // Newest first.
      _entries = entries.reversed.toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your History')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const Center(
                  child: Text(
                    'No entries yet — go save your first one!',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      clipBehavior: Clip.antiAlias,
                      child: Row(
                        children: [
                          // Mini reused scene — same painter, tiny size.
                          SizedBox(
                            width: 90,
                            height: 90,
                            child: CustomPaint(
                              size: const Size(90, 90),
                              painter: RoomScenePainter(sunX: entry.sunPosition),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('EEEE, MMM d – h:mm a').format(entry.date),
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _moodLabelFor(entry.sunPosition),
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  if (entry.note != null && entry.note!.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(entry.note!),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  // Same logic as HomeScreen's moodLabel — kept here too since this
  // screen works from saved entries, not live drag state.
  String _moodLabelFor(double sunX) {
    if (sunX < 0.25) return 'Heavy day';
    if (sunX < 0.45) return 'A little low';
    if (sunX < 0.6) return 'Neutral';
    if (sunX < 0.8) return 'Pretty good';
    return 'Bright day';
  }
}