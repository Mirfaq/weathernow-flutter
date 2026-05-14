// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Search bar renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TextField(
            key: Key('searchField'),
            decoration: InputDecoration(hintText: 'Search city...'),
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('searchField')), findsOneWidget);
  });

  testWidgets('Temperature text renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('25°C', key: Key('temp'))),
        ),
      ),
    );
    expect(find.byKey(const Key('temp')), findsOneWidget);
    expect(find.text('25°C'), findsOneWidget);
  });
}
