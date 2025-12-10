import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';
part 'tag.g.dart';

/// Represents a user-defined tag for organizing notes.
///
/// Tags are user-specific and can be assigned to multiple notes.
/// The [usageCount] is automatically maintained by database triggers.
@freezed
sealed class Tag with _$Tag {
  const factory Tag({
    /// Unique identifier for the tag
    required String id,

    /// User ID who owns this tag (enforced by RLS)
    required String userId,

    /// Tag name (unique per user)
    required String name,

    /// Hex color code for visual identification (e.g., '#FF0000')
    required String color,

    /// Optional emoji or icon identifier
    String? icon,

    /// Optional description for the tag's purpose
    String? description,

    /// Number of notes using this tag (auto-updated by trigger)
    @Default(0) int usageCount,

    /// Timestamp when the tag was created
    required DateTime createdAt,
  }) = _Tag;

  const Tag._();

  /// Creates a Tag from JSON data (from Supabase)
  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  /// Whether this tag has been used on any notes
  bool get isUsed => usageCount > 0;

  /// Display name with icon if available
  String get displayName => icon != null ? '$icon $name' : name;

  /// Whether this tag has a description
  bool get hasDescription => description != null && description!.isNotEmpty;
}
