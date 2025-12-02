import 'package:freezed_annotation/freezed_annotation.dart';
import 'failures/app_failure.dart';

part 'result.freezed.dart';

/// A Result type for handling success and failure cases.
///
/// This pattern is used throughout the app to handle operations that can fail
/// without throwing exceptions. It forces explicit handling of error cases.
///
/// Usage:
/// ```dart
/// Result<Note> createNote(String content) {
///   try {
///     final note = // create note
///     return Result.success(note);
///   } catch (e) {
///     return Result.failure(DatabaseFailure(message: e.toString()));
///   }
/// }
///
/// // Using the result
/// final result = createNote('Hello');
/// result.when(
///   success: (note) => print('Created: ${note.id}'),
///   failure: (error) => print('Error: ${error.message}'),
/// );
/// ```
@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(AppFailure error) = Failure<T>;
}

/// Extension methods for Result to make it easier to work with.
extension ResultExtensions<T> on Result<T> {
  /// Returns true if this is a Success result
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a Failure result
  bool get isFailure => this is Failure<T>;

  /// Get the success data if available, otherwise null
  T? get dataOrNull => when(
        success: (data) => data,
        failure: (_) => null,
      );

  /// Get the failure if available, otherwise null
  AppFailure? get errorOrNull => when(
        success: (_) => null,
        failure: (error) => error,
      );

  /// Map the success value to a new type
  Result<R> map<R>(R Function(T) mapper) {
    return when(
      success: (data) => Result.success(mapper(data)),
      failure: (error) => Result.failure(error),
    );
  }

  /// Flat map for chaining Result-returning operations
  Result<R> flatMap<R>(Result<R> Function(T) mapper) {
    return when(
      success: (data) => mapper(data),
      failure: (error) => Result.failure(error),
    );
  }
}
