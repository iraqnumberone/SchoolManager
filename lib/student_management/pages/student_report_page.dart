import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/app_config.dart';
import 'package:school_app/student_management/services/student_service.dart';

class StudentReportPage extends StatefulWidget {
  final String studentId;

  const StudentReportPage({super.key, required this.studentId});

  @override
  State<StudentReportPage> createState() => _StudentReportPageState();
}

class _StudentReportPageState extends State<StudentReportPage>
    with TickerProviderStateMixin {
  late Future<StudentReport> _reportFuture;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // تهيئة متحكمات التأثيرات
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // إعداد تأثيرات الظهور التدريجي
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // إعداد تأثير التكبير
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // بدء التحميل
    _loadReport();

    // بدء التأثيرات بعد تأخير قصير
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
      _scaleController.forward();
    });
  }

  late final StudentService _studentService = StudentService();

  void _loadReport() {
    _reportFuture = _studentService.generateStudentReport(widget.studentId);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: FutureBuilder<StudentReport>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingView();
          } else if (snapshot.hasError) {
            return _buildErrorView(snapshot.error.toString());
          } else if (snapshot.hasData) {
            return _buildReportView(snapshot.data!);
          } else {
            return _buildEmptyView();
          }
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'تقرير الطالب',
        style: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppConfig.primaryColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            // مشاركة التقرير
          },
        ),
        IconButton(
          icon: const Icon(Icons.print, color: Colors.white),
          onPressed: () {
            // طباعة التقرير
          },
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppConfig.primaryColor),
          ),
          const SizedBox(height: 20),
          Text(
            'جاري إعداد التقرير...',
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: AppConfig.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 20),
          Text(
            'حدث خطأ في إعداد التقرير',
            style: GoogleFonts.cairo(
              fontSize: 18,
              color: Colors.red[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            error,
            style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: Text(
              'إعادة المحاولة',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(child: Text('لا توجد بيانات متاحة'));
  }

  Widget _buildReportView(StudentReport report) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة معلومات الطالب
              _buildStudentInfoCard(report.student),

              const SizedBox(height: 20),

              // بطاقة التقييم العام
              _buildOverallEvaluationCard(report),

              const SizedBox(height: 20),

              // قسم الحضور
              _buildAttendanceSection(report),

              const SizedBox(height: 20),

              // قسم الدرجات
              _buildGradesSection(report),

              const SizedBox(height: 20),

              // قسم السجلات الأخيرة
              _buildRecentRecordsSection(report),

              const SizedBox(height: 80), // مساحة للزر العائم
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard(Student student) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConfig.primaryColor,
            AppConfig.primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConfig.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // صورة الطالب أو الأحرف الأولى
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                student.initials,
                style: GoogleFonts.cairo(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          // معلومات الطالب
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'رقم الطالب: ${student.studentId}',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  student.locationInfo,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${student.age} سنة',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallEvaluationCard(StudentReport report) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'التقييم العام',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${report.overallScore.toStringAsFixed(1)}%',
                    style: GoogleFonts.cairo(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: report.getEvaluationColor(),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: report.getEvaluationColor().withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  report.getEvaluationIcon(),
                  size: 40,
                  color: report.getEvaluationColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: report.getEvaluationColor().withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: report.getEvaluationColor().withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              report.evaluation,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: report.getEvaluationColor(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection(StudentReport report) {
    final attendanceStats = report.attendanceStats;
    final attendanceRate = report.attendanceRate;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppConfig.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'سجل الحضور',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // شريط نسبة الحضور
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: attendanceRate / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: attendanceRate >= 90
                            ? Colors.green
                            : attendanceRate >= 80
                            ? Colors.orange
                            : Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // إحصائيات مفصلة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAttendanceStat(
                      'الحضور',
                      '${attendanceStats['presentDays'] ?? 0}',
                      Colors.green,
                      Icons.check_circle,
                    ),
                    _buildAttendanceStat(
                      'الغياب',
                      '${attendanceStats['absentDays'] ?? 0}',
                      Colors.red,
                      Icons.cancel,
                    ),
                    _buildAttendanceStat(
                      'التأخير',
                      '${attendanceStats['lateDays'] ?? 0}',
                      Colors.orange,
                      Icons.schedule,
                    ),
                    _buildAttendanceStat(
                      'الإجمالي',
                      '${attendanceStats['totalDays'] ?? 0}',
                      AppConfig.primaryColor,
                      Icons.format_list_numbered,
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // نسبة الحضور كنص
                Center(
                  child: Text(
                    'نسبة الحضور: ${attendanceRate.toStringAsFixed(1)}%',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: attendanceRate >= 90
                          ? Colors.green
                          : attendanceRate >= 80
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAttendanceStat(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 5),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildGradesSection(StudentReport report) {
    final gradeStats = report.gradeStats;
    final gradeAverage = report.gradeAverage;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.grade, color: AppConfig.primaryColor, size: 24),
                const SizedBox(width: 10),
                Text(
                  'الأداء الدراسي',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // شريط متوسط الدرجات
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: gradeAverage / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue,
                            Colors.green,
                            Colors.orange,
                            Colors.red,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // إحصائيات الدرجات
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildGradeStat(
                      'المواد',
                      '${gradeStats['totalSubjects'] ?? 0}',
                      Colors.blue,
                      Icons.book,
                    ),
                    _buildGradeStat(
                      'الدرجات',
                      '${gradeStats['totalGrades'] ?? 0}',
                      Colors.purple,
                      Icons.assignment,
                    ),
                    _buildGradeStat(
                      'المتوسط',
                      '${gradeAverage.toStringAsFixed(1)}%',
                      gradeAverage >= 90
                          ? Colors.green
                          : gradeAverage >= 80
                          ? Colors.orange
                          : Colors.red,
                      Icons.analytics,
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // مستوى الأداء
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        gradeAverage >= 90
                            ? Icons.star
                            : gradeAverage >= 80
                            ? Icons.thumb_up
                            : Icons.info,
                        color: gradeAverage >= 90
                            ? Colors.green
                            : gradeAverage >= 80
                            ? Colors.orange
                            : Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        report.performanceLevel,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: gradeAverage >= 90
                              ? Colors.green
                              : gradeAverage >= 80
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGradeStat(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 5),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildRecentRecordsSection(StudentReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'السجلات الأخيرة',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),

        const SizedBox(height: 15),

        // سجلات الحضور الأخيرة
        if (report.recentAttendance.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    'أحدث سجلات الحضور',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: report.recentAttendance.length > 5
                      ? 5
                      : report.recentAttendance.length,
                  itemBuilder: (context, index) {
                    final attendance = report.recentAttendance[index];
                    return ListTile(
                      leading: Icon(
                        attendance.getStatusIcon(),
                        color: attendance.getStatusColor(),
                      ),
                      title: Text(
                        attendance.getStatusText(),
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      subtitle: Text(
                        '${attendance.date.day}/${attendance.date.month}/${attendance.date.year}',
                        style: GoogleFonts.cairo(color: Colors.grey[600]),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),
        ],

        // أحدث الدرجات
        if (report.recentGrades.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    'أحدث الدرجات',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: report.recentGrades.length > 5
                      ? 5
                      : report.recentGrades.length,
                  itemBuilder: (context, index) {
                    final grade = report.recentGrades[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: grade.getPerformanceColor().withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          '${grade.percentage.toStringAsFixed(0)}%',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: grade.getPerformanceColor(),
                          ),
                        ),
                      ),
                      title: Text(
                        grade.subject,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      subtitle: Text(
                        '${grade.getGradeTypeText()} - ${grade.score.toStringAsFixed(1)}/${grade.maxScore}',
                        style: GoogleFonts.cairo(color: Colors.grey[600]),
                      ),
                      trailing: Text(
                        grade.getPerformanceLevel(),
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: grade.getPerformanceColor(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        // تحديث التقرير
        setState(() {
          _loadReport();
        });
      },
      backgroundColor: AppConfig.primaryColor,
      icon: const Icon(Icons.refresh, color: Colors.white),
      label: Text(
        'تحديث',
        style: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
