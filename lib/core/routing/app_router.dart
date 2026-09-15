import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../screens/alerts/alert_center_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/finance/finance_screen.dart';
import '../../screens/finance/transaction_detail_screen.dart';
import '../../screens/finance/transaction_form_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/reports/reports_screen.dart';
import '../../screens/settings/alerts_settings_screen.dart';
import '../../screens/settings/appearance_screen.dart';
import '../../screens/settings/categories_settings_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/tasks/task_form_screen.dart';
import '../../screens/tasks/tasks_screen.dart';
import '../../widgets/common/floating_nav_bar.dart';
import '../../widgets/common/quick_action_button.dart';

class _NoTransitionPage<T> extends CustomTransitionPage<T> {
  _NoTransitionPage({required super.child, required super.key})
      : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
        );
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/dashboard',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => _AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/dashboard',
              pageBuilder: (context, state) =>
                  _NoTransitionPage(key: state.pageKey, child: const DashboardScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/tasks',
              pageBuilder: (context, state) =>
                  _NoTransitionPage(key: state.pageKey, child: const TasksScreen()),
              routes: [
                GoRoute(
                  path: 'new',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) => const TaskFormScreen(),
                ),
                GoRoute(
                  path: ':id/edit',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) =>
                      TaskFormScreen(taskId: state.pathParameters['id']),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/finance',
              pageBuilder: (context, state) =>
                  _NoTransitionPage(key: state.pageKey, child: const FinanceScreen()),
              routes: [
                GoRoute(
                  path: 'new-income',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) =>
                      const TransactionFormScreen(isIncome: true),
                ),
                GoRoute(
                  path: 'new-expense',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) =>
                      const TransactionFormScreen(isIncome: false),
                ),
                GoRoute(
                  path: ':id',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) =>
                      TransactionDetailScreen(transactionId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: ':id/edit',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) => TransactionFormScreen(
                    isIncome: true,
                    transactionId: state.pathParameters['id'],
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/reports',
              pageBuilder: (context, state) =>
                  _NoTransitionPage(key: state.pageKey, child: const ReportsScreen()),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'appearance',
            builder: (context, state) => const AppearanceScreen(),
          ),
          GoRoute(
            path: 'categories',
            builder: (context, state) => const CategoriesSettingsScreen(),
          ),
          GoRoute(
            path: 'alerts',
            builder: (context, state) => const AlertsSettingsScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/alert-center',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AlertCenterScreen(),
      ),
    ],
  );
});

class _AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _AppShell({required this.navigationShell});

  void _openQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ação rápida', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  QuickActionButton(
                    icon: CupertinoIcons.add_circled,
                    label: 'Tarefa',
                    color: const Color(0xFF0F4C81),
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push('/tasks/new');
                    },
                  ),
                  QuickActionButton(
                    icon: CupertinoIcons.minus_circle_fill,
                    label: 'Gasto',
                    color: const Color(0xFFD64545),
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push('/finance/new-expense');
                    },
                  ),
                  QuickActionButton(
                    icon: CupertinoIcons.plus_circle_fill,
                    label: 'Entrada',
                    color: const Color(0xFF2E9E5B),
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push('/finance/new-income');
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: FloatingNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        onFabTap: () => _openQuickActions(context),
      ),
    );
  }
}
