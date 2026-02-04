import "package:flutter_test/flutter_test.dart";
import "package:get/get.dart";
import "package:flutter/material.dart";
import "package:frontend/screens/splash_screen.dart";

void main() {
  testWidgets("Splash screen renders", (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: SplashScreen(skipAuthCheck: true),
      ),
    );

    expect(find.text("G Library"), findsOneWidget);
  });
}
