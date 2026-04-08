import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hilite/widgets/snackbars.dart';

void main() {
  testWidgets('CustomSnackBar can show and dismiss safely', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: SizedBox.shrink(),
        ),
      ),
    );

    CustomSnackBar.failure(message: 'Login failed');
    await tester.pump();

    expect(find.text('Login failed'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Login failed'), findsNothing);
  });
}
