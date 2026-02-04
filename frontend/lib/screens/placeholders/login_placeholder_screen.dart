import "package:flutter/material.dart";

class LoginPlaceholderScreen extends StatelessWidget {
  const LoginPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Semantics(
          label: "Login placeholder screen",
          child: const Text("Login Screen Placeholder"),
        ),
      ),
    );
  }
}
