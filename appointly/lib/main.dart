import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appointly/core/common/main_tab_screen.dart';
import 'package:appointly/module/onboarding/presentation/screen/onboarding_screen.dart';
import 'package:appointly/module/auth/providers/auth_provider.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: showOnboarding
            ? OnboardingScreen(onComplete: completeOnboarding)
            : const MainTabScreen(),
      ),
    );
  }
}
