import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/app_config.dart';
// StudentReport is already imported through student_service.dart
import 'package:school_app/student_management/services/student_service.dart';

class AllStudentsReportsPage extends StatefulWidget {
  const AllStudentsReportsPage({super.key});

  @override
  State<AllStudentsReportsPage> createState() => _AllStudentsReportsPageState();
}

class _AllStudentsReportsPageState extends State<AllStudentsReportsPage> {
  final StudentService _studentService = StudentService();
  List<StudentReport> _studentReports = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAllStudentReports();
  }

  Future<void> _loadAllStudentReports() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Ensure demo data is initialized
      await _studentService.initializeDemoStudents();

      // Generate reports for all students
      final reports = await _studentService.generateAllStudentReports();

      // Filter reports based on search query
      final filteredReports = _searchQuery.isEmpty
          ? reports
          : reports.where((report) {
              return report.student.fullName.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  report.student.studentId.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  report.student.schoolId.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
            }).toList();

      // Sort reports by overall score (highest first)
      filteredReports.sort((a, b) => b.overallScore.compareTo(a.overallScore));

      if (mounted) {
        setState(() {
          _studentReports = filteredReports;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading student reports: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تحميل التقارير: ${e.toString()}'),
          ),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadAllStudentReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      appBar: AppBar(
        title: Text(
          'تقارير جميع الطلاب',
          style: GoogleFonts.cairo(
            fontSize: AppConfig.fontSizeXXLarge,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConfig.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAllStudentReports,
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          Container(
            padding: const EdgeInsets.all(AppConfig.spacingMD),
            decoration: BoxDecoration(
              color: AppConfig.cardColor,
              boxShadow: [
                BoxShadow(
                  color: AppConfig.borderColor.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'البحث في الطلاب أو المدارس...',
                hintStyle: GoogleFonts.cairo(
                  color: AppConfig.textSecondaryColor,
                  fontSize: AppConfig.fontSizeMedium,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppConfig.textSecondaryColor,
                ),
                filled: true,
                fillColor: AppConfig.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                  borderSide: BorderSide(color: AppConfig.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                  borderSide: BorderSide(color: AppConfig.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                  borderSide: BorderSide(color: AppConfig.primaryColor),
                ),
              ),
              style: GoogleFonts.cairo(
                fontSize: AppConfig.fontSizeMedium,
                color: AppConfig.textPrimaryColor,
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // ملخص التقارير
          if (!_isLoading && _studentReports.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppConfig.spacingMD),
              decoration: BoxDecoration(
                color: AppConfig.cardColor,
                border: Border(
                  bottom: BorderSide(
                    color: AppConfig.borderColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'إجمالي الطلاب',
                      '${_studentReports.length}',
                      Icons.people,
                      AppConfig.primaryColor,
                    ),
                  ),
                  const SizedBox(width: AppConfig.spacingSM),
                  Expanded(
                    child: _buildSummaryCard(
                      'المعدل العام',
                      '${_getOverallAverage().toStringAsFixed(1)}%',
                      Icons.analytics,
                      AppConfig.secondaryColor,
                    ),
                  ),
                  const SizedBox(width: AppConfig.spacingSM),
                  Expanded(
                    child: _buildSummaryCard(
                      'الأداء الممتاز',
                      '${_getExcellentCount()}',
                      Icons.star,
                      AppConfig.successColor,
                    ),
                  ),
                ],
              ),
            ),

          // قائمة تقارير الطلاب
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppConfig.primaryColor,
                    ),
                  )
                : _studentReports.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(AppConfig.spacingMD),
                    itemCount: _studentReports.length,
                    itemBuilder: (context, index) {
                      return _buildStudentReportCard(_studentReports[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConfig.spacingSM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: AppConfig.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: AppConfig.fontSizeSmall,
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'لا يوجد طلاب في النظام'
                : 'لا توجد نتائج للبحث',
            style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'قم بإضافة طلاب لترى تقاريرهم هنا'
                : 'جرب كلمات بحث مختلفة',
            style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentReportCard(StudentReport report) {
    final student = report.student;
    final attendanceRate = report.attendanceRate;
    final gradeAverage = report.gradeAverage;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        onTap: () {
          // يمكن إضافة تفاصيل أكثر للطالب هنا
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات الطالب الأساسية
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppConfig.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        student.initials,
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppConfig.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName,
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'رقم الطالب: ${student.studentId}',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'المدرسة: ${student.schoolId}',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: report.getEvaluationColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppConfig.borderRadius / 2,
                      ),
                    ),
                    child: Text(
                      report.getEvaluationText(),
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: report.getEvaluationColor(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // إحصائيات الحضور والدرجات
              Row(
                children: [
                  // نسبة الحضور
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_available,
                          color: _getAttendanceColor(attendanceRate),
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${attendanceRate.toStringAsFixed(1)}%',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getAttendanceColor(attendanceRate),
                          ),
                        ),
                        Text(
                          'نسبة الحضور',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // متوسط الدرجات
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          Icons.grade,
                          color: _getGradeColor(gradeAverage),
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${gradeAverage.toStringAsFixed(1)}%',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getGradeColor(gradeAverage),
                          ),
                        ),
                        Text(
                          'متوسط الدرجات',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // التقييم العام
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          report.getEvaluationIcon(),
                          color: report.getEvaluationColor(),
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.overallScore.toStringAsFixed(1),
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: report.getEvaluationColor(),
                          ),
                        ),
                        Text(
                          'التقييم العام',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // تفاصيل إضافية مختصرة
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConfig.backgroundColor,
                  borderRadius: BorderRadius.circular(
                    AppConfig.borderRadius / 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تقييم مفصل:',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppConfig.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.evaluation,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppConfig.textPrimaryColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAttendanceColor(double rate) {
    if (rate >= 90) return const Color(0xFF10B981); // أخضر - ممتاز
    if (rate >= 80) return const Color(0xFFF59E0B); // برتقالي - جيد
    if (rate >= 70) return const Color(0xFFF97316); // برتقالي داكن - مقبول
    return const Color(0xFFEF4444); // أحمر - ضعيف
  }

  Color _getGradeColor(double average) {
    if (average >= 90) return const Color(0xFF059669); // أخضر داكن - ممتاز
    if (average >= 80) return const Color(0xFF10B981); // أخضر فاتح - جيد جداً
    if (average >= 70) return const Color(0xFFF59E0B); // برتقالي - جيد
    if (average >= 60) return const Color(0xFFF97316); // برتقالي داكن - مقبول
    return const Color(0xFFEF4444); // أحمر - ضعيف
  }

  double _getOverallAverage() {
    if (_studentReports.isEmpty) return 0.0;
    final total = _studentReports
        .map((r) => r.overallScore)
        .reduce((a, b) => a + b);
    return total / _studentReports.length;
  }

  int _getExcellentCount() {
    return _studentReports.where((r) => r.overallScore >= 90).length;
  }
}
