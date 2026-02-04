import "package:flutter/material.dart";

class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Semantics(
          label: "Home placeholder screen",
          child: const Text("Home Screen Placeholder"),
        ),
      ),
    );
  }
}
