import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/login_screen.dart';
import '../screens/availability/availability_screen.dart';
import '../screens/bookings/bookings_screen.dart';
import '../screens/chatbot/chatbot_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/guests/guests_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/rooms/rooms_screen.dart';
import '../screens/shell/app_shell.dart';
import '../state/auth_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn = ref.read(currentUserProvider) != null;
      if (state.matchedLocation == '/') {
        return loggedIn ? '/dashboard' : '/login';
      }
      final onLogin = state.matchedLocation == '/login';
      if (!loggedIn && !onLogin) {
        return '/login';
      }
      if (loggedIn && onLogin) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rooms',
                builder: (context, state) => const RoomsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/availability',
                builder: (context, state) => const AvailabilityScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                builder: (context, state) => const BookingsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/guests',
                builder: (context, state) => const GuestsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/assistant',
                builder: (context, state) => const ChatbotScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
