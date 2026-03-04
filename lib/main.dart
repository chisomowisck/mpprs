import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/dashboard/presentation/cubit/dashboard_prefs_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation for field device usage
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar: transparent with dark icons
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const MpprsApp());
}

class MpprsApp extends StatelessWidget {
  const MpprsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => DashboardPrefsCubit()),
      ],
      child: MaterialApp.router(
        title: 'MPPRS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}
