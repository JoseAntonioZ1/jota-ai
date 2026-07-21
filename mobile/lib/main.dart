import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: JotaApp()));
}

class JotaApp extends StatelessWidget {
  const JotaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'JOTA AI',
      theme: AppTheme.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
