import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabunganku/features/splash/presentation/pages/splash_screen.dart';
import 'package:tabunganku/features/home/presentation/pages/dashboard_page.dart';
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
