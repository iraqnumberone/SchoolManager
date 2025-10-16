import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/app_config.dart';
import 'package:school_app/student_management/models/student.dart';
import 'package:school_app/student_management/services/student_service.dart';
import 'student_report_page.dart';
import 'package:school_app/attendance_management/pages/attendance_page.dart';
import 'grades_page.dart';

class StudentsListPage extends StatefulWidget {
  const StudentsListPage({super.key});

  @override
  State<StudentsListPage> createState() => _StudentsListPageState();
}

class _StudentsListPageState extends State<StudentsListPage> {
  List<Student> _students = [];
  List<Student> _filteredStudents = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    // تهيئة البيانات التجريبية
    await StudentService.initializeDemoStudents();

    // الحصول على الطلاب حسب الفلتر المحدد
    List<Student> students;
    switch (_selectedFilter) {
      case 'المرحلة الأولى':
        students = await StudentService.getStudentsByStage('stage_1');
        break;
      case 'المرحلة الثانية':
        students = await StudentService.getStudentsByStage('stage_2');
        break;
      case 'المرحلة الثالثة':
        students = await StudentService.getStudentsByStage('stage_3');
        break;
      default:
        students = await StudentService.getAllStudents();
    }

    setState(() {
      _students = students;
      _filteredStudents = _applySearchFilter(students);
      _isLoading = false;
    });
  }

  List<Student> _applySearchFilter(List<Student> students) {
    if (_searchQuery.isEmpty) {
      return students;
    }

    final query = _searchQuery.toLowerCase();
    return students.where((student) {
      return student.fullName.toLowerCase().contains(query) ||
          student.studentId.toLowerCase().contains(query) ||
          student.phone.toLowerCase().contains(query);
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredStudents = _applySearchFilter(_students);
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'قائمة الطلاب',
          style: GoogleFonts.cairo(
            fontSize: AppConfig.fontSizeXXLarge,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConfig.primaryColor,
        elevation: AppConfig.cardElevation,
        shadowColor: AppConfig.primaryColor.withValues(alpha: 0.3),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () {
              // الانتقال إلى صفحة إضافة طالب جديد
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث والفلترة
          Container(
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
            child: Column(
              children: [
                // شريط البحث
                TextField(
                  decoration: InputDecoration(
                    hintText: 'البحث عن طالب...',
                    hintStyle: GoogleFonts.cairo(
                      color: AppConfig.textLightColor,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppConfig.primaryColor,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: AppConfig.textLightColor,
                            ),
                            onPressed: () {
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConfig.borderRadius,
                      ),
                      borderSide: BorderSide(color: AppConfig.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConfig.borderRadius,
                      ),
                      borderSide: BorderSide(color: AppConfig.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConfig.borderRadius,
                      ),
                      borderSide: BorderSide(
                        color: AppConfig.primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: AppConfig.backgroundColor,
                  ),
                  onChanged: _onSearchChanged,
                ),

                const SizedBox(height: AppConfig.spacingMD),

                // شريط الفلترة
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('الكل'),
                      _buildFilterChip('المرحلة الأولى'),
                      _buildFilterChip('المرحلة الثانية'),
                      _buildFilterChip('المرحلة الثالثة'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // قائمة الطلاب
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppConfig.primaryColor,
                    ),
                  )
                : _filteredStudents.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _filteredStudents.length,
                    itemBuilder: (context, index) {
                      return _buildStudentCard(_filteredStudents[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // إضافة طالب جديد
        },
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        elevation: AppConfig.buttonElevation,
        icon: const Icon(Icons.person_add),
        label: Text(
          'إضافة طالب',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Container(
      margin: const EdgeInsets.only(left: AppConfig.spacingSM),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.cairo(
            color: isSelected ? Colors.white : AppConfig.textPrimaryColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            _onFilterChanged(label);
          }
        },
        backgroundColor: AppConfig.backgroundColor,
        selectedColor: AppConfig.primaryColor,
        checkmarkColor: Colors.white,
        elevation: 0,
        pressElevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
          side: BorderSide(
            color: isSelected ? AppConfig.primaryColor : AppConfig.borderColor,
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: AppConfig.textLightColor),
          const SizedBox(height: AppConfig.spacingLG),
          Text(
            _searchQuery.isEmpty
                ? 'لا يوجد طلاب مضافون بعد'
                : 'لا توجد نتائج للبحث',
            style: GoogleFonts.cairo(
              fontSize: AppConfig.fontSizeXLarge,
              color: AppConfig.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppConfig.spacingSM),
          Text(
            _searchQuery.isEmpty
                ? 'اضغط على زر الإضافة لبدء إضافة الطلاب'
                : 'جرب كلمات بحث مختلفة',
            style: GoogleFonts.cairo(
              fontSize: AppConfig.fontSizeMedium,
              color: AppConfig.textLightColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
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
          color: AppConfig.borderColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppConfig.spacingMD),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: AppConfig.primaryColor.withValues(alpha: 0.1),
          child: Text(
            student.initials,
            style: GoogleFonts.cairo(
              fontSize: AppConfig.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppConfig.primaryColor,
            ),
          ),
        ),
        title: Text(
          student.fullName,
          style: GoogleFonts.cairo(
            fontSize: AppConfig.fontSizeLarge,
            fontWeight: FontWeight.w600,
            color: AppConfig.textPrimaryColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'رقم الطالب: ${student.studentId}',
              style: GoogleFonts.cairo(
                fontSize: AppConfig.fontSizeMedium,
                color: AppConfig.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'العمر: ${student.age} سنة',
              style: GoogleFonts.cairo(
                fontSize: AppConfig.fontSizeSmall,
                color: AppConfig.textLightColor,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view':
                _showStudentDetails(student);
                break;
              case 'edit':
                // تعديل بيانات الطالب
                break;
              case 'attendance':
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AttendancePage(),
                  ),
                );
                break;
              case 'grades':
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GradesPage(),
                  ),
                );
                break;
              case 'report':
                _showStudentReport(student);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 20),
                  SizedBox(width: 8),
                  Text('عرض التفاصيل'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('تعديل'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'attendance',
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 20),
                  SizedBox(width: 8),
                  Text('الحضور'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'grades',
              child: Row(
                children: [
                  Icon(Icons.grade, size: 20),
                  SizedBox(width: 8),
                  Text('الدرجات'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(
                    Icons.analytics,
                    size: 20,
                    color: AppConfig.primaryColor,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'التقرير',
                    style: GoogleFonts.cairo(
                      color: AppConfig.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          _showStudentDetails(student);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('تصفية الطلاب', style: GoogleFonts.cairo()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'الكل';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _selectedFilter == 'الكل' ? AppConfig.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                      border: Border.all(
                        color: _selectedFilter == 'الكل' ? AppConfig.primaryColor : AppConfig.borderColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedFilter == 'الكل' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: _selectedFilter == 'الكل' ? AppConfig.primaryColor : AppConfig.textSecondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text('الكل', style: GoogleFonts.cairo()),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'المرحلة الأولى';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _selectedFilter == 'المرحلة الأولى' ? AppConfig.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                      border: Border.all(
                        color: _selectedFilter == 'المرحلة الأولى' ? AppConfig.primaryColor : AppConfig.borderColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedFilter == 'المرحلة الأولى' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: _selectedFilter == 'المرحلة الأولى' ? AppConfig.primaryColor : AppConfig.textSecondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text('المرحلة الأولى', style: GoogleFonts.cairo()),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'المرحلة الثانية';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _selectedFilter == 'المرحلة الثانية' ? AppConfig.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                      border: Border.all(
                        color: _selectedFilter == 'المرحلة الثانية' ? AppConfig.primaryColor : AppConfig.borderColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedFilter == 'المرحلة الثانية' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: _selectedFilter == 'المرحلة الثانية' ? AppConfig.primaryColor : AppConfig.textSecondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text('المرحلة الثانية', style: GoogleFonts.cairo()),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'المرحلة الثالثة';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _selectedFilter == 'المرحلة الثالثة' ? AppConfig.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                      border: Border.all(
                        color: _selectedFilter == 'المرحلة الثالثة' ? AppConfig.primaryColor : AppConfig.borderColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedFilter == 'المرحلة الثالثة' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: _selectedFilter == 'المرحلة الثالثة' ? AppConfig.primaryColor : AppConfig.textSecondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text('المرحلة الثالثة', style: GoogleFonts.cairo()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('إلغاء', style: GoogleFonts.cairo()),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _onFilterChanged(_selectedFilter);
                },
                child: Text('تطبيق', style: GoogleFonts.cairo()),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showStudentDetails(Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل الطالب', style: GoogleFonts.cairo()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('الاسم الكامل', student.fullName),
              _buildDetailRow('رقم الطالب', student.studentId),
              _buildDetailRow(
                'تاريخ الميلاد',
                '${student.birthDate.toString().split(' ')[0]} (${student.age} سنة)',
              ),
              _buildDetailRow(
                'الجنس',
                student.gender == 'male' ? 'ذكر' : 'أنثى',
              ),
              _buildDetailRow('العنوان', student.address),
              _buildDetailRow('رقم الهاتف', student.phone),
              if (student.parentPhone != null)
                _buildDetailRow('هاتف ولي الأمر', student.parentPhone!),
              _buildDetailRow(
                'تاريخ التسجيل',
                student.enrollmentDate.toString().split(' ')[0],
              ),
              _buildDetailRow(
                'الحالة',
                student.status == AppConfig.studentStatusActive
                    ? 'نشط'
                    : 'غير نشط',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('إغلاق', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  void _showStudentReport(Student student) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentReportPage(studentId: student.id),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.cairo(
                fontSize: AppConfig.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: AppConfig.textSecondaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: AppConfig.fontSizeMedium,
                color: AppConfig.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
