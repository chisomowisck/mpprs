import 'package:flutter_test/flutter_test.dart';
import 'package:mpprs/main.dart';

void main() {
  testWidgets('MPPRS app smoke test — login page renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MpprsApp());
    await tester.pumpAndSettle();
    expect(find.text('Officer Sign In'), findsOneWidget);
  });
}
