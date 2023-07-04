import 'package:auto_route/auto_route.dart';
import 'package:example/pages/page_1.dart';
import 'package:example/pages/page_2.dart';
import 'package:example/pages/page_3.dart';
import 'package:example/pages/page_4.dart';
import 'package:example/pages/page_5.dart';
import 'package:example/tabs_page.dart';
import 'package:flutter/material.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(
  replaceInRouteName: 'Page,Route',
)
class AppRouter extends _$AppRouter {

  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  final List<AutoRoute> routes = [
    AutoRoute(
      page: TabsRoute.page,
      path: '/',
      children: [
        AutoRoute(page: FirstRoute.page),
        AutoRoute(page: SecondRoute.page),
        AutoRoute(page: ThirdRoute.page, initial: true),
        AutoRoute(page: FourthRoute.page),
        AutoRoute(page: FifthRoute.page),
      ],
    ),
  ];
}
