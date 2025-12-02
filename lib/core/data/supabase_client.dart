import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../env/env.dart';

part 'supabase_client.g.dart';

/// Initialize Supabase with configuration from environment variables.
///
/// This should be called once during app initialization in main.dart
/// before runApp().
///
/// Example:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await initializeSupabase();
///   runApp(MyApp());
/// }
/// ```
Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
}

/// Provider for accessing the Supabase client instance.
///
/// Usage:
/// ```dart
/// final supabase = ref.watch(supabaseClientProvider);
/// final response = await supabase.from('notes').select();
/// ```
@riverpod
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}

/// Convenience getter for the Supabase client.
///
/// Usage in non-Riverpod contexts:
/// ```dart
/// final notes = await supabase.from('notes').select();
/// ```
SupabaseClient get supabase => Supabase.instance.client;
