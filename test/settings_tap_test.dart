import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skycast_pro/app.dart';
import 'package:skycast_pro/presentation/screens/home_screen.dart';
import 'package:skycast_pro/presentation/routing/app_router.dart';

void main() {
  testWidgets('Settings tap test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: appRouter,
        ),
      ),
    );
    await tester.pumpAndSettle();

    appRouter.go('/home');
    await tester.pumpAndSettle();

    final settingsButton = find.text('Settings');
    expect(settingsButton, findsOneWidget);

    await tester.tap(settingsButton);
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsOneWidget);
  });
}
