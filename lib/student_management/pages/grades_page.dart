import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/app_config.dart';
import 'package:school_app/student_management/models/student.dart';

class GradesPage extends StatefulWidget {
  const GradesPage({super.key});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage>
    with TickerProviderStateMixin {
  List<Student> _students = [];
  final Map<String, Map<String, double>> _studentGrades = {};
  bool _isLoading = true;
  String _selectedClass = 'الصف الأول أ';
  String _selectedSubject = 'الرياضيات';
  String _selectedTerm = 'الفصل الأول';
  double _classAverage = 0.0;
  int _excellentCount = 0;
  int _goodCount = 0;
  int _passCount = 0;
  int _failCount = 0;

  late AnimationController _saveButtonController;
  late AnimationController _statsController;
  late Animation<double> _saveButtonScale;
  late Animation<double> _statsSlide;

  final List<String> _subjects = [
    'الرياضيات',
    'اللغة العربية',
    'اللغة الإنجليزية',
    'العلوم',
    'التاريخ',
    'الجغرافيا',
    'التربية الإسلامية',
    'التربية الرياضية'
  ];

  final List<String> _classes = [
    'الصف الأول أ',
    'الصف الأول ب',
    'الصف الثاني أ',
    'الصف الثاني ب',
    'الصف الثالث أ',
    'الصف الثالث ب'
  ];

  final List<String> _terms = [
    'الفصل الأول',
    'الفصل الثاني',
    'الفصل الثالث'
  ];

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
          end: 1.05,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.05,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_saveButtonController);

