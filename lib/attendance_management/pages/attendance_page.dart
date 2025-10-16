import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/app_config.dart';
import 'package:school_app/student_management/models/student.dart';
import 'package:school_app/student_management/models/attendance.dart';
import 'package:school_app/student_management/services/student_service.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage>
    with TickerProviderStateMixin {
  List<Student> _students = [];
  final Map<String, String> _attendanceStatus = {};
  bool _isLoading = true;
  final String _selectedClass = 'الصف الأول أ';
  int _presentCount = 0;
  int _absentCount = 0;
  int _excusedCount = 0;
  int _lateCount = 0;

  late AnimationController _saveButtonController;
  late AnimationController _statsController;
  late Animation<double> _saveButtonScale;
  late Animation<double> _statsSlide;

  @override
  void initState() {
    super.initState();

    // متحكم تأثير زر الحفظ
    _saveButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // متحكم تأثير الإحصائيات
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // تأثير تكبير زر الحفظ
    _saveButtonScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_saveButtonController);

    // تأثير انزلاق الإحصائيات
    _statsSlide = Tween<double>(
      begin: -50.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _statsController, curve: Curves.easeOut));

    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    // تهيئة البيانات التجريبية
    await StudentService.initializeDemoStudents();

    // الحصول على الطلاب حسب الصف المحدد
    final students = await StudentService.getStudentsByClassGroup('group_1');

    setState(() {
      _students = students;
      _initializeAttendanceStatus();
      _calculateStats();
      _isLoading = false;
    });

    // بدء تأثير الإحصائيات
    _statsController.forward();
  }

  void _initializeAttendanceStatus() {
    // تهيئة جميع الطلاب كـ "حاضر" افتراضياً
    for (var student in _students) {
      _attendanceStatus[student.id] = AppConfig.attendancePresent;
    }
  }

  void _calculateStats() {
    _presentCount = _attendanceStatus.values
        .where((status) => status == AppConfig.attendancePresent)
        .length;
    _absentCount = _attendanceStatus.values
        .where((status) => status == AppConfig.attendanceAbsent)
        .length;
    _excusedCount = _attendanceStatus.values
        .where((status) => status == AppConfig.attendanceExcused)
        .length;
    _lateCount = _attendanceStatus.values
        .where((status) => status == AppConfig.attendanceLate)
        .length;
  }

  void _updateAttendanceStatus(String studentId, String status) {
    setState(() {
      _attendanceStatus[studentId] = status;
      _calculateStats();
    });

    // تشغيل تأثير الإحصائيات عند كل تحديث
    _statsController.forward(from: 0.0);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConfig.attendancePresent:
        return AppConfig.presentColor;
      case AppConfig.attendanceAbsent:
        return AppConfig.absentColor;
      case AppConfig.attendanceExcused:
        return AppConfig.excusedColor;
      case AppConfig.attendanceLate:
        return AppConfig.lateColor;
      default:
        return AppConfig.borderColor;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case AppConfig.attendancePresent:
        return 'حاضر';
      case AppConfig.attendanceAbsent:
        return 'غائب';
      case AppConfig.attendanceExcused:
        return 'مجاز';
      case AppConfig.attendanceLate:
        return 'متأخر';
      default:
        return 'غير محدد';
    }
  }

  Future<void> _saveAttendance() async {
    // تشغيل تأثير زر الحفظ
    await _saveButtonController.forward();

    // حفظ سجلات الحضور
    for (var entry in _attendanceStatus.entries) {
      final student = _students.firstWhere((s) => s.id == entry.key);
      final attendance = Attendance(
        id: 'attendance_${student.id}_${DateTime.now().millisecondsSinceEpoch}',
        studentId: student.id,
        schoolId: student.schoolId,
        date: DateTime.now(),
        status: entry.value,
        recordedBy: 'teacher_1',
        recordedAt: DateTime.now(),
      );

      await StudentService.recordAttendance(attendance);
    }

    // إظهار رسالة النجاح المتحركة
    if (mounted) {
      _showSuccessMessage();
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'تم حفظ سجل الحضور بنجاح',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: AppConfig.successColor,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );

    // العودة إلى لوحة التحكم بعد فترة قصيرة
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _saveButtonController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      appBar: AppBar(
        title: Text(
          'تسجيل الحضور',
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
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _selectedClass,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: AppConfig.fontSizeMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط الإحصائيات المتحرك
          AnimatedBuilder(
            animation: _statsController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_statsSlide.value, 0),
                child: Opacity(
                  opacity: _statsController.value,
                  child: Container(
                    padding: const EdgeInsets.all(AppConfig.spacingMD),
                    decoration: BoxDecoration(
                      color: AppConfig.surfaceColor,
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
                        _buildStatCard(
                          'الحاضرون',
                          _presentCount.toString(),
                          AppConfig.presentColor,
                        ),
                        const SizedBox(width: 8),
                        _buildStatCard(
                          'الغائبون',
                          _absentCount.toString(),
                          AppConfig.absentColor,
                        ),
                        const SizedBox(width: 8),
                        _buildStatCard(
                          'المجازون',
                          _excusedCount.toString(),
                          AppConfig.excusedColor,
                        ),
                        const SizedBox(width: 8),
                        _buildStatCard(
                          'المتأخرون',
                          _lateCount.toString(),
                          AppConfig.lateColor,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // قائمة الطلاب
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppConfig.primaryColor,
                    ),
                  )
                : ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      final status =
                          _attendanceStatus[student.id] ??
                          AppConfig.attendancePresent;

                      return _buildStudentAttendanceCard(student, status);
                    },
                  ),
          ),

          // زر الحفظ المتحرك
          Container(
            padding: const EdgeInsets.all(AppConfig.spacingMD),
            decoration: BoxDecoration(
              color: AppConfig.surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: AppConfig.borderColor.withValues(alpha: 0.5),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _saveButtonScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _saveButtonScale.value,
                  child: ElevatedButton(
                    onPressed: _saveAttendance,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.save_rounded, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'حفظ وتأكيد',
                          style: GoogleFonts.cairo(
                            fontSize: AppConfig.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: AppConfig.fontSizeXLarge,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: AppConfig.fontSizeSmall,
                color: AppConfig.textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentAttendanceCard(Student student, String status) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConfig.spacingMD,
        vertical: AppConfig.spacingSM,
      ),
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
        border: Border.all(
          color: _getStatusColor(status).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          onTap: () {
            _showStatusOptions(student);
          },
          child: Padding(
            padding: const EdgeInsets.all(AppConfig.spacingMD),
            child: Row(
              children: [
                // صورة الطالب
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppConfig.primaryColor.withValues(
                    alpha: 0.1,
                  ),
                  child: Text(
                    student.initials,
                    style: GoogleFonts.cairo(
                      fontSize: AppConfig.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: AppConfig.primaryColor,
                    ),
                  ),
                ),

                const SizedBox(width: AppConfig.spacingMD),

                // معلومات الطالب
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName,
                        style: GoogleFonts.cairo(
                          fontSize: AppConfig.fontSizeLarge,
                          fontWeight: FontWeight.w600,
                          color: AppConfig.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'رقم الطالب: ${student.studentId}',
                        style: GoogleFonts.cairo(
                          fontSize: AppConfig.fontSizeMedium,
                          color: AppConfig.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // حالة الحضور مع أيقونة
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConfig.spacingMD,
                    vertical: AppConfig.spacingSM,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppConfig.borderRadius / 2,
                    ),
                    border: Border.all(
                      color: _getStatusColor(status).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        status == AppConfig.attendancePresent
                            ? Icons.check_circle
                            : status == AppConfig.attendanceAbsent
                            ? Icons.cancel
                            : status == AppConfig.attendanceExcused
                            ? Icons.info
                            : Icons.schedule,
                        color: _getStatusColor(status),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getStatusText(status),
                        style: GoogleFonts.cairo(
                          fontSize: AppConfig.fontSizeSmall,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStatusOptions(Student student) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConfig.borderRadius),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppConfig.spacingMD),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تحديد حالة ${student.firstName}',
                style: GoogleFonts.cairo(
                  fontSize: AppConfig.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: AppConfig.textPrimaryColor,
                ),
              ),
              const SizedBox(height: AppConfig.spacingLG),

              _buildStatusOption(
                'حاضر',
                AppConfig.attendancePresent,
                AppConfig.presentColor,
                Icons.check_circle,
                () {
                  _updateAttendanceStatus(
                    student.id,
                    AppConfig.attendancePresent,
                  );
                  Navigator.of(context).pop();
                },
                student.id,
              ),

              _buildStatusOption(
                'غائب',
                AppConfig.attendanceAbsent,
                AppConfig.absentColor,
                Icons.cancel,
                () {
                  _updateAttendanceStatus(
                    student.id,
                    AppConfig.attendanceAbsent,
                  );
                  Navigator.of(context).pop();
                },
                student.id,
              ),

              _buildStatusOption(
                'مجاز',
                AppConfig.attendanceExcused,
                AppConfig.excusedColor,
                Icons.info,
                () {
                  _updateAttendanceStatus(
                    student.id,
                    AppConfig.attendanceExcused,
                  );
                  Navigator.of(context).pop();
                },
                student.id,
              ),

              _buildStatusOption(
                'متأخر',
                AppConfig.attendanceLate,
                AppConfig.lateColor,
                Icons.schedule,
                () {
                  _updateAttendanceStatus(student.id, AppConfig.attendanceLate);
                  Navigator.of(context).pop();
                },
                student.id,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusOption(
    String label,
    String status,
    Color color,
    IconData icon,
    VoidCallback onTap,
    String studentId,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConfig.spacingSM),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
          child: Container(
            padding: const EdgeInsets.all(AppConfig.spacingMD),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: AppConfig.fontSizeLarge,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const Spacer(),
                if (_attendanceStatus[studentId] == status)
                  Icon(Icons.check, color: color, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
