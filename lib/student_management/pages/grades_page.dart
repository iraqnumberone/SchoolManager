import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/app_config.dart';
import 'package:school_app/student_management/services/student_service.dart';
import 'package:school_app/school_management/services/school_service.dart';

import 'package:school_app/school_management/models/school.dart';

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class GradesPage extends StatefulWidget {
  final VoidCallback? onBack;
  const GradesPage({super.key, this.onBack});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> with TickerProviderStateMixin {
  final StudentService _studentService = StudentService();
  List<Student> _students = [];
  final Map<String, List<Grade>> _gradesByStudent = {};
  bool _isLoading = true;
  // Selection state (uses real schools/class groups)
  List<School> _schools = [];
  School? _selectedSchool;
  String _selectedTerm = 'الفصل الأول';
  String _selectedMonthLabel = 'الشهر الأول';
  String _selectedGradeType = 'monthly';
  double _classAverage = 0.0;
  int _excellentCount = 0;
  int _goodCount = 0;
  int _passCount = 0;
  int _failCount = 0;

  late AnimationController _saveButtonController;
  late AnimationController _statsController;
  late Animation<double> _saveButtonScale;
  late Animation<double> _statsSlide;

  final List<String> _terms = ['الفصل الأول', 'الفصل الثاني'];
  final List<String> _months = ['الشهر الأول', 'الشهر الثاني', 'الشهر الثالث'];
  final Map<String, String> _gradeTypeLabels = {
    'monthly': 'امتحان شهري',
    'daily': 'امتحان يومي',
  };

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
    _statsSlide = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _statsController, curve: Curves.easeOut));

    // بدء التأثيرات
    _startAnimations();

    // تحميل البيانات
    _initializeData();
  }

  Future<void> _updateDailyGrade(String studentId, double score) async {
    final grades = _gradesByStudent[studentId] ?? [];
    grades.sort((a, b) => b.date.compareTo(a.date));
    Grade? existing;
    final now = DateTime.now();
    for (final g in grades) {
      if (g.gradeType == 'daily') {
        final d = g.date;
        if (d.year == now.year && d.month == now.month && d.day == now.day) {
          existing = g;
          break;
        }
      }
    }

    Grade updated =
        (existing ??
                Grade(
                  id: 'grade_${DateTime.now().millisecondsSinceEpoch}',
                  studentId: studentId,
                  schoolId: _selectedSchool?.id ?? '1',
                  subject: 'عام',
                  gradeType: 'daily',
                  score: score,
                  maxScore: 100.0,
                  date: now,
                  recordedBy: 'teacher_1',
                  recordedAt: now,
                  additionalData: {'date': now.toIso8601String()},
                ))
            .copyWith(
              score: score,
              date: now,
              recordedAt: now,
              gradeType: 'daily',
              subject: 'عام',
              additionalData: {'date': now.toIso8601String()},
            );

    bool ok;
    if (existing != null) {
      ok = await _studentService.updateGrade(updated);
      if (ok) {
        final idx = grades.indexWhere((g) => g.id == existing!.id);
        if (idx != -1) grades[idx] = updated;
      }
    } else {
      ok = await _studentService.addGrade(updated);
      if (ok) grades.add(updated);
    }
    if (ok) {
      setState(() {
        _gradesByStudent[studentId] = grades;
        _calculateStats();
      });
    }
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _statsController.forward();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await SchoolService.instance.initializeDemoData();
      await _studentService.initializeDemoStudents();

      final schools = await SchoolService.instance.getSchools();
      final selectedSchool = schools.isNotEmpty ? schools.first : null;

      List<Student> students = [];
      if (selectedSchool != null) {
        students = await _studentService.getStudentsBySchool(selectedSchool.id);
      }

      _gradesByStudent.clear();
      for (final s in students) {
        final allGrades = await _studentService.getStudentGrades(s.id);
        _gradesByStudent[s.id] = allGrades;
      }

      setState(() {
        _schools = schools;
        _selectedSchool = selectedSchool;
        _students = students;
        _calculateStats();
      });
    } catch (e) {
      // التعامل مع الأخطاء - استخدام debugPrint بدلاً من print
      debugPrint('Error loading students: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onSchoolChanged(String? schoolId) async {
    if (schoolId == null) return;
    final school = _schools.firstWhere((s) => s.id == schoolId);
    setState(() {
      _selectedSchool = school;
      _students = [];
      _gradesByStudent.clear();
      _isLoading = true;
    });

    List<Student> students = [];
    students = await _studentService.getStudentsBySchool(schoolId);

    _gradesByStudent.clear();
    for (final s in students) {
      final allGrades = await _studentService.getStudentGrades(s.id);
      _gradesByStudent[s.id] = allGrades;
    }

    setState(() {
      _students = students;
      _calculateStats();
      _isLoading = false;
    });
  }

  // تم إزالة تغيير الشعبة. الاعتماد فقط على المدرسة.

  void _calculateStats() {
    double total = 0;
    int count = 0;
    _excellentCount = 0;
    _goodCount = 0;
    _passCount = 0;
    _failCount = 0;

    for (final entry in _gradesByStudent.entries) {
      List<Grade> matching;
      if (_selectedGradeType == 'monthly') {
        final monthIndex = _monthLabelToIndex(_selectedMonthLabel);
        matching = entry.value.where((g) {
          if (g.gradeType != 'monthly') return false;
          final data = g.additionalData ?? {};
          return data['term'] == _selectedTerm && data['month'] == monthIndex;
        }).toList()..sort((a, b) => b.date.compareTo(a.date));
      } else {
        matching = entry.value.where((g) => g.gradeType == 'daily').toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      }
      if (matching.isNotEmpty) {
        final gradePercent =
            (matching.first.score / matching.first.maxScore) * 100.0;
        total += gradePercent;
        count++;
        if (gradePercent >= 90) {
          _excellentCount++;
        } else if (gradePercent >= 80) {
          _goodCount++;
        } else if (gradePercent >= 60) {
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

  Future<void> _updateMonthlyGrade(
    String studentId,
    String term,
    int monthIndex,
    double score,
  ) async {
    final grades = _gradesByStudent[studentId] ?? [];
    grades.sort((a, b) => b.date.compareTo(a.date));
    Grade? existing;
    for (final g in grades) {
      if (g.gradeType == 'monthly') {
        final data = g.additionalData ?? {};
        if (data['term'] == term && data['month'] == monthIndex) {
          existing = g;
          break;
        }
      }
    }

    Grade updated =
        (existing ??
                Grade(
                  id: 'grade_${DateTime.now().millisecondsSinceEpoch}',
                  studentId: studentId,
                  schoolId: '1',
                  subject: 'عام',
                  gradeType: 'monthly',
                  score: score,
                  maxScore: 100.0,
                  date: DateTime.now(),
                  recordedBy: 'teacher_1',
                  recordedAt: DateTime.now(),
                  additionalData: {'term': term, 'month': monthIndex},
                ))
            .copyWith(
              score: score,
              date: DateTime.now(),
              recordedAt: DateTime.now(),
              additionalData: {'term': term, 'month': monthIndex},
              gradeType: 'monthly',
              subject: 'عام',
            );

    bool ok;
    if (existing != null) {
      ok = await _studentService.updateGrade(updated);
      if (ok) {
        final idx = grades.indexWhere((g) => g.id == existing!.id);
        if (idx != -1) grades[idx] = updated;
      }
    } else {
      ok = await _studentService.addGrade(updated);
      if (ok) grades.add(updated);
    }
    if (ok) {
      setState(() {
        _gradesByStudent[studentId] = grades;
        _calculateStats();
      });
    }
  }

  Future<void> _addGradeDialog(Student student) async {
    final formKey = GlobalKey<FormState>();
    double value = 0;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppConfig.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConfig.borderRadius * 1.5),
        ),
      ),
      builder: (ctx) {
        final media = MediaQuery.of(ctx);
        final edge = EdgeInsets.only(
          bottom: media.viewInsets.bottom + AppConfig.spacingLG,
          left: AppConfig.spacingLG,
          right: AppConfig.spacingLG,
          top: AppConfig.spacingLG,
        );
        final title = _selectedGradeType == 'monthly'
            ? 'إضافة امتحان شهري'
            : 'إضافة امتحان يومي';

        final controller = TextEditingController(text: '0');

        void syncFromText(String t) {
          final v = double.tryParse(t);
          if (v != null) {
            value = v.clamp(0, 100).toDouble();
          }
        }

        return Padding(
          padding: edge,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$title - ${student.fullName}',
                        style: GoogleFonts.cairo(
                          fontSize: AppConfig.fontSizeXLarge,
                          fontWeight: FontWeight.bold,
                          color: AppConfig.textPrimaryColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close),
                      color: AppConfig.textSecondaryColor,
                      tooltip: 'إغلاق',
                    ),
                  ],
                ),
                const SizedBox(height: AppConfig.spacingMD),
                Text(
                  'الدرجة (0 - 100)',
                  style: GoogleFonts.cairo(
                    fontSize: AppConfig.fontSizeSmall,
                    fontWeight: FontWeight.w600,
                    color: AppConfig.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'أدخل الدرجة من 100',
                    filled: true,
                    fillColor: AppConfig.surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (t) {
                    final v = double.tryParse(t ?? '');
                    if (v == null) return 'يرجى إدخال رقم صحيح';
                    if (v < 0 || v > 100) return 'القيمة يجب أن تكون بين 0 و 100';
                    return null;
                  },
                  onChanged: (t) => setState(() => syncFromText(t)),
                ),
                const SizedBox(height: AppConfig.spacingMD),
                SliderTheme(
                  data: SliderTheme.of(ctx).copyWith(
                    activeTrackColor: AppConfig.primaryColor,
                    thumbColor: AppConfig.secondaryColor,
                    overlayColor: AppConfig.secondaryColor.withValues(alpha: 0.2),
                  ),
                  child: StatefulBuilder(
                    builder: (context, setSt) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Slider(
                            value: value.clamp(0, 100).toDouble(),
                            min: 0,
                            max: 100,
                            divisions: 100,
                            label: value.toStringAsFixed(0),
                            onChanged: (v) {
                              setSt(() => value = v);
                              controller.text = v.toStringAsFixed(0);
                            },
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              '${value.toStringAsFixed(0)} / 100',
                              style: GoogleFonts.cairo(
                                fontSize: AppConfig.fontSizeSmall,
                                color: AppConfig.textSecondaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppConfig.spacingLG),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppConfig.borderColor),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConfig.spacingMD,
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w600,
                            color: AppConfig.textPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConfig.spacingMD),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (!(formKey.currentState?.validate() ?? false)) return;
                          final v = double.tryParse(controller.text) ?? value;
                          final double grade = v.clamp(0, 100).toDouble();
                          if (_selectedGradeType == 'monthly') {
                            await _updateMonthlyGrade(
                              student.id,
                              _selectedTerm,
                              _monthLabelToIndex(_selectedMonthLabel),
                              grade,
                            );
                          } else {
                            await _updateDailyGrade(student.id, grade);
                          }
                          if (!ctx.mounted) return;
                          Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConfig.secondaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConfig.spacingMD,
                          ),
                          elevation: AppConfig.buttonElevation,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(
                          'حفظ',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteLatestGrade(String studentId) async {
    final grades = _gradesByStudent[studentId] ?? [];
    List<Grade> filtered;
    if (_selectedGradeType == 'monthly') {
      final monthIndex = _monthLabelToIndex(_selectedMonthLabel);
      filtered = grades.where((g) {
        if (g.gradeType != 'monthly') return false;
        final data = g.additionalData ?? {};
        return data['term'] == _selectedTerm && data['month'] == monthIndex;
      }).toList()..sort((a, b) => b.date.compareTo(a.date));
    } else {
      filtered = grades.where((g) => g.gradeType == 'daily').toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
    if (filtered.isEmpty) return;
    final latest = filtered.first;
    final ok = await _studentService.deleteGrade(latest.id);
    if (ok) {
      setState(() {
        grades.removeWhere((g) => g.id == latest.id);
        _gradesByStudent[studentId] = grades;
        _calculateStats();
      });
    }
  }

  @override
  void dispose() {
    _saveButtonController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  Future<Uint8List> _buildGradesPdfBytes() async {
    final doc = pw.Document();
    final term = _selectedGradeType == 'monthly' ? _selectedTerm : 'يومي';
    final monthLabel = _selectedGradeType == 'monthly' ? _selectedMonthLabel : '';
    final headers = ['الرقم', 'اسم الطالب', 'الدرجة', 'من', 'النسبة %'];

    // Try to load Arabic fonts; prefer assets/fonts/, fallback to project root
    pw.Font? regularFont;
    pw.Font? boldFont;
    Future<pw.Font?> _tryLoad(String path) async {
      try {
        final data = await rootBundle.load(path);
        return pw.Font.ttf(data);
      } catch (_) {
        return null;
      }
    }
    regularFont = await _tryLoad('assets/fonts/Cairo-Regular.ttf')
        ?? await _tryLoad('Cairo-Regular.ttf');
    boldFont = await _tryLoad('assets/fonts/Cairo-Bold.ttf')
        ?? await _tryLoad('Cairo-Bold.ttf');
    if (boldFont == null && regularFont != null) {
      boldFont = regularFont; // fallback
    }

    List<List<String>> rows = [];
    for (final s in _students) {
      final grades = (_gradesByStudent[s.id] ?? []).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      Grade? g;
      if (_selectedGradeType == 'monthly') {
        final monthIndex = _monthLabelToIndex(_selectedMonthLabel);
        for (final x in grades) {
          if (x.gradeType == 'monthly') {
            final data = x.additionalData ?? {};
            if (data['term'] == _selectedTerm && data['month'] == monthIndex) {
              g = x;
              break;
            }
          }
        }
      } else {
        final daily = grades.where((x) => x.gradeType == 'daily');
        g = daily.isNotEmpty ? daily.first : null;
      }
      if (g != null) {
        final percent = ((g.score / g.maxScore) * 100).toStringAsFixed(0);
        rows.add([
          s.studentId,
          s.fullName,
          g.score.toStringAsFixed(0),
          g.maxScore.toStringAsFixed(0),
          percent,
        ]);
      } else {
        rows.add([s.studentId, s.fullName, '-', '-', '-']);
      }
    }

    final pageTheme = (regularFont != null && boldFont != null)
        ? pw.PageTheme(
            textDirection: pw.TextDirection.rtl,
            theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
          )
        : const pw.PageTheme(
            textDirection: pw.TextDirection.rtl,
          );

    doc.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('تقرير الدرجات', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text('المدرسة: ${_selectedSchool?.name ?? '-'}'),
              pw.Text('النوع: ${_gradeTypeLabels[_selectedGradeType]} ${monthLabel.isNotEmpty ? ' - $monthLabel' : ''} ($term)'),
              pw.SizedBox(height: 12),
              pw.TableHelper.fromTextArray(
                headers: headers,
                data: rows,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                border: null,
                cellAlignment: pw.Alignment.centerRight,
              ),
              pw.SizedBox(height: 12),
              pw.Text('متوسط الصف: ${_classAverage.toStringAsFixed(1)}%  | ممتاز: $_excellentCount  جيد: $_goodCount  مقبول: $_passCount  راسب: $_failCount'),
            ],
          ),
        ],
      ),
    );

    return doc.save();
  }

  Future<void> _printGradesReport() async {
    await Printing.layoutPdf(onLayout: (format) async => await _buildGradesPdfBytes());
  }

  Future<void> _shareGradesReport() async {
    final bytes = await _buildGradesPdfBytes();
    await Printing.sharePdf(bytes: bytes, filename: 'grades_report.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
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
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined, color: Colors.white),
            onPressed: _printGradesReport,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: _shareGradesReport,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppConfig.primaryColor,
                ),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final isPhone = width < 600;
                final contentPadding = EdgeInsets.all(
                  width > 1000 ? AppConfig.spacingLG : AppConfig.spacingMD,
                );
                // Reserve bottom padding so content doesn't hide behind fixed button.
                final extraBottomPadding = media.viewPadding.bottom + 96.0;
                return Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: contentPadding.copyWith(
                        bottom: (contentPadding.bottom) + extraBottomPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSelectionAndFiltersSection(),
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
                        ],
                      ),
                    ),
                    // زر الحفظ مثبت بالأسفل
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SafeArea(
                          minimum: EdgeInsets.only(
                            left: isPhone
                                ? AppConfig.spacingMD
                                : AppConfig.spacingLG,
                            right: isPhone
                                ? AppConfig.spacingMD
                                : AppConfig.spacingLG,
                            bottom: AppConfig.spacingMD,
                          ),
                          child: AnimatedBuilder(
                            animation: _saveButtonScale,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _saveButtonScale.value,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: width > 700
                                        ? 420
                                        : double.infinity,
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _saveGrades,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppConfig.secondaryColor,
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
                                        shadowColor: AppConfig.secondaryColor
                                            .withValues(alpha: 0.3),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.save_outlined,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'حفظ الدرجات',
                                              style: GoogleFonts.cairo(
                                                fontSize:
                                                    AppConfig.fontSizeLarge,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildSelectionAndFiltersSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 600;
        final double gap = AppConfig.spacingMD;
        final double itemWidth = isCompact ? width : (width - gap) / 2;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
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
                  'اختيار المدرسة',
                  style: GoogleFonts.cairo(
                    fontSize: AppConfig.fontSizeXLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConfig.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppConfig.spacingLG),
                Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedSchool?.id,
                        decoration: InputDecoration(
                          labelText: 'اختر المدرسة',
                          labelStyle: GoogleFonts.cairo(
                            color: AppConfig.textSecondaryColor,
                          ),
                          filled: true,
                          fillColor: AppConfig.surfaceColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppConfig.borderRadius,
                            ),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: _schools
                            .map(
                              (s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(
                                  s.name,
                                  style: GoogleFonts.cairo(
                                    color: AppConfig.textPrimaryColor,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => _onSchoolChanged(value),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppConfig.spacingLG),

                Text(
                  'الفلاتر',
                  style: GoogleFonts.cairo(
                    fontSize: AppConfig.fontSizeXLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConfig.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppConfig.spacingLG),
                Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedGradeType,
                        decoration: InputDecoration(
                          labelText: 'نوع الدرجة',
                          labelStyle: GoogleFonts.cairo(
                            color: AppConfig.textSecondaryColor,
                          ),
                          filled: true,
                          fillColor: AppConfig.surfaceColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppConfig.borderRadius,
                            ),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: _gradeTypeLabels.entries
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(
                                  e.value,
                                  style: GoogleFonts.cairo(
                                    color: AppConfig.textPrimaryColor,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedGradeType = value;
                            _calculateStats();
                          });
                        },
                      ),
                    ),
                    if (_selectedGradeType == 'monthly')
                      SizedBox(
                        width: itemWidth,
                        child: _buildDropdown(
                          'الشهر',
                          _selectedMonthLabel,
                          _months,
                          (value) {
                            setState(() {
                              _selectedMonthLabel = value!;
                              _calculateStats();
                            });
                          },
                        ),
                      ),
                    if (_selectedGradeType == 'monthly')
                      SizedBox(
                        width: itemWidth,
                        child: _buildDropdown(
                          'الفصل الدراسي',
                          _selectedTerm,
                          _terms,
                          (value) {
                            setState(() {
                              _selectedTerm = value!;
                              _calculateStats();
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
      },
    );
  }

  Widget _buildStatsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final gap = AppConfig.spacingSM;
        // target card width responsive
        double targetWidth;
        if (width >= 1200) {
          targetWidth = (width - gap * 3) / 4; // 4 per row
        } else if (width >= 900) {
          targetWidth = (width - gap * 2) / 3; // 3 per row
        } else if (width >= 600) {
          targetWidth = (width - gap) / 2; // 2 per row
        } else {
          targetWidth = width; // 1 per row
        }

        final cards = <Widget>[
          _buildStatCard(
            'متوسط الدرجات',
            _classAverage.toStringAsFixed(1),
            Icons.analytics_outlined,
            AppConfig.primaryColor,
          ),
          _buildStatCard(
            'ممتاز',
            _excellentCount.toString(),
            Icons.star_outlined,
            AppConfig.successColor,
          ),
          _buildStatCard(
            'جيد',
            _goodCount.toString(),
            Icons.thumb_up_outlined,
            AppConfig.infoColor,
          ),
          _buildStatCard(
            'مقبول',
            _passCount.toString(),
            Icons.check_circle_outline,
            AppConfig.warningColor,
          ),
          _buildStatCard(
            'راسب',
            _failCount.toString(),
            Icons.warning_amber_outlined,
            AppConfig.errorColor,
          ),
        ];

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
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
                Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: cards
                      .map((c) => SizedBox(width: targetWidth, child: c))
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: AppConfig.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: AppConfig.fontSizeSmall,
                color: AppConfig.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsGradesSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
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
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: AppConfig.spacingMD,
                  runSpacing: AppConfig.spacingSM,
                  alignment: WrapAlignment.spaceBetween,
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
                );
              },
            ),
            const SizedBox(height: AppConfig.spacingLG),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _students.length,
              separatorBuilder: (context, index) =>
                  Divider(color: AppConfig.borderColor, height: 1),
              itemBuilder: (context, index) {
                final student = _students[index];
                List<Grade> currentList;
                if (_selectedGradeType == 'monthly') {
                  final monthIndex = _monthLabelToIndex(_selectedMonthLabel);
                  currentList = (_gradesByStudent[student.id] ?? []).where((g) {
                    if (g.gradeType != 'monthly') return false;
                    final data = g.additionalData ?? {};
                    return data['term'] == _selectedTerm &&
                        data['month'] == monthIndex;
                  }).toList()..sort((a, b) => b.date.compareTo(a.date));
                } else {
                  currentList =
                      (_gradesByStudent[student.id] ?? [])
                          .where((g) => g.gradeType == 'daily')
                          .toList()
                        ..sort((a, b) => b.date.compareTo(a.date));
                }
                final currentGrade = currentList.isNotEmpty
                    ? (currentList.first.score / currentList.first.maxScore) *
                          100.0
                    : 0.0;

                return LayoutBuilder(
                  builder: (context, itemC) {
                    final w = itemC.maxWidth;
                    final isTight = w < 520;
                    final inputWidth = w >= 900
                        ? 120.0
                        : (w >= 700 ? 100.0 : 80.0);
                    final title = Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: AppConfig.primaryColor.withValues(
                            alpha: 0.1,
                          ),
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
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  student.fullName,
                                  style: GoogleFonts.cairo(
                                    fontSize: AppConfig.fontSizeMedium,
                                    fontWeight: FontWeight.bold,
                                    color: AppConfig.textPrimaryColor,
                                  ),
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
                      ],
                    );

                    final gradeInput = SizedBox(
                      width: inputWidth,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppConfig.borderColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppConfig.primaryColor,
                            ),
                          ),
                        ),
                        initialValue: currentGrade.toStringAsFixed(0),
                        onFieldSubmitted: (value) async {
                          double? grade = double.tryParse(value);
                          if (grade != null && grade >= 0 && grade <= 100) {
                            await _updateMonthlyGrade(
                              student.id,
                              _selectedTerm,
                              _monthLabelToIndex(_selectedMonthLabel),
                              grade,
                            );
                          }
                        },
                      ),
                    );

                    final gradeColor = _getGradeColor(currentGrade);
                    final gradeChip = Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: gradeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: gradeColor),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _getGradeText(currentGrade),
                          style: GoogleFonts.cairo(
                            fontSize: AppConfig.fontSizeSmall,
                            color: gradeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );

                    final actions = Wrap(
                      spacing: AppConfig.spacingSM,
                      children: [
                        IconButton(
                          tooltip: 'إضافة',
                          icon: const Icon(Icons.add_circle_outline),
                          color: AppConfig.infoColor,
                          onPressed: () => _addGradeDialog(student),
                        ),
                        IconButton(
                          tooltip: 'حذف آخر درجة',
                          icon: const Icon(Icons.delete_outline),
                          color: AppConfig.errorColor,
                          onPressed: () => _deleteLatestGrade(student.id),
                        ),
                      ],
                    );

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(AppConfig.spacingMD),
                      decoration: BoxDecoration(
                        color: index % 2 == 0
                            ? AppConfig.backgroundColor
                            : AppConfig.cardColor,
                        borderRadius: BorderRadius.circular(
                          AppConfig.borderRadius / 2,
                        ),
                      ),
                      child: isTight
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                title,
                                const SizedBox(height: AppConfig.spacingSM),
                                Wrap(
                                  spacing: AppConfig.spacingSM,
                                  runSpacing: AppConfig.spacingSM,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [gradeInput, gradeChip, actions],
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(child: title),
                                const SizedBox(width: AppConfig.spacingSM),
                                gradeInput,
                                const SizedBox(width: AppConfig.spacingSM),
                                gradeChip,
                                const SizedBox(width: AppConfig.spacingSM),
                                actions,
                              ],
                            ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
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
    if (grade >= 60) return AppConfig.warningColor;
    return AppConfig.errorColor;
  }

  String _getGradeText(double grade) {
    if (grade >= 90) return 'ممتاز';
    if (grade >= 80) return 'جيد جداً';
    if (grade >= 60) return 'مقبول';
    return 'راسب';
  }

  int _monthLabelToIndex(String label) {
    switch (label) {
      case 'الشهر الأول':
        return 1;
      case 'الشهر الثاني':
        return 2;
      case 'الشهر الثالث':
        return 3;
      default:
        return 1;
    }
  }
}
