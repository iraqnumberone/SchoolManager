import 'package:flutter/material.dart';

class AppConfig {
  // معلومات التطبيق الأساسية
  static const String appName = 'تطبيق المدرسة الذكية';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'نظام إدارة تعليمي متطور وشامل';

  // لوحة الألوان الأساسية - ألوان احترافية ومتناسقة حسب المواصفات
  static const Color primaryColor = Color(0xFF4A90E2);     // أزرق هادئ احترافي
  static const Color primaryLight = Color(0xFF6BA3E8);    // أزرق فاتح
  static const Color primaryDark = Color(0xFF2E7BD1);     // أزرق داكن

  static const Color secondaryColor = Color(0xFF50E3C2);   // أخضر مائي احترافي
  static const Color secondaryLight = Color(0xFF6EE8D1);  // أخضر مائي فاتح
  static const Color secondaryDark = Color(0xFF3AD4B3);   // أخضر مائي داكن

  // ألوان الحالات والحالة حسب المواصفات
  static const Color successColor = Color(0xFF7ED321);     // أخضر فاتح للنجاح/متميز
  static const Color warningColor = Color(0xFFF5A623);    // برتقالي للتحذير/متوسط
  static const Color errorColor = Color(0xFFD0021B);       // أحمر للخطر/رسوب
  static const Color infoColor = Color(0xFF50A6E3);        // أزرق فاتح للمعلومات/إجازة

  // ألوان حالات الحضور حسب المواصفات
  static const Color absentColor = Color(0xFFF8E71C);      // أصفر فاتح للغياب
  static const Color excusedColor = Color(0xFF50A6E3);    // أزرق فاتح للإجازة
  static const Color presentColor = Color(0xFF7ED321);     // أخضر فاتح للحضور
  static const Color lateColor = Color(0xFFF5A623);        // برتقالي للتأخير

  // ألوان الخلفية والسطح
  static const Color backgroundColor = Color(0xFFF4F4F4); // رمادي فاتح جداً
  static const Color surfaceColor = Color(0xFFFFFFFF);    // أبيض نقي
  static const Color cardColor = Color(0xFFFFFFFF);       // أبيض للبطاقات

  // ألوان النصوص
  static const Color textPrimaryColor = Color(0xFF4A4A4A); // رمادي داكن للنصوص الرئيسية
  static const Color textSecondaryColor = Color(0xFF6B7280); // رمادي متوسط للنصوص الثانوية
  static const Color textLightColor = Color(0xFF9CA3AF);  // رمادي فاتح للنصوص الخفيفة

  // ألوان الحدود والفواصل
  static const Color borderColor = Color(0xFFE5E7EB);     // رمادي فاتح للحدود
  static const Color dividerColor = Color(0xFFF3F4F6);    // رمادي فاتح جداً للفواصل

  // ألوان الوضع الداكن
  static const Color darkBackgroundColor = Color(0xFF1A1A1A); // أسود داكن
  static const Color darkSurfaceColor = Color(0xFF2D2D2D);   // رمادي داكن
  static const Color darkCardColor = Color(0xFF3A3A3A);      // رمادي متوسط داكن

  // إعدادات التطبيق
  static const bool enableDarkMode = true;
  static const bool enableNotifications = true;
  static const bool enableBiometricAuth = false;
  static const bool enableAnimations = true;

  // قواعد البيانات
  static const String databaseName = 'school_app.db';
  static const int databaseVersion = 1;

  // إعدادات الشبكة
  static const String apiBaseUrl = 'https://api.schoolapp.com/';
  static const Duration connectionTimeout = Duration(seconds: 30);

  // إعدادات التخزين المحلي
  static const String prefsKey = 'school_app_prefs';
  static const String userTokenKey = 'user_token';
  static const String userRoleKey = 'user_role';
  static const String schoolIdKey = 'school_id';
  static const String themeModeKey = 'theme_mode';
  static const String languageKey = 'language';

  // أدوار المستخدمين
  static const String roleAdmin = 'admin';
  static const String roleTeacher = 'teacher';
  static const String roleSupervisor = 'supervisor';
  static const String roleStudent = 'student';

  // حالات الطالب
  static const String studentStatusActive = 'active';
  static const String studentStatusInactive = 'inactive';
  static const String studentStatusGraduated = 'graduated';
  static const String studentStatusSuspended = 'suspended';

  // أنواع الحضور
  static const String attendancePresent = 'present';
  static const String attendanceAbsent = 'absent';
  static const String attendanceExcused = 'excused';
  static const String attendanceLate = 'late';

  // مستويات الأداء
  static const String performanceExcellent = 'excellent';
  static const String performanceGood = 'good';
  static const String performanceAverage = 'average';
  static const String performanceWeak = 'weak';

  // إعدادات الرسوم البيانية
  static const double chartAnimationDuration = 1.5; // ثواني
  static const double cardElevation = 4.0;
  static const double buttonElevation = 2.0;
  static const double borderRadius = 16.0;

  // إعدادات الخطوط
  static const String primaryFont = 'Cairo';
  static const String secondaryFont = 'Inter';
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 24.0;
  static const double fontSizeXXXLarge = 32.0;

  // إعدادات التباعد
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
}
