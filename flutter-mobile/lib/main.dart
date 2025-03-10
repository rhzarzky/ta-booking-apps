import 'package:Appointly/core/common/main_tab_screen.dart';
import 'package:Appointly/module/auth/presentation/bloc/auth_bloc.dart';
import 'package:Appointly/module/auth/presentation/screen/auth_signIn.dart';
import 'package:Appointly/module/auth/repository/auth_repository.dart';
import 'package:Appointly/module/meetings/presentation/bloc/service_bloc.dart';
import 'package:Appointly/module/meetings/repository/service_repository.dart';
import 'package:Appointly/module/onboarding/presentation/screen/onboarding_screen.dart';
import 'package:Appointly/module/onboarding/repository/onboarding_repository.dart';// Import ServiceBloc
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool showOnboarding = true;
  String? token;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final onBoardingRepo = OnboardingRepository();
    final isOnboardingComplete = await onBoardingRepo.isOnboardingComplete();
    setState(() {
      showOnboarding = !isOnboardingComplete;
    });
  }

  void completeOnboarding() async {
    final onboardingRepo = OnboardingRepository();
    await onboardingRepo.completeOnboarding();
    setState(() {
      showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ServiceBloc(
            serviceRepository: ServiceRepository(),
          ),
        ),
        BlocProvider(
          create: (context) => AuthBloc(
            AuthRepository(),
            context.read<ServiceBloc>(), // Pastikan ServiceBloc sudah ada
          )..add(CheckAuthStatus()),
        ),
      ],
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
