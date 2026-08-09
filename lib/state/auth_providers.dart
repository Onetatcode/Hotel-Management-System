import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(client: Supabase.instance.client);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  final state = ref.watch(authStateProvider).asData?.value;
  return state?.session?.user;
});

final staffProfileProvider = FutureProvider<StaffProfile?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Future.value(null);
  }
  return ref.watch(authServiceProvider).fetchStaffProfile(user.id);
});
