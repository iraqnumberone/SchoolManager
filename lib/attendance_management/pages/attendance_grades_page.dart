import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/app_config.dart';
import 'package:school_app/attendance_management/pages/attendance_grades_system_page.dart';

class AttendanceGradesPage extends StatefulWidget {
  const AttendanceGradesPage({super.key});

  @override
  State<AttendanceGradesPage> createState() => _AttendanceGradesPageState();
}

class _AttendanceGradesPageState extends State<AttendanceGradesPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // متحكم تأثير الظهور التدريجي
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // تأثير الظهور التدريجي
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    // بدء التأثير
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      appBar: AppBar(
        title: Text(
          'الحضور والدرجات',
          style: GoogleFonts.cairo(
            fontSize: AppConfig.fontSizeXXLarge,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConfig.primaryColor,
        elevation: AppConfig.cardElevation,
        shadowColor: AppConfig.primaryColor.withValues(alpha: 0.3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppConfig.spacingMD),
          child: Column(
            children: [
              // البطاقة الرئيسية مع الأيقونة
              Container(
                padding: const EdgeInsets.all(AppConfig.spacingXXL),
                decoration: BoxDecoration(
                  color: AppConfig.cardColor,
                  borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: AppConfig.borderColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // الأيقونة الرئيسية
                    Container(
                      padding: const EdgeInsets.all(AppConfig.spacingLG),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppConfig.primaryColor,
                            AppConfig.secondaryColor
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppConfig.borderRadius * 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppConfig.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: Colors.white,
                        size: 80,
                      ),
                    ),

                    const SizedBox(height: AppConfig.spacingXXL),

                    // العنوان الرئيسي
                    Text(
                      'نظام الحضور والدرجات',
                      style: GoogleFonts.cairo(
                        fontSize: AppConfig.fontSizeXXLarge,
                        fontWeight: FontWeight.bold,
                        color: AppConfig.textPrimaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppConfig.spacingMD),

                    // الوصف
                    Text(
                      'إدارة شاملة ومتطورة للحضور والدرجات الدراسية',
                      style: GoogleFonts.cairo(
                        fontSize: AppConfig.fontSizeMedium,
                        color: AppConfig.textSecondaryColor,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppConfig.spacingXXL),

                    // شبكة الميزات
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppConfig.spacingMD,
                      mainAxisSpacing: AppConfig.spacingMD,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildFeatureCard(
                          'تسجيل الحضور',
                          'تسجيل حضور الطلاب بسهولة وسرعة',
                          Icons.check_circle_outline,
                          AppConfig.successColor,
                        ),
                        _buildFeatureCard(
                          'إدخال الدرجات',
                          'إدخال وتحديث درجات الطلاب',
                          Icons.grade_outlined,
                          AppConfig.primaryColor,
                        ),
                        _buildFeatureCard(
                          'التقارير التفصيلية',
                          'عرض تقارير شاملة للحضور والدرجات',
                          Icons.analytics_outlined,
                          AppConfig.warningColor,
                        ),
                        _buildFeatureCard(
                          'إشعارات ذكية',
                          'تلقي إشعارات فورية عن حالات الغياب',
                          Icons.notifications_outlined,
                          AppConfig.infoColor,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConfig.spacingXXL),

                    // زر البدء
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AttendanceGradesSystemPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.secondaryColor,
                        foregroundColor: Colors.white,
                        elevation: AppConfig.buttonElevation,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConfig.spacingXXL,
                          vertical: AppConfig.spacingLG,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConfig.borderRadius,
                          ),
                        ),
                        shadowColor: AppConfig.secondaryColor.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      icon: const Icon(Icons.start, size: 24),
                      label: Text(
                        'بدء استخدام النظام',
                        style: GoogleFonts.cairo(
                          fontSize: AppConfig.fontSizeLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConfig.spacingXXL),

              // بطاقة المعلومات الإضافية
              Container(
                padding: const EdgeInsets.all(AppConfig.spacingLG),
                decoration: BoxDecoration(
                  color: AppConfig.surfaceColor,
                  borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                  border: Border.all(
                    color: AppConfig.borderColor.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppConfig.infoColor,
                          size: 24,
                        ),
                        const SizedBox(width: AppConfig.spacingSM),
                        Text(
                          'معلومات مهمة',
                          style: GoogleFonts.cairo(
                            fontSize: AppConfig.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                            color: AppConfig.textPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConfig.spacingMD),
                    Text(
                      '• يمكنك الوصول إلى هذه الصفحة من القائمة الجانبية أو شريط التنقل السفلي\n'
                      '• النظام يدعم تتبع الحضور اليومي والدرجات الفصلية\n'
                      '• جميع البيانات محمية ومشفرة بالكامل\n'
                      '• يمكن تصدير التقارير بصيغ متعددة',
                      style: GoogleFonts.cairo(
                        fontSize: AppConfig.fontSizeMedium,
                        color: AppConfig.textSecondaryColor,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConfig.spacingXXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConfig.spacingMD),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConfig.spacingSM),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: AppConfig.spacingSM),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: AppConfig.fontSizeMedium,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.cairo(
              fontSize: AppConfig.fontSizeSmall,
              color: AppConfig.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
