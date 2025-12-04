import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_filter.freezed.dart';
part 'note_filter.g.dart';

/// Sort order for note queries
enum NoteSortOrder {
  @JsonValue('date_desc')
  dateDescending,
  @JsonValue('date_asc')
  dateAscending,
  @JsonValue('relevance')
  relevance,
}

/// Filter criteria for searching and filtering notes
///
/// Used to build complex queries with text search, tag filters,
/// language filters, and sorting options.
@freezed
sealed class NoteFilter with _$NoteFilter {
  const NoteFilter._();

  const factory NoteFilter({
    /// Full-text search query
    String? searchQuery,

    /// Filter by specific tag IDs
    List<String>? tagIds,

    /// Filter by language codes (en, de, etc.)
    List<String>? languages,

    /// Minimum language confidence (0.0 to 1.0)
    double? minLanguageConfidence,

    /// Filter notes created after this date
    DateTime? createdAfter,

    /// Filter notes created before this date
    DateTime? createdBefore,

    /// Filter notes updated after this date
    DateTime? updatedAfter,

    /// Filter notes updated before this date
    DateTime? updatedBefore,

    /// Sort order for results
    @Default(NoteSortOrder.dateDescending) NoteSortOrder sortOrder,

    /// Limit number of results
    int? limit,

    /// Offset for pagination
    @Default(0) int offset,
  }) = _NoteFilter;

  /// Creates a NoteFilter from JSON
  factory NoteFilter.fromJson(Map<String, dynamic> json) =>
      _$NoteFilterFromJson(json);

  /// Creates an empty filter (returns all notes)
  factory NoteFilter.empty() => const NoteFilter();

  /// Creates a filter for full-text search
  factory NoteFilter.search({
    required String query,
    NoteSortOrder sortOrder = NoteSortOrder.relevance,
  }) =>
      NoteFilter(
        searchQuery: query,
        sortOrder: sortOrder,
      );

  /// Creates a filter for specific tags
  factory NoteFilter.byTags({
    required List<String> tagIds,
    NoteSortOrder sortOrder = NoteSortOrder.dateDescending,
  }) =>
      NoteFilter(
        tagIds: tagIds,
        sortOrder: sortOrder,
      );

  /// Creates a filter for notes in a specific language
  factory NoteFilter.byLanguage({
    required String languageCode,
    double? minConfidence,
    NoteSortOrder sortOrder = NoteSortOrder.dateDescending,
  }) =>
      NoteFilter(
        languages: [languageCode],
        minLanguageConfidence: minConfidence,
        sortOrder: sortOrder,
      );

  /// Creates a filter for recent notes (last N days)
  factory NoteFilter.recent({
    required int days,
    NoteSortOrder sortOrder = NoteSortOrder.dateDescending,
  }) =>
      NoteFilter(
        createdAfter: DateTime.now().subtract(Duration(days: days)),
        sortOrder: sortOrder,
      );

  /// Returns true if any filters are active
  bool get hasFilters =>
      searchQuery != null ||
      tagIds != null ||
      languages != null ||
      minLanguageConfidence != null ||
      createdAfter != null ||
      createdBefore != null ||
      updatedAfter != null ||
      updatedBefore != null;

  /// Returns true if text search is active
  bool get hasSearchQuery => searchQuery != null && searchQuery!.isNotEmpty;

  /// Returns true if tag filters are active
  bool get hasTagFilters => tagIds != null && tagIds!.isNotEmpty;

  /// Returns true if language filters are active
  bool get hasLanguageFilters => languages != null && languages!.isNotEmpty;

  /// Returns true if date range filters are active
  bool get hasDateFilters =>
      createdAfter != null ||
      createdBefore != null ||
      updatedAfter != null ||
      updatedBefore != null;

  /// Returns number of active filters
  int get activeFilterCount {
    int count = 0;
    if (hasSearchQuery) count++;
    if (hasTagFilters) count++;
    if (hasLanguageFilters) count++;
    if (minLanguageConfidence != null) count++;
    if (hasDateFilters) count++;
    return count;
  }

  /// Creates a copy with search query
  NoteFilter withSearch(String query) => copyWith(
        searchQuery: query,
        sortOrder: NoteSortOrder.relevance,
      );

  /// Creates a copy with tag filters
  NoteFilter withTags(List<String> tags) => copyWith(tagIds: tags);

  /// Creates a copy with language filters
  NoteFilter withLanguages(List<String> langs) => copyWith(languages: langs);

  /// Creates a copy with different sort order
  NoteFilter withSortOrder(NoteSortOrder order) => copyWith(sortOrder: order);

  /// Creates a copy with pagination
  NoteFilter withPagination({int? newLimit, int? newOffset}) => copyWith(
        limit: newLimit ?? limit,
        offset: newOffset ?? offset,
      );

  /// Clears all filters
  NoteFilter clearFilters() => NoteFilter.empty();
}
