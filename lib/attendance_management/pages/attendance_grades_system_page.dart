import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/app_config.dart';
import 'package:school_app/school_management/models/class_group.dart';
import 'package:school_app/school_management/models/school.dart';
import 'package:school_app/school_management/services/school_service.dart';
import 'package:school_app/student_management/services/student_service.dart';
import 'package:logging/logging.dart';

final _logger = Logger('AttendanceGradesSystemPage');

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
  List<School> _schools = [];
  List<ClassGroup> _classGroups = [];
  School? _selectedSchool;
  ClassGroup? _selectedClassGroup;
  List<Student> _attendanceStudents = [];
  List<Student> _gradeStudents = [];
  final Map<String, String> _attendanceStatus = {};
  final Map<String, double> _gradeInputs = {};
  bool _isLoading = true;

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

    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    // Initialize demo data
    await SchoolService.instance.initializeDemoData();
    await StudentService().initializeDemoStudents();

    // Get all schools
    final schools = await SchoolService.instance.getSchools();
    final selectedSchool = schools.isNotEmpty ? schools.first : null;
    
    // Get class groups for the selected school
    final classGroups = selectedSchool != null
        ? await _getClassGroupsForSchool(selectedSchool.id)
        : <ClassGroup>[];
    final selectedGroup = classGroups.isNotEmpty ? classGroups.first : null;
    // الحصول على الطلاب حسب الصف المحدد
    final students = selectedGroup != null
        ? await StudentService().getStudentsByClassGroup(selectedGroup.id)
        : <Student>[];

    setState(() {
      _schools = schools;
      _classGroups = classGroups;
      _selectedSchool = selectedSchool;
      _selectedClassGroup = selectedGroup;
      _attendanceStudents = students;
      _gradeStudents = students;
      _initializeAttendanceStatus();
      _initializeGradeInputs();
      _isLoading = false;
    });
  }

  Future<List<ClassGroup>> _getClassGroupsForSchool(String schoolId) async {
    try {
      final stages = await SchoolService.instance.getStagesBySchool(schoolId);
      final groups = <ClassGroup>[];
      for (var stage in stages) {
        final stageGroups = await SchoolService.instance.getClassGroupsByStage(stage.id);
        groups.addAll(stageGroups);
      }
      return groups;
    } catch (e) {
      _logger.severe('Error getting class groups for school', e);
      return [];
    }
  }

  Future<void> _onSchoolChanged(String? schoolId) async {
    if (schoolId == null) {
      return;
    }

    final school = _schools.firstWhere((s) => s.id == schoolId);

    setState(() {
      _selectedSchool = school;
      _classGroups = [];
      _selectedClassGroup = null;
      _attendanceStudents = [];
      _gradeStudents = [];
      _attendanceStatus.clear();
      _gradeInputs.clear();
      _isLoading = true;
    });

    final groups = await _getClassGroupsForSchool(schoolId);
    final initialGroup = groups.isNotEmpty ? groups.first : null;

    setState(() {
      _classGroups = groups;
      _selectedClassGroup = initialGroup;
    });

    if (initialGroup != null) {
      await _loadStudentsForClass(initialGroup.id);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onClassChanged(String? classId) async {
    if (classId == null) {
      return;
    }

    final group = _classGroups.firstWhere((g) => g.id == classId, orElse: () => _classGroups.first);

    setState(() {
      _selectedClassGroup = group;
    });

    await _loadStudentsForClass(group.id);
  }

  Future<void> _loadStudentsForClass(String classGroupId) async {
    setState(() {
      _isLoading = true;
      _attendanceStudents = [];
      _gradeStudents = [];
      _attendanceStatus.clear();
      _gradeInputs.clear();
    });

    final students = await StudentService().getStudentsByClassGroup(classGroupId);

    setState(() {
      _attendanceStudents = students;
      _gradeStudents = students;
      _initializeAttendanceStatus();
      _initializeGradeInputs();
      _isLoading = false;
    });
  }

  void _initializeAttendanceStatus() {
    for (var student in _attendanceStudents) {
      _attendanceStatus[student.id] = AppConfig.attendancePresent;
    }
  }

  void _initializeGradeInputs() {
    for (var student in _gradeStudents) {
      _gradeInputs[student.id] = 0;
    }
  }

  void _saveAttendance() {
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
  }

  void _saveGrades() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'تم حفظ الدرجات بنجاح',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: AppConfig.primaryColor,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildSelectionCard() {
    return Container(
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
          DropdownButtonFormField<String>(
            initialValue: _selectedSchool?.id,
            decoration: InputDecoration(
              labelText: 'اختر المدرسة',
              labelStyle: GoogleFonts.cairo(
                color: AppConfig.textSecondaryColor,
              ),
              filled: true,
              fillColor: AppConfig.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                borderSide: BorderSide.none,
              ),
            ),
            items: _schools
                .map(
                  (school) => DropdownMenuItem(
                    value: school.id,
                    child: Text(
                      school.name,
                      style: GoogleFonts.cairo(
                        color: AppConfig.textPrimaryColor,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              _onSchoolChanged(value);
            },
          ),
          const SizedBox(height: AppConfig.spacingMD),
          DropdownButtonFormField<String>(
            initialValue: _selectedClassGroup?.id,
            decoration: InputDecoration(
              labelText: 'اختر الشعبة',
              labelStyle: GoogleFonts.cairo(
                color: AppConfig.textSecondaryColor,
              ),
              filled: true,
              fillColor: AppConfig.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                borderSide: BorderSide.none,
              ),
            ),
            items: _classGroups
                .map(
                  (group) => DropdownMenuItem(
                    value: group.id,
                    child: Text(
                      group.name,
                      style: GoogleFonts.cairo(
                        color: AppConfig.textPrimaryColor,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: _classGroups.isEmpty
                ? null
                : (value) {
                    _onClassChanged(value);
                  },
          ),
        ],
      ),
    );
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppConfig.primaryColor),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppConfig.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'الحاضرون اليوم',
                  _attendanceStatus.values
                      .where((status) => status == AppConfig.attendancePresent)
                      .length
                      .toString(),
                  Icons.check_circle,
                  AppConfig.successColor,
                ),
              ),
              const SizedBox(width: AppConfig.spacingMD),
              Expanded(
                child: _buildStatCard(
                  'الغائبون',
                  _attendanceStatus.values
                      .where((status) => status == AppConfig.attendanceAbsent)
                      .length
                      .toString(),
                  Icons.cancel,
                  AppConfig.errorColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConfig.spacingLG),

          _buildSelectionCard(),

          const SizedBox(height: AppConfig.spacingLG),

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
                  itemCount: _attendanceStudents.length,
                  itemBuilder: (context, index) {
                    final student = _attendanceStudents[index];
                    final currentStatus = _attendanceStatus[student.id] ?? AppConfig.attendancePresent;
                    return _buildStudentAttendanceItem(student, currentStatus);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConfig.spacingLG),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _attendanceStudents.isEmpty ? null : _saveAttendance,
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppConfig.primaryColor),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppConfig.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectionCard(),

          const SizedBox(height: AppConfig.spacingLG),

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
                  itemCount: _gradeStudents.length,
                  itemBuilder: (context, index) {
                    final student = _gradeStudents[index];
                    final currentGrade = _gradeInputs[student.id] ?? 0;
                    return _buildStudentGradeItem(student, currentGrade);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConfig.spacingLG),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _gradeStudents.isEmpty ? null : _saveGrades,
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
    return Container(
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
    );
  }

  Widget _buildStudentAttendanceItem(Student student, String status) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dropdownWidth = (constraints.maxWidth * 0.32).clamp(140.0, 220.0).toDouble();
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
                  student.initials,
                  style: GoogleFonts.cairo(
                    color: AppConfig.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppConfig.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: GoogleFonts.cairo(
                        fontSize: AppConfig.fontSizeMedium,
                        color: AppConfig.textPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'رقم الطالب: ${student.studentId}',
                      style: GoogleFonts.cairo(
                        fontSize: AppConfig.fontSizeSmall,
                        color: AppConfig.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConfig.spacingMD),
              SizedBox(
                width: dropdownWidth,
                child: DropdownButton<String>(
                  value: status,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: AppConfig.attendancePresent,
                      child: Text(
                        'حاضر',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem(
                      value: AppConfig.attendanceAbsent,
                      child: Text(
                        'غائب',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem(
                      value: AppConfig.attendanceExcused,
                      child: Text(
                        'مجاز',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem(
                      value: AppConfig.attendanceLate,
                      child: Text(
                        'متأخر',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _attendanceStatus[student.id] = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentGradeItem(Student student, double gradeValue) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final inputWidth = (constraints.maxWidth * 0.24).clamp(80.0, 160.0).toDouble();
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
                  student.initials,
                  style: GoogleFonts.cairo(
                    color: AppConfig.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppConfig.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: GoogleFonts.cairo(
                        fontSize: AppConfig.fontSizeMedium,
                        color: AppConfig.textPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'رقم الطالب: ${student.studentId}',
                      style: GoogleFonts.cairo(
                        fontSize: AppConfig.fontSizeSmall,
                        color: AppConfig.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConfig.spacingMD),
              SizedBox(
                width: inputWidth,
                child: TextField(
                  controller: TextEditingController(text: gradeValue.toStringAsFixed(0)),
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
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null && parsed >= 0 && parsed <= 100) {
                      setState(() {
                        _gradeInputs[student.id] = parsed;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
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
