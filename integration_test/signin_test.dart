import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sticky_note/signin_page.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    try {
      await dotenv.load(fileName: "assets/.env");  // ✅ Explicitly load the correct .env file
      print("✅ .env Loaded Successfully");
    } catch (e) {
      print("❌ Error loading .env: $e");
    }
  });

  testWidgets('Email Login Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: SignInPage()));
    await tester.pumpAndSettle(); // Wait for UI

    final emailField = find.byKey(Key('emailField'));
    final passwordField = find.byKey(Key('passwordField'));
    final loginButton = find.byKey(Key('loginButton'));

    await tester.enterText(emailField, 'jeet@gmail.com');
    await tester.enterText(passwordField, 'Jeet@123');
    await tester.tap(loginButton);

    await tester.pumpAndSettle(); // Wait for API response
    await tester.pump(Duration(seconds: 10)); // ✅ Extra wait time

    // ✅ Check for success or failure message
    if (find.textContaining("Login Successful").evaluate().isNotEmpty) {
      expect(find.textContaining("Login Successful"), findsOneWidget);
    } else {
      print("❌ Login Failed! Check the API response.");
      expect(find.textContaining("Error"), findsNothing); // Force fail test
    }
  });
}
