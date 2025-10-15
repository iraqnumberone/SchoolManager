import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/app_config.dart';
import 'package:school_app/features/school/services/school_service.dart';
import 'package:school_app/school_management/pages/schools_list_page.dart';
import 'package:school_app/features/students/pages/students_list_page.dart';

class SmartTeacherHomePage extends StatefulWidget {
  const SmartTeacherHomePage({super.key});

  @override
  State<SmartTeacherHomePage> createState() => _SmartTeacherHomePageState();
}

class _SmartTeacherHomePageState extends State<SmartTeacherHomePage>
    with TickerProviderStateMixin {
  Map<String, dynamic> _schoolStats = {};
  bool _isLoading = true;
  int _currentIndex = 0; // مؤشر العنصر النشط في شريط التنقل السفلي

  @override
  void initState() {
    super.initState();

    _loadSchoolData();
  }

  Future<void> _loadSchoolData() async {
    setState(() {
      _isLoading = true;
    });

    // تهيئة البيانات التجريبية
    await SchoolService.initializeDemoData();

    // الحصول على إحصائيات المدرسة
    final stats = await SchoolService.getSchoolStats('school_1');

    setState(() {
      _schoolStats = stats;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      appBar: AppBar(
        title: Text(
          'مدرستي الذكية',
          style: GoogleFonts.cairo(
            fontSize: AppConfig.fontSizeXXLarge,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConfig.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // الانتقال إلى صفحة الإشعارات
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingView() : _buildMainContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // إجراء سريع - إضافة طالب جديد
        },
        backgroundColor: AppConfig.secondaryColor,
        foregroundColor: Colors.white,
        elevation: AppConfig.buttonElevation,
        icon: const Icon(Icons.person_add),
        label: Text(
          'إضافة طالب',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        ),
      ),
      drawer: _buildDrawer(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(color: AppConfig.primaryColor),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppConfig.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بطاقة الترحيب البسيطة
          _buildWelcomeCard(),

          const SizedBox(height: AppConfig.spacingXXL),

          // شبكة الإحصائيات البسيطة
          _buildStatsGrid(),

          const SizedBox(height: AppConfig.spacingXXL),

          // الإجراءات السريعة البسيطة
          _buildQuickActions(),

          const SizedBox(height: AppConfig.spacingXXL),

          // النشاطات الأخيرة البسيطة
          _buildRecentActivities(),

          const SizedBox(height: AppConfig.spacingXXL),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(AppConfig.spacingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppConfig.primaryColor, AppConfig.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppConfig.primaryColor.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.waving_hand_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: AppConfig.spacingSM),
              Text(
                'مرحباً بك في مدرستك الذكية!',
                style: GoogleFonts.cairo(
                  fontSize: AppConfig.fontSizeXLarge,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConfig.spacingSM),
          Text(
            'نظام إدارة تعليمي متطور وشامل للمدرسة',
            style: GoogleFonts.cairo(
              fontSize: AppConfig.fontSizeMedium,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppConfig.spacingMD),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConfig.spacingMD,
              vertical: AppConfig.spacingSM,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
            ),
            child: Text(
              'اليوم: ${DateTime.now().toString().split(' ')[0]}',
              style: GoogleFonts.cairo(
                fontSize: AppConfig.fontSizeMedium,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppConfig.spacingMD,
      mainAxisSpacing: AppConfig.spacingMD,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          'إجمالي الفصول',
          '${_schoolStats['totalClassrooms'] ?? 0}',
          Icons.school_outlined,
          AppConfig.primaryColor,
          'فصل دراسي',
        ),
        _buildStatCard(
          'عدد المعلمين',
          '${_schoolStats['totalTeachers'] ?? 0}',
          Icons.person_outline,
          AppConfig.secondaryColor,
          'معلم',
        ),
        _buildStatCard(
          'إجمالي الطلاب',
          '${_schoolStats['totalStudents'] ?? 0}',
          Icons.people_outline,
          AppConfig.successColor,
          'طالب',
        ),
        _buildStatCard(
          'معدل الحضور اليوم',
          '${(_schoolStats['attendanceRate'] ?? 0).toStringAsFixed(1)}%',
          Icons.trending_up_outlined,
          AppConfig.warningColor,
          'نسبة الحضور',
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConfig.spacingMD),
      decoration: BoxDecoration(
        color: AppConfig.cardColor,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppConfig.borderColor.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: AppConfig.spacingSM),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: AppConfig.fontSizeXXLarge,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: AppConfig.fontSizeMedium,
              color: AppConfig.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.cairo(
              fontSize: AppConfig.fontSizeSmall,
              color: AppConfig.textLightColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppConfig.spacingMD,
      mainAxisSpacing: AppConfig.spacingMD,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildQuickActionCard(
          'تسجيل الحضور',
          Icons.check_circle_outline,
          AppConfig.secondaryColor,
          () {
            // الانتقال إلى صفحة الحضور
          },
        ),
        _buildQuickActionCard(
          'إدخال الدرجات',
          Icons.grade_outlined,
          AppConfig.successColor,
          () {
            // الانتقال إلى صفحة الدرجات
          },
        ),
        _buildQuickActionCard(
          'إدارة الطلاب',
          Icons.people_outline,
          AppConfig.primaryColor,
          () {
            // الانتقال إلى صفحة الطلاب
          },
        ),
        _buildQuickActionCard(
          'عرض التقارير',
          Icons.analytics_outlined,
          AppConfig.warningColor,
          () {
            // الانتقال إلى صفحة التقارير
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppConfig.cardColor,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppConfig.borderColor.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppConfig.spacingMD),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConfig.spacingMD),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppConfig.borderRadius / 2,
                    ),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: AppConfig.spacingMD),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: AppConfig.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: AppConfig.textPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      children: [
        _buildActivityCard(
          'تم إضافة طالب جديد',
          'أحمد محمد علي - الصف الأول أ',
          'منذ ساعتين',
          Icons.person_add,
          AppConfig.successColor,
        ),
        _buildActivityCard(
          'تم تحديث جدول الحصص',
          'جدول حصص الرياضيات - الصف الثاني',
          'منذ 4 ساعات',
          Icons.schedule,
          AppConfig.infoColor,
        ),
        _buildActivityCard(
          'تم إرسال تقرير شهري',
          'تقرير أداء الطلاب لشهر أكتوبر',
          'منذ يوم واحد',
          Icons.analytics,
          AppConfig.warningColor,
        ),
      ],
    );
  }

  Widget _buildActivityCard(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConfig.spacingMD),
      padding: const EdgeInsets.all(AppConfig.spacingMD),
      decoration: BoxDecoration(
        color: AppConfig.cardColor,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppConfig.borderColor.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppConfig.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: AppConfig.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: AppConfig.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: AppConfig.fontSizeSmall,
                    color: AppConfig.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.cairo(
              fontSize: AppConfig.fontSizeSmall,
              color: AppConfig.textLightColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: AppConfig.surfaceColor,
        child: Column(
          children: [
            // رأس القائمة الجانبية
            Container(
              padding: const EdgeInsets.all(AppConfig.spacingLG),
              decoration: BoxDecoration(color: AppConfig.primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      'م',
                      style: GoogleFonts.cairo(
                        fontSize: AppConfig.fontSizeXLarge,
                        fontWeight: FontWeight.bold,
                        color: AppConfig.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConfig.spacingMD),
                  Text(
                    'مدرسة الرياض الذكية',
                    style: GoogleFonts.cairo(
                      fontSize: AppConfig.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'نظام إدارة تعليمي متطور',
                    style: GoogleFonts.cairo(
                      fontSize: AppConfig.fontSizeSmall,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            // عناصر القائمة الرئيسية
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConfig.spacingMD,
                ),
                children: [
                  _buildDrawerItem(
                    Icons.dashboard_outlined,
                    'لوحة التحكم',
                    () {
                      Navigator.of(context).pop();
                    },
                    color: AppConfig.primaryColor,
                  ),
                  _buildDrawerItem(Icons.school_outlined, 'إدارة المدرسة', () {
                    Navigator.of(context).pop();
                  }),
                  _buildDrawerItem(Icons.people_outline, 'إدارة الطلاب', () {
                    Navigator.of(context).pop();
                  }),
                  _buildDrawerItem(
                    Icons.check_circle_outline,
                    'الحضور والغياب',
                    () {
                      Navigator.of(context).pop();
                    },
                  ),
                  _buildDrawerItem(
                    Icons.analytics_outlined,
                    'التقارير والإحصائيات',
                    () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),

            // قسم الإعدادات والمساعدة
            Container(
              padding: const EdgeInsets.all(AppConfig.spacingMD),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppConfig.borderColor)),
              ),
              child: Column(
                children: [
                  _buildDrawerItem(Icons.settings_outlined, 'الإعدادات', () {
                    Navigator.of(context).pop();
                  }),
                  _buildDrawerItem(
                    Icons.logout_outlined,
                    'تسجيل الخروج',
                    () {
                      Navigator.of(context).pop();
                    },
                    color: AppConfig.errorColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConfig.spacingMD,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color != null
            ? color.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: color ?? AppConfig.textPrimaryColor,
          size: 28,
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            color: color ?? AppConfig.textPrimaryColor,
            fontSize: AppConfig.fontSizeLarge,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConfig.spacingLG,
          vertical: AppConfig.spacingSM,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppConfig.cardColor,
        boxShadow: [
          BoxShadow(
            color: AppConfig.borderColor.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(top: BorderSide(color: AppConfig.borderColor)),
      ),
      child: BottomNavigationBar(
        backgroundColor: AppConfig.cardColor,
        selectedItemColor: AppConfig.primaryColor,
        unselectedItemColor: AppConfig.textSecondaryColor,
        selectedFontSize: AppConfig.fontSizeSmall,
        unselectedFontSize: AppConfig.fontSizeSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConfig.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
              ),
              child: const Icon(Icons.dashboard, size: 20),
            ),
            label: 'لوحة التحكم',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConfig.secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
              ),
              child: const Icon(Icons.people, size: 20),
            ),
            label: 'الطلاب',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConfig.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
              ),
              child: const Icon(Icons.school, size: 20),
            ),
            label: 'المدرسة',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConfig.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
              ),
              child: const Icon(Icons.analytics, size: 20),
            ),
            label: 'التقارير',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConfig.infoColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
              ),
              child: const Icon(Icons.more_horiz, size: 20),
            ),
            label: 'المزيد',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // التعامل مع التنقل حسب العنصر المختار
          switch (index) {
            case 0:
              // لوحة التحكم - إعادة تحميل البيانات وعرض رسالة نجاح
              _reloadDashboardData();
              break;
            case 1:
              // إدارة الطلاب - الانتقال إلى صفحة الطلاب
              _navigateToStudentsPage();
              break;
            case 2:
              // إدارة المدرسة - الانتقال إلى صفحة المدرسة
              _navigateToSchoolPage();
              break;
            case 3:
              // التقارير والإحصائيات - الانتقال إلى صفحة التقارير
              _navigateToReportsPage();
              break;
            case 4:
              // فتح القائمة الجانبية للخيارات الأخرى
              Scaffold.of(context).openDrawer();
              break;
          }
        },
      ),
    );
  }

  void _reloadDashboardData() {
    // إعادة تحميل بيانات لوحة التحكم وعرض رسالة نجاح
    _showSuccessMessage('تم تحديث لوحة التحكم');
    _loadSchoolData(); // إعادة تحميل البيانات
  }

  void _navigateToStudentsPage() {
    // الانتقال إلى صفحة إدارة الطلاب وقائمة المدارس
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StudentsListPage(),
      ),
    );
  }

  void _navigateToSchoolPage() {
    // الانتقال إلى صفحة إدارة المدرسة وقائمة المدارس
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SchoolsListPage(),
      ),
    );
  }

  void _navigateToReportsPage() {
    // الانتقال إلى صفحة التقارير
    _showSuccessMessage('جاري التنقل إلى التقارير...');
    // هنا يمكن إضافة منطق الانتقال إلى صفحة التقارير
    // Navigator.push(context, MaterialPageRoute(builder: (context) => ReportsPage()));
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppConfig.successColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        ),
      ),
    );
  }
}
