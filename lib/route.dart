import 'package:flutter/material.dart';
import 'package:task/screens/home.dart';
import 'package:task/screens/onboarding.dart';
import 'package:task/screens/splash_screen.dart';
import 'package:task/screens/tasks_screen.dart';
import 'package:task/screens/profile_screen.dart';

class Routes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register'; 
  static const String home = '/home';
  static const String tasks = '/tasks';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      Routes.splash: (context) => const SplashScreen(),
      Routes.onboarding: (context) => const OnboardingScreen(),
      Routes.home: (context) => const HomeScreen(),
      Routes.tasks: (context) => const TasksScreen(),
      Routes.profile: (context) => const ProfileScreen(),
    };
  }
}