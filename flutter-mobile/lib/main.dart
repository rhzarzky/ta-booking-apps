import 'dart:convert';
import 'package:Appointly/core/common/main_tab_screen.dart';
import 'package:Appointly/module/auth/presentation/bloc/auth_bloc.dart';
import 'package:Appointly/module/auth/presentation/screen/auth_signIn.dart';
import 'package:Appointly/module/auth/repository/auth_repository.dart';
import 'package:Appointly/module/meetings/presentation/bloc/booking_bloc.dart';
import 'package:Appointly/module/meetings/presentation/bloc/service_bloc.dart';
import 'package:Appointly/module/meetings/presentation/screen/detail_meeting_success.dart';
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
import 'package:Appointly/module/meetings/presentation/bloc/map_bloc.dart';
import 'package:Appointly/module/meetings/repository/map_repository.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse details) {
      _handleNotification(details.payload);
    },
  );

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

void _handleNotification(String? payload) {
  if (payload != null) {
    try {
      final data = jsonDecode(payload);

      if (data['type'] == 'booking' && data['bookingId'] != null) {
        final int bookingId = data['bookingId'] is int
            ? data['bookingId']
            : int.tryParse(data['bookingId'].toString()) ?? 0;

        if (bookingId > 0) {
          // Tunggu navigasi siap
          Future.delayed(Duration(milliseconds: 500), () {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) =>
                    DetailMeetingSuccess(bookingId: bookingId),
              ),
            );
          });
        }
      }
    } catch (e) {
      print('Error parsing notification payload: $e');
    }
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool isOnboardingCompleted = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final onBoardingRepo = OnboardingRepository();
    await onBoardingRepo.resetOnboarding();

    final isComplete = await onBoardingRepo.isOnboardingComplete();

    setState(() {
      isOnboardingCompleted = isComplete;
      isLoading = false;
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
        BlocProvider<MapBloc>(
          create: (context) => MapBloc(
            mapRepository: MapRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        home: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildHomeScreen(),
      ),
    );
  }

  Widget _buildHomeScreen() {
    if (!isOnboardingCompleted) {
      return OnboardingScreen(
        onComplete: () {
          setState(() {
            isOnboardingCompleted = true;
          });
        },
      );
    } else {
      return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return const MainTabScreen();
          } else {
            return const AuthSignin();
          }
        },
      );
    }
  }
}
