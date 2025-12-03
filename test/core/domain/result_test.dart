import 'package:flutter_test/flutter_test.dart';
import 'package:notes/core/domain/result.dart';
import 'package:notes/core/domain/failures/app_failure.dart';

void main() {
  group('Result', () {
    group('isSuccess', () {
      test('returns true for Success result', () {
        // Arrange
        final result = Result<int>.success(42);

        // Act & Assert
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
      });

      test('returns false for Failure result', () {
        // Arrange
        const failure = AppFailure.unknown(message: 'error');
        final result = Result<int>.failure(failure);

        // Act & Assert
        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
      });
    });

    group('dataOrNull', () {
      test('returns data for Success result', () {
        // Arrange
        final result = Result<String>.success('test data');

        // Act
        final data = result.dataOrNull;

        // Assert
        expect(data, equals('test data'));
      });

      test('returns null for Failure result', () {
        // Arrange
        const failure = AppFailure.unknown(message: 'error');
        final result = Result<String>.failure(failure);

        // Act
        final data = result.dataOrNull;

        // Assert
        expect(data, isNull);
      });
    });

    group('errorOrNull', () {
      test('returns null for Success result', () {
        // Arrange
        final result = Result<int>.success(42);

        // Act
        final error = result.errorOrNull;

        // Assert
        expect(error, isNull);
      });

      test('returns error for Failure result', () {
        // Arrange
        const failure = AppFailure.auth(message: 'auth error', code: '401');
        final result = Result<int>.failure(failure);

        // Act
        final error = result.errorOrNull;

        // Assert
        expect(error, equals(failure));
      });
    });

    group('ResultExtensions.map', () {
      test('transforms success value with mapper function', () {
        // Arrange
        final result = Result<int>.success(5);

        // Act
        final mapped = ResultExtensions(result).map((value) => value * 2);

        // Assert
        expect(mapped.isSuccess, isTrue);
        expect(mapped.dataOrNull, equals(10));
      });

      test('transforms to different type', () {
        // Arrange
        final result = Result<int>.success(42);

        // Act
        final mapped = ResultExtensions(result).map((value) => 'Number: $value');

        // Assert
        expect(mapped.isSuccess, isTrue);
        expect(mapped.dataOrNull, equals('Number: 42'));
      });

      test('preserves failure without calling mapper', () {
        // Arrange
        const failure = AppFailure.database(message: 'db error', code: '500');
        final result = Result<int>.failure(failure);
        var mapperCalled = false;

        // Act
        final mapped = ResultExtensions(result).map((value) {
          mapperCalled = true;
          return value * 2;
        });

        // Assert
        expect(mapped.isFailure, isTrue);
        expect(mapped.errorOrNull, equals(failure));
        expect(mapperCalled, isFalse); // Mapper should not be called
      });
    });

    group('ResultExtensions.flatMap', () {
      test('chains successful operations', () {
        // Arrange
        final result = Result<int>.success(5);

        // Act
        final flatMapped = ResultExtensions(result).flatMap(
          (value) => Result<String>.success('Value: $value'),
        );

        // Assert
        expect(flatMapped.isSuccess, isTrue);
        expect(flatMapped.dataOrNull, equals('Value: 5'));
      });

      test('returns failure from mapper when mapper fails', () {
        // Arrange
        final result = Result<int>.success(5);
        const expectedFailure = AppFailure.validation(
          message: 'Value too small',
          field: 'number',
        );

        // Act
        final flatMapped = ResultExtensions(result).flatMap(
          (value) => Result<String>.failure(expectedFailure),
        );

        // Assert
        expect(flatMapped.isFailure, isTrue);
        expect(flatMapped.errorOrNull, equals(expectedFailure));
      });

      test('preserves original failure without calling mapper', () {
        // Arrange
        const failure = AppFailure.network(message: 'network error');
        final result = Result<int>.failure(failure);
        var mapperCalled = false;

        // Act
        final flatMapped = ResultExtensions(result).flatMap((value) {
          mapperCalled = true;
          return Result<String>.success('Should not be called');
        });

        // Assert
        expect(flatMapped.isFailure, isTrue);
        expect(flatMapped.errorOrNull, equals(failure));
        expect(mapperCalled, isFalse); // Mapper should not be called
      });

      test('chains multiple operations', () {
        // Arrange
        final result = Result<int>.success(10);

        // Act
        final chained = ResultExtensions(
          ResultExtensions(result).flatMap(
            (value) => Result<int>.success(value * 2),
          ),
        ).flatMap((value) => Result<String>.success('Result: $value'));

        // Assert
        expect(chained.isSuccess, isTrue);
        expect(chained.dataOrNull, equals('Result: 20'));
      });

      test('stops chain at first failure', () {
        // Arrange
        final result = Result<int>.success(10);
        const failure = AppFailure.unknown(message: 'chain broken');
        var secondMapperCalled = false;

        // Act
        final firstMap = ResultExtensions(result).flatMap(
          (value) => Result<int>.failure(failure),
        );
        final chained = ResultExtensions(firstMap).flatMap((value) {
          secondMapperCalled = true;
          return Result<String>.success('Should not reach here');
        });

        // Assert
        expect(chained.isFailure, isTrue);
        expect(chained.errorOrNull, equals(failure));
        expect(secondMapperCalled, isFalse);
      });
    });
  });
}
