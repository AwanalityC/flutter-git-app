// A simple data class representing one saved mood entry.
// You'll use this in Phase 4 when you add saving.
class DiaryEntry {
  final DateTime date;
  final double sunPosition; // 0.0 (far left / low mood) to 1.0 (far right / good mood)
  final String? note;

  DiaryEntry({
    required this.date,
    required this.sunPosition,
    this.note,
  });

  // Converts this entry into a simple Map so it can be turned into JSON.
  // You'll need this for Phase 4 (saving with shared_preferences).
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'sunPosition': sunPosition,
      'note': note,
    };
  }

  // Rebuilds a DiaryEntry from a Map (the reverse of toJson).
  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      date: DateTime.parse(json['date'] as String),
      sunPosition: (json['sunPosition'] as num).toDouble(),
      note: json['note'] as String?,
    );
  }
}