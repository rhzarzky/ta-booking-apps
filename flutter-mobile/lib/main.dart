import 'package:Appointly/core/common/main_tab_screen.dart';
import 'package:Appointly/module/auth/presentation/bloc/auth_bloc.dart';
import 'package:Appointly/module/auth/presentation/screen/auth_signIn.dart';
import 'package:Appointly/module/auth/repository/auth_repository.dart';
import 'package:Appointly/module/meetings/presentation/bloc/booking_bloc.dart';
import 'package:Appointly/module/meetings/presentation/bloc/service_bloc.dart';
import 'package:Appointly/module/meetings/repository/historyBooking_repository.dart';
import 'package:Appointly/module/meetings/repository/service_repository.dart';
import 'package:Appointly/module/onboarding/presentation/screen/onboarding_screen.dart';
import 'package:Appointly/module/onboarding/repository/onboarding_repository.dart';
import 'package:Appointly/module/notification/presentation/bloc/notification_bloc.dart';
import 'package:Appointly/module/profile/presentation/bloc/profile_bloc.dart';
import 'package:Appointly/module/profile/repository/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Create the notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'appointly_channel',
    'Appointly Notifications',
    importance: Importance.max,
    playSound: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

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
            context.read<ServiceBloc>(),
          )..add(CheckAuthStatus()),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(),
        ),
        BlocProvider(
          create: (context) => BookingBloc(
            historybookingRepository: HistorybookingRepository(),
          ),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(
            profileRepository: ProfileRepository(),
          ),
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
