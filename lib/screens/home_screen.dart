import 'package:flutter/material.dart';
import '../widgets/room_scene.dart';
import '../models/diary_entry.dart';
import '../services/storage_service.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // This one number drives the entire scene. 0.5 = neutral/centered.
  // setState() is enough for now — no need for a state management
  // package yet at this size of app.
  double sunX = 0.5;

  static const double sunDiameter = 56;

  final StorageService _storage = StorageService();
  bool _isSaving = false;

  // Turns sunX into a human-readable mood label for feedback.
  String get moodLabel {
    if (sunX < 0.25) return 'Heavy day';
    if (sunX < 0.45) return 'A little low';
    if (sunX < 0.6) return 'Neutral';
    if (sunX < 0.8) return 'Pretty good';
    return 'Bright day';
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    final entry = DiaryEntry(date: DateTime.now(), sunPosition: sunX);
    await _storage.saveEntry(entry);

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved ✅')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shadow Diary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final sceneHeight = constraints.maxHeight * 0.6;

          return Column(
            children: [
              // --- The scene itself ---
              SizedBox(
                width: width,
                height: sceneHeight,
                child: Stack(
                  children: [
                    // The painted room + shadow, redrawn every time sunX changes.
                    CustomPaint(
                      size: Size(width, sceneHeight),
                      painter: RoomScenePainter(sunX: sunX),
                    ),

                    // The draggable sun.
                    // We use GestureDetector + Positioned instead of the
                    // Draggable widget because we just want free horizontal
                    // movement, not drag-and-drop onto a target.
                    Positioned(
                      left: sunX * (width - sunDiameter),
                      top: 24,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            // Convert the raw pixel movement into a 0.0–1.0
                            // value, and clamp so the sun can't go offscreen.
                            final newX = sunX + details.delta.dx / (width - sunDiameter);
                            sunX = newX.clamp(0.0, 1.0);
                          });
                        },
                        child: Container(
                          width: sunDiameter,
                          height: sunDiameter,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.lerp(Colors.indigo.shade200, Colors.amber, sunX),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(sunX * 0.6),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- Feedback text ---
              Text(
                moodLabel,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Drag the sun to match how you feel today.',
                style: TextStyle(color: Colors.grey),
              ),

              const Spacer(),

              // --- Save button (placeholder for Phase 4) ---
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _handleSave,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save today\'s entry'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}