    // تأثير انزلاق الإحصائيات
    _statsSlide = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.easeOut),
    );

    // بدء التأثيرات
    _startAnimations();

    // تحميل البيانات
    _loadStudents();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _statsController.forward();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // محاكاة تحميل الطلاب
      await Future.delayed(const Duration(seconds: 1));

      // بيانات تجريبية للطلاب
      _students = [
        Student(
          id: '1',
          firstName: 'أحمد',
          lastName: 'محمد علي',
          fullName: 'أحمد محمد علي',
          studentId: 'STU001',
          birthDate: DateTime(2010, 5, 15),
          gender: 'ذكر',
          address: 'الرياض، المملكة العربية السعودية',
          phone: '0501234567',
          parentPhone: '0507654321',
          schoolId: 'SCH001',
          stageId: 'المرحلة الابتدائية',
          classGroupId: 'الصف الأول أ',
          status: 'نشط',
          enrollmentDate: DateTime(2023, 9, 1),
        ),
        Student(
          id: '2',
          firstName: 'فاطمة',
          lastName: 'أحمد حسن',
          fullName: 'فاطمة أحمد حسن',
          studentId: 'STU002',
          birthDate: DateTime(2010, 8, 22),
          gender: 'أنثى',
          address: 'الرياض، المملكة العربية السعودية',
          phone: '0502345678',
          parentPhone: '0508765432',
          schoolId: 'SCH001',
          stageId: 'المرحلة الابتدائية',
          classGroupId: 'الصف الأول أ',
          status: 'نشط',
          enrollmentDate: DateTime(2023, 9, 1),
        ),
        Student(
          id: '3',
          firstName: 'محمد',
          lastName: 'عبدالله سالم',
          fullName: 'محمد عبدالله سالم',
          studentId: 'STU003',
          birthDate: DateTime(2010, 3, 10),
          gender: 'ذكر',
          address: 'الرياض، المملكة العربية السعودية',
          phone: '0503456789',
          parentPhone: '0509876543',
          schoolId: 'SCH001',
          stageId: 'المرحلة الابتدائية',
          classGroupId: 'الصف الأول أ',
          status: 'نشط',
          enrollmentDate: DateTime(2023, 9, 1),
        ),
      ];

      // إنشاء درجات تجريبية
      for (var student in _students) {
        _studentGrades[student.id] = {
          'الرياضيات': (80 + (DateTime.now().millisecondsSinceEpoch % 20)).toDouble(),
          'اللغة العربية': (75 + (DateTime.now().millisecondsSinceEpoch % 25)).toDouble(),
          'اللغة الإنجليزية': (85 + (DateTime.now().millisecondsSinceEpoch % 15)).toDouble(),
          'العلوم': (78 + (DateTime.now().millisecondsSinceEpoch % 22)).toDouble(),
        };
      }

      _calculateStats();

    } catch (e) {
      // التعامل مع الأخطاء - استخدام debugPrint بدلاً من print
      debugPrint('Error loading students: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateStats() {
    double total = 0;
    int count = 0;
    _excellentCount = 0;
    _goodCount = 0;
    _passCount = 0;
    _failCount = 0;

    for (var grades in _studentGrades.values) {
      if (grades.containsKey(_selectedSubject)) {
        double grade = grades[_selectedSubject]!;
        total += grade;
        count++;

        if (grade >= 90) {
          _excellentCount++;
        } else if (grade >= 80) {
          _goodCount++;
        } else if (grade >= 60) {
          _passCount++;
        } else {
          _failCount++;
        }
      }
    }

    _classAverage = count > 0 ? total / count : 0.0;
  }

  Future<void> _saveGrades() async {
    setState(() {
      _isLoading = true;
    });

    // تشغيل تأثير زر الحفظ
    await _saveButtonController.forward();

    try {
      // محاكاة حفظ الدرجات
      await Future.delayed(const Duration(seconds: 2));

      // إظهار رسالة النجاح
      if (mounted) {
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
    } catch (e) {
      // التعامل مع الأخطاء - استخدام debugPrint بدلاً من print
      debugPrint('Error saving grades: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateGrade(String studentId, String subject, double grade) {
    setState(() {
      if (_studentGrades[studentId] == null) {
        _studentGrades[studentId] = {};
      }
      _studentGrades[studentId]![subject] = grade;
      _calculateStats();
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
          'إدارة الدرجات',
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
          IconButton(
            icon: const Icon(Icons.print_outlined, color: Colors.white),
            onPressed: () {
              // طباعة التقرير
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {
              // مشاركة التقرير
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppConfig.primaryColor),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppConfig.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // فلاتر الصف والمادة والفصل
                  _buildFiltersSection(),

                  const SizedBox(height: AppConfig.spacingLG),

                  // إحصائيات الصف
                  AnimatedBuilder(
                    animation: _statsController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_statsSlide.value, 0),
                        child: Opacity(
                          opacity: _statsController.value,
                          child: _buildStatsSection(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppConfig.spacingLG),

                  // قائمة الطلاب والدرجات
                  _buildStudentsGradesSection(),

                  const SizedBox(height: AppConfig.spacingXXL),

                  // زر الحفظ المتحرك
                  AnimatedBuilder(
                    animation: _saveButtonScale,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _saveButtonScale.value,
                        child: ElevatedButton(
                          onPressed: _saveGrades,
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
                              const Icon(Icons.save_outlined, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                'حفظ الدرجات',
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

                  const SizedBox(height: AppConfig.spacingLG),
                ],
              ),
            ),
    );
  }

  Widget _buildFiltersSection() {
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الفلاتر',
              style: GoogleFonts.cairo(
                fontSize: AppConfig.fontSizeXLarge,
                fontWeight: FontWeight.bold,
                color: AppConfig.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppConfig.spacingLG),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    'الصف الدراسي',
                    _selectedClass,
                    _classes,
                    (value) {
                      setState(() {
                        _selectedClass = value!;
                        _loadStudents();
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppConfig.spacingMD),
                Expanded(
                  child: _buildDropdown(
                    'المادة',
                    _selectedSubject,
                    _subjects,
                    (value) {
                      setState(() {
                        _selectedSubject = value!;
                        _calculateStats();
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppConfig.spacingMD),
                Expanded(
                  child: _buildDropdown(
                    'الفصل الدراسي',
                    _selectedTerm,
                    _terms,
                    (value) {
                      setState(() {
                        _selectedTerm = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إحصائيات الصف',
              style: GoogleFonts.cairo(
                fontSize: AppConfig.fontSizeXLarge,
                fontWeight: FontWeight.bold,
                color: AppConfig.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppConfig.spacingLG),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'متوسط الدرجات',
                    _classAverage.toStringAsFixed(1),
                    Icons.analytics_outlined,
                    AppConfig.primaryColor,
                  ),
                ),
                const SizedBox(width: AppConfig.spacingSM),
                Expanded(
                  child: _buildStatCard(
                    'ممتاز',
                    _excellentCount.toString(),
                    Icons.star_outlined,
                    AppConfig.successColor,
                  ),
                ),
                const SizedBox(width: AppConfig.spacingSM),
                Expanded(
                  child: _buildStatCard(
                    'جيد',
                    _goodCount.toString(),
                    Icons.thumb_up_outlined,
                    AppConfig.infoColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConfig.spacingSM),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'مقبول',
                    _passCount.toString(),
                    Icons.check_circle_outline,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: AppConfig.spacingSM),
                Expanded(
                  child: _buildStatCard(
                    'راسب',
                    _failCount.toString(),
                    Icons.warning_amber_outlined,
                    AppConfig.errorColor,
                  ),
                ),
                const SizedBox(width: AppConfig.spacingSM),
                Expanded(
                  child: Container(), // مساحة فارغة للحفاظ على التنسيق
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConfig.spacingMD),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppConfig.spacingSM),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: AppConfig.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
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

  Widget _buildStudentsGradesSection() {
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'قائمة الطلاب والدرجات',
                  style: GoogleFonts.cairo(
                    fontSize: AppConfig.fontSizeXLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConfig.textPrimaryColor,
                  ),
                ),
                Text(
                  'عدد الطلاب: ${_students.length}',
                  style: GoogleFonts.cairo(
                    fontSize: AppConfig.fontSizeMedium,
                    color: AppConfig.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConfig.spacingLG),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _students.length,
              separatorBuilder: (context, index) => Divider(
                color: AppConfig.borderColor,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final student = _students[index];
                final currentGrade = _studentGrades[student.id]?[_selectedSubject] ?? 0.0;

                return Container(
                  padding: const EdgeInsets.all(AppConfig.spacingMD),
                  decoration: BoxDecoration(
                    color: index % 2 == 0
                        ? AppConfig.backgroundColor
                        : AppConfig.cardColor,
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
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
                                fontWeight: FontWeight.bold,
                                color: AppConfig.textPrimaryColor,
                              ),
                            ),
                            Text(
                              'رقم الطالب: ${student.studentId}',
                              style: GoogleFonts.cairo(
                                fontSize: AppConfig.fontSizeSmall,
                                color: AppConfig.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppConfig.borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppConfig.primaryColor),
                            ),
                          ),
                          controller: TextEditingController(
                            text: currentGrade.toStringAsFixed(0),
                          ),
                          onChanged: (value) {
                            double? grade = double.tryParse(value);
                            if (grade != null && grade >= 0 && grade <= 100) {
                              _updateGrade(student.id, _selectedSubject, grade);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppConfig.spacingSM),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getGradeColor(currentGrade).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getGradeColor(currentGrade),
                          ),
                        ),
                        child: Text(
                          _getGradeText(currentGrade),
                          style: GoogleFonts.cairo(
                            fontSize: AppConfig.fontSizeSmall,
                            color: _getGradeColor(currentGrade),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: AppConfig.fontSizeSmall,
            fontWeight: FontWeight.w600,
            color: AppConfig.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppConfig.borderColor, width: 1),
            borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
          ),
          child: DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.cairo(
                    fontSize: AppConfig.fontSizeSmall,
                    color: AppConfig.textPrimaryColor,
                  ),
                ),
              );
            }).toList(),
            style: GoogleFonts.cairo(
              fontSize: AppConfig.fontSizeSmall,
              color: AppConfig.textPrimaryColor,
            ),
            underline: Container(),
            isExpanded: true,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConfig.spacingMD,
            ),
          ),
        ),
      ],
    );
  }

  Color _getGradeColor(double grade) {
    if (grade >= 90) return AppConfig.successColor;
    if (grade >= 80) return AppConfig.infoColor;
    if (grade >= 60) return Colors.orange;
    return AppConfig.errorColor;
  }

  String _getGradeText(double grade) {
    if (grade >= 90) return 'ممتاز';
    if (grade >= 80) return 'جيد جداً';
    if (grade >= 60) return 'مقبول';
    return 'راسب';
  }
}
