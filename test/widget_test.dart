import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hotelms/main.dart';
import 'package:hotelms/screens/auth/login_screen.dart';
import 'package:hotelms/screens/home_screen.dart';
import 'package:hotelms/services/auth_service.dart';
import 'package:hotelms/state/auth_providers.dart';

void main() {
  testWidgets('shows Login screen when signed out', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(AuthService()),
          authStateProvider.overrideWith((ref) => const Stream.empty()),
          currentUserProvider.overrideWith((ref) => null),
        ],
        child: const HotelManagementApp(),
      ),
    );

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('shows Home screen with role when signed in', (tester) async {
    final user = User(
      id: 'user-1',
      appMetadata: const <String, dynamic>{},
      userMetadata: const <String, dynamic>{'email': 'admin@hotelms.test'},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00Z',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(AuthService()),
          authStateProvider.overrideWith((ref) => const Stream.empty()),
          currentUserProvider.overrideWith((ref) => user),
          staffProfileProvider.overrideWith(
            (ref) async => const StaffProfile(
              id: 'staff-1',
              userId: 'user-1',
              name: 'Hotel Admin',
              role: 'admin',
            ),
          ),
        ],
        child: const HotelManagementApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Role: admin'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
  });
}
