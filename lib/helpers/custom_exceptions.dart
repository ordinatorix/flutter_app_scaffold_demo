import 'package:flutter/foundation.dart';

/// Generic exception related to Scaffold app. Check the error code
/// and message for more details.
class ScaffoldException implements Exception {
  const ScaffoldException({
    @required this.message,
    @required this.code,
  });

  /// Unique error code
  final String code;

  /// Complete error message.
  final String message;

  @override
  String toString() {
    return 'code: $code, message: $message';
  }
}
