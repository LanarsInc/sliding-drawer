import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class FirstPage extends StatelessWidget {
  const FirstPage({
    super.key,
    required this.onMenuPressed,
  });

  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Page 1'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onMenuPressed,
              child: Text('Open menu'),
            ),
          ],
        ),
      ),
    );
  }
}
