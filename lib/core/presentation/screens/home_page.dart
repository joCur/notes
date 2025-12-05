/// Home Page (Placeholder)
///
/// Temporary placeholder home screen for authenticated users.
/// This will be replaced with the actual note list in future phases.
///
/// Features:
/// - Simple welcome message
/// - Bauhaus styling
/// - Sign out functionality
/// - Placeholder for future note list
///
/// Architecture:
/// - Uses Riverpod for auth state management
/// - Protected route (requires authentication)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/application/auth_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../theme/bauhaus_spacing.dart';
import '../theme/bauhaus_typography.dart';
import '../widgets/buttons/bauhaus_elevated_button.dart';

/// Placeholder home page for authenticated users
///
/// This screen follows Bauhaus design principles:
/// - Clean, minimalist layout
/// - Clear visual hierarchy
/// - Functional design
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: Text(
          l10n.appTitle.toUpperCase(),
          style: BauhausTypography.screenTitle.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w300,
            letterSpacing: 4.0,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/voice-input');
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Sharp corners for Bauhaus style
        ),
        tooltip: l10n.voiceButtonStartRecording,
        child: const Icon(Icons.mic),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(BauhausSpacing.large),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome message
                Text(
                  l10n.welcome,
                  style: BauhausTypography.heroText.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: BauhausSpacing.medium),

                // User email
                if (currentUser != null)
                  Text(
                    currentUser.email,
                    style: BauhausTypography.bodyText.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: BauhausSpacing.xxLarge),

                // Placeholder message
                Container(
                  padding: EdgeInsets.all(BauhausSpacing.large),
                  color: colorScheme.surface,
                  child: Column(
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 64,
                        color: colorScheme.primary,
                      ),
                      SizedBox(height: BauhausSpacing.medium),
                      Text(
                        l10n.noteListComingSoon,
                        style: BauhausTypography.sectionHeader.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: BauhausSpacing.small),
                      Text(
                        l10n.homePagePlaceholder,
                        style: BauhausTypography.bodyText.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: BauhausSpacing.xxLarge),

                // Sign out button
                BauhausElevatedButton(
                  label: l10n.signOut,
                  onPressed: () {
                    // Call signOut without awaiting to avoid ref disposal issues
                    // Navigation handled automatically by GoRouter watching authStateStreamProvider
                    ref.read(authProvider.notifier).signOut();
                  },
                  fullWidth: true,
                  backgroundColor: colorScheme.secondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
