import 'package:flutter/material.dart';
import 'package:school_app/core/app_config.dart';
import 'package:school_app/ui/app_theme.dart';
import 'package:school_app/features/school/pages/smart_teacher_home.dart';

void main() {
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
