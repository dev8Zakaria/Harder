import 'package:flutter_test/flutter_test.dart';

import 'package:harder/main.dart';

void main() {
  testWidgets('affiche l ecran de landing Harder', (WidgetTester tester) async {
    await tester.pumpWidget(const FitnessTrackerApp());

    expect(find.text('HARDER'), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);
  });
}
