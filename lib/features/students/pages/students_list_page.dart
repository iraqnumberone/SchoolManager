import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/app_config.dart';
import 'package:school_app/school_management/models/school.dart';
import 'package:school_app/school_management/services/school_service.dart';
import 'package:school_app/student_management/services/student_service.dart';
import 'package:school_app/features/students/pages/school_students_page.dart';

class StudentsListPage extends StatefulWidget {
  const StudentsListPage({super.key});

  @override
  State<StudentsListPage> createState() => _StudentsListPageState();
}

class _StudentsListPageState extends State<StudentsListPage> {
  List<School> _schools = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  Future<void> _loadSchools() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize demo data if needed
      final schoolService = SchoolService.instance;
      await schoolService.initializeDemoData();
      
      // Initialize student demo data
      final studentService = StudentService();
      await studentService.initializeDemoStudents();
      
      // Load schools
      final schools = await schoolService.getSchools();

      if (mounted) {
        setState(() {
          _schools = schools;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في تحميل بيانات المدارس: $e')),
        );
      }
    }
  }

  List<School> get _filteredSchools {
    if (_searchQuery.isEmpty) {
      return _schools;
    }
    return _schools.where((school) =>
      school.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      school.address.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadSchools,
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
                hintText: 'البحث في المدارس...',
                hintStyle: GoogleFonts.cairo(
                  color: AppConfig.textSecondaryColor,
                  fontSize: AppConfig.fontSizeMedium,
                ),
                prefixIcon: const Icon(Icons.search, color: AppConfig.textSecondaryColor),
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // قائمة المدارس
          Expanded(
            child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppConfig.primaryColor,
                  ),
                )
              : _filteredSchools.isEmpty
                ? _buildEmptyState(Icons.school_outlined, 'لا توجد مدارس متاحة')
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredSchools.length,
                    itemBuilder: (context, index) {
                      final school = _filteredSchools[index];
                      return _buildSchoolCard(school);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _filteredSchools.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                // يمكن إضافة منطق إضافة مدرسة جديدة هنا إذا لزم الأمر
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'يجب إضافة مدارس أولاً قبل إضافة الطلاب',
                      style: GoogleFonts.cairo(color: Colors.white),
                    ),
                    backgroundColor: AppConfig.warningColor,
                  ),
                );
              },
              backgroundColor: AppConfig.secondaryColor,
              foregroundColor: Colors.white,
              elevation: AppConfig.buttonElevation,
              icon: const Icon(Icons.school),
              label: Text(
                'إضافة مدرسة أولاً',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState(IconData icon, String text) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).hintColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Theme.of(context).hintColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolCard(School school) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () => _navigateToSchoolStudents(school),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.spacingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConfig.spacingSM),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withAlpha(25), // ~10% opacity
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Icon(
                      Icons.school,
                      color: AppConfig.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppConfig.spacingMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          school.name,
                          style: GoogleFonts.cairo(
                            fontSize: AppConfig.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                            color: AppConfig.textPrimaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppConfig.spacingXS),
                        Text(
                          school.address,
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
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppConfig.textSecondaryColor,
                  ),
                ],
              ),
              const SizedBox(height: AppConfig.spacingSM),
              Row(
                children: [
                  _buildInfoChip('${school.studentCount} طالب', Icons.person),
                  const SizedBox(width: AppConfig.spacingXS),
                  _buildInfoChip('3 شعبة', Icons.class_),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSchoolStudents(School school) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchoolStudentsPage(school: school),
      ),
    );
  }
}
