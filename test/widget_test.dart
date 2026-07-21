import 'package:client/l10n/app_localizations.dart';
import 'package:client/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('GitPetApp configures localization and app themes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GitPetApp());

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app.theme, isNotNull);
    expect(app.darkTheme, isNotNull);
    expect(app.themeMode, ThemeMode.system);
    expect(app.localizationsDelegates, AppLocalizations.localizationsDelegates);
    expect(app.supportedLocales, AppLocalizations.supportedLocales);
  });
}
