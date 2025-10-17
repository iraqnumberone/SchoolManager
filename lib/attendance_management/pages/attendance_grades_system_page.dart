import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/app_config.dart';

class AttendanceGradesSystemPage extends StatefulWidget {
  const AttendanceGradesSystemPage({super.key});

  @override
  State<AttendanceGradesSystemPage> createState() => _AttendanceGradesSystemPageState();
}

class _AttendanceGradesSystemPageState extends State<AttendanceGradesSystemPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Tab controller for attendance/grades tabs
    _tabController = TabController(length: 2, vsync: this);

    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      appBar: AppBar(
        title: Text(
          'نظام الحضور والدرجات',
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppConfig.secondaryColor,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Text(
                'الحضور',
                style: GoogleFonts.cairo(
                  fontSize: AppConfig.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Tab(
              child: Text(
                'الدرجات',
                style: GoogleFonts.cairo(
                  fontSize: AppConfig.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAttendanceTab(),
            _buildGradesTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Show options for quick actions
          _showQuickActions(context);
        },
        backgroundColor: AppConfig.secondaryColor,
        foregroundColor: Colors.white,
        elevation: AppConfig.buttonElevation,
        icon: const Icon(Icons.add),
        label: Text(
          'إجراء سريع',
          style: GoogleFonts.cairo(
            fontSize: AppConfig.fontSizeMedium,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppConfig.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick stats cards
          Row(
            children: [
              _buildStatCard(
                'الحاضرون اليوم',
                '45',
                Icons.check_circle,
                AppConfig.successColor,
              ),
              const SizedBox(width: AppConfig.spacingMD),
              _buildStatCard(
                'الغائبون',
                '3',
                Icons.cancel,
                AppConfig.errorColor,
              ),
            ],
          ),

          const SizedBox(height: AppConfig.spacingLG),

          // Class selection
          Container(
            padding: const EdgeInsets.all(AppConfig.spacingMD),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اختر الفصل',
                  style: GoogleFonts.cairo(
                    fontSize: AppConfig.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConfig.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppConfig.spacingMD),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppConfig.surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(AppConfig.spacingMD),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'class1', child: Text('الصف الأول')),
                    DropdownMenuItem(value: 'class2', child: Text('الصف الثاني')),
                    DropdownMenuItem(value: 'class3', child: Text('الصف الثالث')),
                  ],
                  onChanged: (value) {},
                  hint: Text(
                    'اختر الفصل الدراسي',
                    style: GoogleFonts.cairo(
                      color: AppConfig.textSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConfig.spacingLG),

          // Students list for attendance
          Container(
            padding: const EdgeInsets.all(AppConfig.spacingMD),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'قائمة الطلاب',
                  style: GoogleFonts.cairo(
                    fontSize: AppConfig.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConfig.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppConfig.spacingMD),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return _buildStudentAttendanceItem(index);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConfig.spacingLG),

          // Submit attendance button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.successColor,
                foregroundColor: Colors.white,
                elevation: AppConfig.buttonElevation,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConfig.spacingLG,
                  vertical: AppConfig.spacingMD,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                ),
              ),
              icon: const Icon(Icons.save),
              label: Text(
                'حفظ سجل الحضور',
                style: GoogleFonts.cairo(
                  fontSize: AppConfig.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradesTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppConfig.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick stats cards
          Row(
            children: [
              _buildStatCard(
                'المقررات',
                '8',
                Icons.book,
                AppConfig.primaryColor,
              ),
              const SizedBox(width: AppConfig.spacingMD),
              _buildStatCard(
                'الطلاب',
                '120',
                Icons.people,
                AppConfig.infoColor,
              ),
            ],
          ),

          const SizedBox(height: AppConfig.spacingLG),

          // Subject selection
          Container(
            padding: const EdgeInsets.all(AppConfig.spacingMD),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اختر المقرر',
                  style: GoogleFonts.cairo(
                    fontSize: AppConfig.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConfig.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppConfig.spacingMD),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppConfig.surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(AppConfig.spacingMD),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'math', child: Text('الرياضيات')),
                    DropdownMenuItem(value: 'arabic', child: Text('العربية')),
                    DropdownMenuItem(value: 'english', child: Text('الإنجليزية')),
                    DropdownMenuItem(value: 'science', child: Text('العلوم')),
                  ],
                  onChanged: (value) {},
                  hint: Text(
                    'اختر المقرر الدراسي',
                    style: GoogleFonts.cairo(
                      color: AppConfig.textSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConfig.spacingLG),

          // Students grades list
          Container(
            padding: const EdgeInsets.all(AppConfig.spacingMD),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'درجات الطلاب',
                  style: GoogleFonts.cairo(
                    fontSize: AppConfig.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConfig.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppConfig.spacingMD),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return _buildStudentGradeItem(index);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConfig.spacingLG),

          // Submit grades button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.primaryColor,
                foregroundColor: Colors.white,
                elevation: AppConfig.buttonElevation,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConfig.spacingLG,
                  vertical: AppConfig.spacingMD,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                ),
              ),
              icon: const Icon(Icons.save),
              label: Text(
                'حفظ الدرجات',
                style: GoogleFonts.cairo(
                  fontSize: AppConfig.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppConfig.spacingMD),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
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
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: AppConfig.fontSizeSmall,
                color: AppConfig.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentAttendanceItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConfig.spacingSM),
      padding: const EdgeInsets.all(AppConfig.spacingMD),
      decoration: BoxDecoration(
        color: AppConfig.surfaceColor,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppConfig.primaryColor.withValues(alpha: 0.1),
            child: Text(
              '${index + 1}',
              style: GoogleFonts.cairo(
                color: AppConfig.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppConfig.spacingMD),
          Expanded(
            child: Text(
              'الطالب ${index + 1}',
              style: GoogleFonts.cairo(
                fontSize: AppConfig.fontSizeMedium,
                color: AppConfig.textPrimaryColor,
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.check_circle,
                  color: AppConfig.successColor,
                ),
                tooltip: 'حاضر',
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.cancel,
                  color: AppConfig.errorColor,
                ),
                tooltip: 'غائب',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentGradeItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConfig.spacingSM),
      padding: const EdgeInsets.all(AppConfig.spacingMD),
      decoration: BoxDecoration(
        color: AppConfig.surfaceColor,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppConfig.primaryColor.withValues(alpha: 0.1),
            child: Text(
              '${index + 1}',
              style: GoogleFonts.cairo(
                color: AppConfig.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppConfig.spacingMD),
          Expanded(
            child: Text(
              'الطالب ${index + 1}',
              style: GoogleFonts.cairo(
                fontSize: AppConfig.fontSizeMedium,
                color: AppConfig.textPrimaryColor,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'الدرجة',
                hintStyle: GoogleFonts.cairo(
                  color: AppConfig.textSecondaryColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConfig.spacingSM,
                  vertical: AppConfig.spacingSM,
                ),
              ),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConfig.borderRadius * 2),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppConfig.spacingLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'إجراءات سريعة',
                style: GoogleFonts.cairo(
                  fontSize: AppConfig.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: AppConfig.textPrimaryColor,
                ),
              ),
              const SizedBox(height: AppConfig.spacingLG),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to attendance tab
                        _tabController.animateTo(0);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.successColor,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check_circle),
                      label: Text(
                        'تسجيل حضور',
                        style: GoogleFonts.cairo(
                          fontSize: AppConfig.fontSizeMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConfig.spacingMD),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to grades tab
                        _tabController.animateTo(1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.grade),
                      label: Text(
                        'إدخال درجات',
                        style: GoogleFonts.cairo(
                          fontSize: AppConfig.fontSizeMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
