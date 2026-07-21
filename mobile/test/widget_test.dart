import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jota_ai/main.dart';

void main() {
  testWidgets('JotaApp arranca y muestra la pantalla de onboarding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: JotaApp()));
    await tester.pumpAndSettle();

    expect(find.text('Configuracion inicial'), findsWidgets);
  });
}
