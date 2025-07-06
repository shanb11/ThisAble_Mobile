import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thisable_mobile/app.dart'; // CHANGED: import app.dart instead of main.dart

void main() {
  testWidgets('ThisAble app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ThisAbleApp());

    // Verify that our app loads correctly
    expect(find.text('ThisAble'), findsWidgets); // Updated expectation
    expect(
        find.text('STEP 5 COMPLETE!'), findsOneWidget); // Updated expectation

    // Verify that accessibility icon is present
    expect(find.byIcon(Icons.accessibility_new), findsOneWidget);
  });
}
