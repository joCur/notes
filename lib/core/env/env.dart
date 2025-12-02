import 'package:envied/envied.dart';

part 'env.g.dart';

/// Environment configuration using envied for obfuscated environment variables.
///
/// This class loads sensitive configuration from .env file and obfuscates them
/// at compile time for security.
///
/// Usage:
/// ```dart
/// final url = Env.supabaseUrl;
/// final key = Env.supabaseAnonKey;
/// ```
@Envied(path: '.env', obfuscate: true)
abstract class Env {
  /// Supabase project URL
  @EnviedField(varName: 'SUPABASE_URL')
  static final String supabaseUrl = _Env.supabaseUrl;

  /// Supabase anonymous key for client authentication
  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static final String supabaseAnonKey = _Env.supabaseAnonKey;
}
