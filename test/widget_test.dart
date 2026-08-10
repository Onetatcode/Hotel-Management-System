import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hotelms/main.dart';
import 'package:hotelms/models/booking.dart';
import 'package:hotelms/models/guest.dart';
import 'package:hotelms/models/room.dart';
import 'package:hotelms/screens/auth/login_screen.dart';
import 'package:hotelms/screens/dashboard/dashboard_screen.dart';
import 'package:hotelms/screens/profile/profile_screen.dart';
import 'package:hotelms/services/auth_service.dart';
import 'package:hotelms/state/auth_providers.dart';
import 'package:hotelms/state/data_providers.dart';

class _EmptyRoomsController extends RoomsController {
  @override
  Future<List<Room>> build() async => const [];
}

class _EmptyGuestsController extends GuestsController {
  @override
  Future<List<Guest>> build() async => const [];
}

class _EmptyBookingsController extends BookingsController {
  @override
  Future<List<Booking>> build() async => const [];
}

void main() {
  testWidgets('unauthenticated users land on Login', (tester) async {
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
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('authenticated users land on Dashboard shell; Profile shows role', (tester) async {
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
          roomsControllerProvider.overrideWith(_EmptyRoomsController.new),
          guestsControllerProvider.overrideWith(_EmptyGuestsController.new),
          bookingsControllerProvider.overrideWith(_EmptyBookingsController.new),
        ],
        child: const HotelManagementApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Rooms'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Hotel Admin'), findsOneWidget);
    expect(find.text('admin'), findsOneWidget);
  });
}
