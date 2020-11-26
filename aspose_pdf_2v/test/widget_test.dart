import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('finds a widget', (WidgetTester tester) async {
    final childWidget = Padding(padding: EdgeInsets.zero);
    await tester.pumpWidget(Container(child: childWidget));
    expect(find.byWidget(childWidget), findsOneWidget);
  });
}