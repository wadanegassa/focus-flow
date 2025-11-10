import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task/route.dart';
import 'package:task/services/theme_service.dart';
import 'package:task/services/task_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final TaskService _taskService;

  @override
  void initState() {
    super.initState();
    _taskService = TaskService();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider.value(value: _taskService),
      ],
      child: Builder(
        builder: (context) {
          // Load tasks after providers are set up
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<TaskService>().loadTasks();
          });

          return Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return MaterialApp(
                title: 'Focus Flow',
                debugShowCheckedModeBanner: false,
                theme: themeService.lightTheme,
                darkTheme: themeService.darkTheme,
                themeMode: themeService.themeMode,
                initialRoute: '/',
                routes: Routes.getRoutes(),
              );
            },
          );
        },
      ),
    );
  }
}
