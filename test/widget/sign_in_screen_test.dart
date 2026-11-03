import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/auth/presentation/sign_in_screen.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_auth_repository.dart';

Widget _host(FakeAuthRepository repository) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('en'),
      home: SignInScreen(),
    ),
  );
}

void _useLargeScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('empty form shows required errors and does not call sign in', (
    tester,
  ) async {
    _useLargeScreen(tester);
    final repository = FakeAuthRepository();
    await tester.pumpWidget(_host(repository));

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('This field is required'), findsNWidgets(2));
    expect(repository.signInCalls, 0);
  });

  testWidgets('invalid email shows a validation message', (tester) async {
    _useLargeScreen(tester);
    final repository = FakeAuthRepository();
    await tester.pumpWidget(_host(repository));

    await tester.enterText(find.byKey(const Key('email_field')), 'abc');
    await tester.enterText(find.byKey(const Key('password_field')), '123456');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(repository.signInCalls, 0);
  });

  testWidgets('valid form signs in with the trimmed email', (tester) async {
    _useLargeScreen(tester);
    final repository = FakeAuthRepository();
    await tester.pumpWidget(_host(repository));

    await tester.enterText(
      find.byKey(const Key('email_field')),
      '  owner@shop.com  ',
    );
    await tester.enterText(find.byKey(const Key('password_field')), 'secret1');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(repository.signInCalls, 1);
    expect(repository.lastEmail, 'owner@shop.com');
    expect(repository.lastPassword, 'secret1');
  });

  testWidgets('failed sign in shows the error and keeps what was typed', (
    tester,
  ) async {
    _useLargeScreen(tester);
    final repository = FakeAuthRepository(
      signInError: const AppException(AppErrorType.invalidCredentials),
    );
    await tester.pumpWidget(_host(repository));

    await tester.enterText(
      find.byKey(const Key('email_field')),
      'owner@shop.com',
    );
    await tester.enterText(find.byKey(const Key('password_field')), 'wrong99');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Incorrect email or password.'), findsOneWidget);
    expect(find.text('owner@shop.com'), findsOneWidget);
  });
}
