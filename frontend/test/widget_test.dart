import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoconnect/main.dart';

void main() {
  testWidgets('EcoConnect smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EcoConnectApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
