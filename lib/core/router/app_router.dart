import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/home_page.dart';
import '../../features/offense/presentation/pages/new_traffic_offense_page.dart';
import '../../features/offense/presentation/pages/review_confirm_page.dart';
import '../../features/offense/presentation/pages/prn_issued_page.dart';
import '../../features/service_fee/presentation/pages/new_service_fee_page.dart';
import '../../features/transactions/presentation/pages/search_page.dart';
import '../../features/transactions/presentation/pages/transaction_detail_page.dart';
import '../../features/queue/presentation/pages/queue_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/shell/shell_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  debugLogDiagnostics: false,
  routes: [
    // ── Auth ──────────────────────────────────────────────────────────────
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => const NoTransitionPage(child: LoginPage()),
    ),

    // ── Main App Shell (bottom nav) ───────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => ShellPage(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(child: HomePage()),
        ),
        GoRoute(
          path: '/search',
          pageBuilder: (context, state) => const NoTransitionPage(child: SearchPage()),
        ),
        GoRoute(
          path: '/queue',
          pageBuilder: (context, state) => const NoTransitionPage(child: QueuePage()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => const NoTransitionPage(child: ProfilePage()),
        ),
        // "/new" tab — shows the choice page inline in the shell
        GoRoute(
          path: '/new',
          pageBuilder: (context, state) => const NoTransitionPage(child: _NewChooserPage()),
        ),
      ],
    ),

    // ── Traffic Offense flow (full-screen, no shell) ──────────────────────
    GoRoute(
      path: '/offense/new',
      builder: (context, state) => const NewTrafficOffensePage(),
    ),
    GoRoute(
      path: '/offense/review',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return ReviewConfirmPage(data: data);
      },
    ),
    GoRoute(
      path: '/offense/prn-issued',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return PrnIssuedPage(data: data);
      },
    ),

    // ── Service Fee flow (full-screen, no shell) ──────────────────────────
    GoRoute(
      path: '/service-fee/new',
      builder: (context, state) => const NewServiceFeePage(),
    ),

    // ── Transaction detail (full-screen, no shell) ────────────────────────
    GoRoute(
      path: '/transaction/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return TransactionDetailPage(transactionId: id);
      },
    ),
  ],
);

// ── New Chooser Page ──────────────────────────────────────────────────────────
// Embedded in the shell so the bottom nav stays visible while choosing.

class _NewChooserPage extends StatelessWidget {
  const _NewChooserPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New PRN'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ChoiceCard(
              icon: Icons.traffic_rounded,
              title: 'Traffic Offense',
              subtitle: 'Issue a PRN for a road traffic offense',
              color: const Color(0xFF1A3C5E),
              onTap: () => context.push('/offense/new'),
            ),
            const SizedBox(height: 16),
            _ChoiceCard(
              icon: Icons.receipt_long_rounded,
              title: 'Service Fee',
              subtitle: 'Issue a PRN for a police service request',
              color: const Color(0xFFE8A020),
              onTap: () => context.push('/service-fee/new'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.25)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF5A6478))),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

