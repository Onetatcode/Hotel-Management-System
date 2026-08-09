import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/auth_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(staffProfileProvider);
    final user = ref.watch(currentUserProvider);
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hotel Management App')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: profile.when(
            loading: () => const CircularProgressIndicator(),
            error: (error, _) => Text('Failed to load profile: $error'),
            data: (p) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Signed in as ${p?.name ?? 'staff'}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('Role: ${p?.role ?? 'unknown'}'),
                const SizedBox(height: 8),
                Text('Email: ${user?.email ?? ''}'),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => authService.signOut(),
                  child: const Text('Sign Out'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Dashboard & navigation arrive in Phase 3.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
