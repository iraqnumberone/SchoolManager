import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:school_app/core/app_config.dart';
import 'package:school_app/ui/app_theme.dart';
import 'package:school_app/features/school/pages/smart_teacher_home.dart';

void main() {
  // Configure logging
  Logger.root.level = Level.ALL; // Set the minimum logging level
  Logger.root.onRecord.listen((record) {
    // You can customize the log output format here
    final message = '${record.level.name}: ${record.time}: ${record.message}';
    if (record.error != null) {
      debugPrint('$message\n${record.error}');
      if (record.stackTrace != null) {
        debugPrint(record.stackTrace.toString());
      }
    } else {
      debugPrint(message);
    }
  });
  
  // Log app startup
  final logger = Logger('main');
  logger.info('Starting ${AppConfig.appName}...');
  runApp(const SmartTeacherApp());
}

class SmartTeacherApp extends StatelessWidget {
  const SmartTeacherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // إعدادات النص للعربية
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },

      home: const SmartTeacherHomePage(),
    );
  }
}
