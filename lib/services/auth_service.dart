import 'package:supabase_flutter/supabase_flutter.dart';

class StaffProfile {
  const StaffProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.role,
  });

  final String id;
  final String userId;
  final String name;
  final String role;

  bool get isAdmin => role == 'admin';
}

class AuthService {
  AuthService({this._client});

  final SupabaseClient? _client;  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  User? get currentUser => _supabase.auth.currentUser;

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _supabase.auth.signOut();

  Future<StaffProfile?> fetchStaffProfile(String userId) async {
    final rows = await _supabase
        .from('staff')
        .select('id, user_id, name, role')
        .eq('user_id', userId)
        .limit(1);
    if (rows.isEmpty) {
      return null;
    }
    final row = rows.first;
    return StaffProfile(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      name: row['name'] as String,
      role: row['role'] as String,
    );
  }
}
