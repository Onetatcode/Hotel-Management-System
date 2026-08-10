import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/error_state.dart';
import '../../widgets/neumorphic_card.dart';
import '../../widgets/status_badge.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(staffProfileProvider);
    final user = ref.watch(currentUserProvider);
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: NeumorphicCard(
              padding: const EdgeInsets.all(24),
              radius: 24,
              child: profile.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => ErrorState(
                  message: 'Failed to load profile.',
                  onRetry: () => ref.refresh(staffProfileProvider.future),
                ),
                data: (p) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.elevated,
                        child: Text(
                          (p?.name ?? '?').isEmpty
                              ? '?'
                              : p!.name.characters.first,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: AppColors.lime),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        p?.name ?? 'Staff member',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(child: StatusBadge(status: p?.role ?? 'unknown')),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        user?.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => authService.signOut(),
                        icon: const Icon(Icons.logout, color: AppColors.softRed),
                        label: const Text('Sign Out'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.softRed,
                          side: BorderSide(
                            color: AppColors.softRed.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
