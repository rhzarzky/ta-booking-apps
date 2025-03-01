import 'package:appointly/module/auth/presentation/bloc/auth_bloc.dart';
import 'package:appointly/module/auth/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appointly/core/common/main_tab_screen.dart';
import 'package:appointly/module/onboarding/presentation/screen/onboarding_screen.dart';
import 'package:appointly/module/auth/presentation/screen/auth_signin.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool showOnboarding = true;

  void completeOnboarding() {
    setState(() {
      showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(AuthRepository())..add(CheckAuthStatus()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (showOnboarding) {
              return OnboardingScreen(onComplete: completeOnboarding);
            } else if (state is AuthAuthenticated) {
              return const MainTabScreen();
            } else {
              return const AuthSignin();
            }
          },
        ),
      ),
    );
  }
}
