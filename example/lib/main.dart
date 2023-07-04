import 'package:auto_route/auto_route.dart';
import 'package:example/app_router.dart';
import 'package:flutter/material.dart';

final _router = AppRouter();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerDelegate: AutoRouterDelegate(_router),
      routeInformationParser: _router.defaultRouteParser(),
    );
  }
}
