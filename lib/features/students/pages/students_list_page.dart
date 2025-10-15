import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/app_config.dart';
import 'package:school_app/school_management/models/school.dart';
import 'package:school_app/school_management/services/school_service.dart';
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
    setState(() {
      _isLoading = true;
    });

    await SchoolService.initializeDemoData();
    final schools = await SchoolService.getAllSchools();

    setState(() {
      _schools = schools;
      _isLoading = false;
    });
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
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(AppConfig.spacingMD),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: AppConfig.textLightColor,
          ),
          const SizedBox(height: AppConfig.spacingLG),
          Text(
            'لا توجد مدارس متاحة',
            style: GoogleFonts.cairo(
              fontSize: AppConfig.fontSizeLarge,
              color: AppConfig.textSecondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConfig.spacingSM),
          Text(
            'أضف مدارس جديدة لتتمكن من إدارة الطلاب',
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

  Widget _buildSchoolCard(School school) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConfig.spacingMD),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          onTap: () {
            _navigateToSchoolStudents(school);
          },
          child: Padding(
            padding: const EdgeInsets.all(AppConfig.spacingLG),
            child: Row(
              children: [
                // شعار المدرسة
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppConfig.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                  ),
                  child: Icon(
                    Icons.school,
                    color: AppConfig.primaryColor,
                    size: 30,
                  ),
                ),

                const SizedBox(width: AppConfig.spacingMD),

                // معلومات المدرسة
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
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppConfig.textSecondaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            school.address,
                            style: GoogleFonts.cairo(
                              fontSize: AppConfig.fontSizeMedium,
                              color: AppConfig.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${school.educationLevel} - شعبة ${school.section}',
                        style: GoogleFonts.cairo(
                          fontSize: AppConfig.fontSizeSmall,
                          color: AppConfig.textLightColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // معلومات الطلاب
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConfig.spacingSM,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppConfig.infoColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                      ),
                      child: Text(
                        '${school.studentCount} طالب',
                        style: GoogleFonts.cairo(
                          fontSize: AppConfig.fontSizeSmall,
                          fontWeight: FontWeight.w600,
                          color: AppConfig.infoColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConfig.spacingSM,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppConfig.successColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                      ),
                      child: Text(
                        '3 شعبة',
                        style: GoogleFonts.cairo(
                          fontSize: AppConfig.fontSizeSmall,
                          fontWeight: FontWeight.w600,
                          color: AppConfig.successColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: AppConfig.spacingSM),

                // أيقونة السهم
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppConfig.textSecondaryColor,
                  size: 16,
                ),
              ],
            ),
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
