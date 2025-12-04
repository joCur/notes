import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/l10n/app_localizations.dart';

import 'core/data/supabase_client.dart';
import 'core/presentation/theme/app_theme.dart';
import 'core/routing/router.dart';
import 'core/utils/logger.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set up error handling with Talker
  FlutterError.onError = (details) {
    logger.handle(details.exception, details.stack);
  };

  // Initialize Supabase
  await initializeSupabase();

  // Log successful initialization
  logger.info('App initialized successfully');

  // Run app with Riverpod provider scope
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Voice Notes',
      routerConfig: router,
      // Localization delegates
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('de'), // German
      ],
      // Use Bauhaus theme
      theme: BauhausTheme.lightTheme,
      darkTheme: BauhausTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}
