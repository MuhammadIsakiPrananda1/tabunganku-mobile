import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/features/splash/presentation/pages/splash_screen.dart';
import 'package:tabunganku/features/home/presentation/pages/dashboard_page.dart';
import 'package:tabunganku/features/auth/presentation/pages/lock_screen.dart';
import 'package:tabunganku/features/friends/presentation/pages/family_group_page.dart';
import 'package:tabunganku/features/settings/presentation/pages/pin_setup_page.dart';
import 'package:tabunganku/features/home/presentation/pages/saving_simulator_page.dart';
import 'package:tabunganku/features/transaction/presentation/pages/scan_receipt_page.dart';
import 'package:tabunganku/features/challenge/presentation/pages/challenge_page.dart';
import 'package:tabunganku/features/budget/presentation/pages/monthly_budget_page.dart';
import 'package:tabunganku/features/home/presentation/pages/zakat_page.dart';
final appRouterProvider = Provider((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Main Routes
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),

      // Security Lock
      GoRoute(
        path: '/lock',
        name: 'lock',
        builder: (context, state) => const LockScreen(),
      ),

      // Family Group
      GoRoute(
        path: '/family-group',
        name: 'family-group',
        builder: (context, state) => const FamilyGroupPage(),
      ),

      // PIN Setup
      GoRoute(
        path: '/pin-setup',
        name: 'pin-setup',
        builder: (context, state) => const PinSetupPage(),
      ),

      GoRoute(
        path: '/saving-simulator',
        name: 'saving-simulator',
        builder: (context, state) => const SavingSimulatorPage(),
      ),

      // Scan Receipt
      GoRoute(
        path: '/scan-receipt',
        name: 'scan-receipt',
        builder: (context, state) => const ScanReceiptPage(),
      ),

      // Challenge Page
      GoRoute(
        path: '/challenge',
        name: 'challenge',
        builder: (context, state) => const ChallengePage(),
      ),

      // Monthly Budget Page
      GoRoute(
        path: '/monthly-budget',
        name: 'monthly-budget',
        builder: (context, state) => const MonthlyBudgetPage(),
      ),

      // Zakat & Infaq Page
      GoRoute(
        path: '/zakat',
        name: 'zakat',
        builder: (context, state) => const ZakatPage(),
      ),

      // Catch-all redirect to splash
      GoRoute(
        path: '/',
        name: 'home',
        redirect: (context, state) => '/splash',
      ),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/splash'),
              child: const Text('Kembali ke Awal'),
            ),
          ],
        ),
      ),
    ),
  );
});
