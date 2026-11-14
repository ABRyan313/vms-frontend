import 'package:flutter_test/flutter_test.dart';
import 'package:vms_frontend/main.dart';

void main() {
  testWidgets('VmsApp smoke test - verifies initial login screen load',
      (WidgetTester tester) async {
    await tester.pumpWidget(const VmsApp());
    await tester.pumpAndSettle();

    // Verify that the login screen elements are rendered
    expect(find.text('Sign In to VMS Portal'), findsOneWidget);
    expect(find.text('Quick Fill Demo Admin'), findsOneWidget);
  });
}
