import 'package:flutter_test/flutter_test.dart';

import 'package:harder/main.dart';

void main() {
  testWidgets('affiche l ecran de landing', (WidgetTester tester) async {
    await tester.pumpWidget(const FitnessTrackerApp());

    expect(find.text('Commencer'), findsOneWidget);
  });
}
