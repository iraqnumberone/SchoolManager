import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/app_config.dart';
import 'package:school_app/school_management/models/school.dart';
import 'package:school_app/school_management/services/school_service.dart';

class SchoolsListPage extends StatefulWidget {
  const SchoolsListPage({super.key});

  @override
  State<SchoolsListPage> createState() => _SchoolsListPageState();
}

class _SchoolsListPageState extends State<SchoolsListPage> {
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

    // تهيئة البيانات التجريبية إذا لزم الأمر
    await SchoolService.initializeDemoData();

    final schools = _searchQuery.isEmpty
        ? await SchoolService.getAllSchools()
        : await SchoolService.searchSchools(_searchQuery);

    setState(() {
      _schools = schools;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadSchools();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      appBar: AppBar(
        title: Text(
          'قائمة المدارس',
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
          // شريط البحث المبسط
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
              onChanged: _onSearchChanged,
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
              : _schools.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(AppConfig.spacingMD),
                    itemCount: _schools.length,
                    itemBuilder: (context, index) {
                      return _buildSchoolCard(_schools[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddSchoolDialog();
        },
        backgroundColor: AppConfig.secondaryColor,
        foregroundColor: Colors.white,
        elevation: AppConfig.buttonElevation,
        icon: const Icon(Icons.add),
        label: Text(
          'إضافة مدرسة',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'لا توجد مدارس مضافة بعد'
                : 'لا توجد نتائج للبحث',
            style: GoogleFonts.cairo(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'اضغط على زر الإضافة لبدء إضافة مدرسة جديدة'
                : 'جرب كلمات بحث مختلفة',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolCard(School school) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppConfig.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.school,
                    color: AppConfig.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        school.name,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        school.directorName,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditSchoolDialog(school);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(school);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
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
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20),
                          SizedBox(width: 8),
                          Text('حذف'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    school.address,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  school.phone,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.email, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    school.email,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSchoolDialog() {
    showDialog(
      context: context,
      builder: (context) => const SimpleAddSchoolDialog(),
    ).then((_) => _loadSchools());
  }

  void _showEditSchoolDialog(School school) {
    showDialog(
      context: context,
      builder: (context) => SimpleEditSchoolDialog(school: school),
    ).then((_) => _loadSchools());
  }

  void _showDeleteConfirmation(School school) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تأكيد الحذف',
          style: GoogleFonts.cairo(),
        ),
        content: Text(
          'هل أنت متأكد من حذف مدرسة "${school.name}"؟',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await SchoolService.deleteSchool(school.id);
              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم حذف المدرسة بنجاح',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: AppConfig.successColor,
                  ),
                );
                _loadSchools();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'فشل في حذف المدرسة',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: AppConfig.errorColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.errorColor,
            ),
            child: Text(
              'حذف',
              style: GoogleFonts.cairo(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// حوار إضافة مدرسة جديدة مبسط
class SimpleAddSchoolDialog extends StatefulWidget {
  const SimpleAddSchoolDialog({super.key});

  @override
  State<SimpleAddSchoolDialog> createState() => _SimpleAddSchoolDialogState();
}

class _SimpleAddSchoolDialogState extends State<SimpleAddSchoolDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedEducationLevel = 'ابتدائي';
  final _sectionController = TextEditingController();
  final _studentCountController = TextEditingController();

  bool _isLoading = false;

  final List<String> _educationLevels = ['ابتدائي', 'متوسط', 'ثانوي'];

  @override
  void dispose() {
    _nameController.dispose();
    _sectionController.dispose();
    _studentCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'إضافة مدرسة جديدة',
        style: GoogleFonts.cairo(
          fontSize: AppConfig.fontSizeLarge,
          fontWeight: FontWeight.bold,
          color: AppConfig.textPrimaryColor,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'اسم المدرسة',
                  labelStyle: GoogleFonts.cairo(
                    color: AppConfig.textSecondaryColor,
                    fontSize: AppConfig.fontSizeMedium,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                    borderSide: BorderSide(color: AppConfig.primaryColor),
                  ),
                ),
                style: GoogleFonts.cairo(
                  fontSize: AppConfig.fontSizeMedium,
                  color: AppConfig.textPrimaryColor,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم المدرسة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConfig.spacingMD),
              DropdownButtonFormField<String>(
                value: _selectedEducationLevel,
                decoration: InputDecoration(
                  labelText: 'مرحلة الدراسة',
                  labelStyle: GoogleFonts.cairo(
                    color: AppConfig.textSecondaryColor,
                    fontSize: AppConfig.fontSizeMedium,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                    borderSide: BorderSide(color: AppConfig.primaryColor),
                  ),
                ),
                style: GoogleFonts.cairo(
                  fontSize: AppConfig.fontSizeMedium,
                  color: AppConfig.textPrimaryColor,
                ),
                items: _educationLevels.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEducationLevel = value!;
                  });
                },
              ),
              const SizedBox(height: AppConfig.spacingMD),
              TextFormField(
                controller: _sectionController,
                decoration: InputDecoration(
                  labelText: 'الشعبة',
                  labelStyle: GoogleFonts.cairo(
                    color: AppConfig.textSecondaryColor,
                    fontSize: AppConfig.fontSizeMedium,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                    borderSide: BorderSide(color: AppConfig.primaryColor),
                  ),
                ),
                style: GoogleFonts.cairo(
                  fontSize: AppConfig.fontSizeMedium,
                  color: AppConfig.textPrimaryColor,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الشعبة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConfig.spacingMD),
              TextFormField(
                controller: _studentCountController,
                decoration: InputDecoration(
                  labelText: 'عدد الطلاب',
                  labelStyle: GoogleFonts.cairo(
                    color: AppConfig.textSecondaryColor,
                    fontSize: AppConfig.fontSizeMedium,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                    borderSide: BorderSide(color: AppConfig.primaryColor),
                  ),
                ),
                style: GoogleFonts.cairo(
                  fontSize: AppConfig.fontSizeMedium,
                  color: AppConfig.textPrimaryColor,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال عدد الطلاب';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'يرجى إدخال رقم صحيح أكبر من صفر';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            'إلغاء',
            style: GoogleFonts.cairo(
              color: AppConfig.textSecondaryColor,
              fontSize: AppConfig.fontSizeMedium,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConfig.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConfig.spacingLG,
              vertical: AppConfig.spacingSM,
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'إضافة',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w600,
                    fontSize: AppConfig.fontSizeMedium,
                  ),
                ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final school = School(
      id: 'school_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      address: 'عنوان المدرسة', // قيمة افتراضية
      phone: 'رقم الهاتف', // قيمة افتراضية
      email: 'البريد الإلكتروني', // قيمة افتراضية
      directorName: 'اسم المدير', // قيمة افتراضية
      createdAt: DateTime.now(),
      educationLevel: _selectedEducationLevel,
      section: _sectionController.text.trim(),
      studentCount: int.parse(_studentCountController.text.trim()),
    );

    final success = await SchoolService.addSchool(school);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.of(context).pop();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إضافة المدرسة بنجاح',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppConfig.successColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          ),
        ),
      );
      // إعادة تحميل البيانات
      context.findAncestorStateOfType<_SchoolsListPageState>()?._loadSchools();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل في إضافة المدرسة',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppConfig.errorColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          ),
        ),
      );
    }
  }
}

// حوار تعديل مدرسة مبسط
class SimpleEditSchoolDialog extends StatefulWidget {
  final School school;

  const SimpleEditSchoolDialog({super.key, required this.school});

  @override
  State<SimpleEditSchoolDialog> createState() => _SimpleEditSchoolDialogState();
}

class _SimpleEditSchoolDialogState extends State<SimpleEditSchoolDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedEducationLevel;
  late TextEditingController _sectionController;
  late TextEditingController _studentCountController;

  bool _isLoading = false;

  final List<String> _educationLevels = ['ابتدائي', 'متوسط', 'ثانوي'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.school.name);
    _selectedEducationLevel = widget.school.educationLevel;
    _sectionController = TextEditingController(text: widget.school.section);
    _studentCountController = TextEditingController(text: widget.school.studentCount.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sectionController.dispose();
    _studentCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'تعديل المدرسة',
        style: GoogleFonts.cairo(
          fontSize: AppConfig.fontSizeLarge,
          fontWeight: FontWeight.bold,
          color: AppConfig.textPrimaryColor,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'اسم المدرسة',
                  labelStyle: GoogleFonts.cairo(
                    color: AppConfig.textSecondaryColor,
                    fontSize: AppConfig.fontSizeMedium,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                    borderSide: BorderSide(color: AppConfig.primaryColor),
                  ),
                ),
                style: GoogleFonts.cairo(
                  fontSize: AppConfig.fontSizeMedium,
                  color: AppConfig.textPrimaryColor,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم المدرسة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConfig.spacingMD),
              DropdownButtonFormField<String>(
                value: _selectedEducationLevel,
                decoration: InputDecoration(
                  labelText: 'مرحلة الدراسة',
                  labelStyle: GoogleFonts.cairo(
                    color: AppConfig.textSecondaryColor,
                    fontSize: AppConfig.fontSizeMedium,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                    borderSide: BorderSide(color: AppConfig.primaryColor),
                  ),
                ),
                style: GoogleFonts.cairo(
                  fontSize: AppConfig.fontSizeMedium,
                  color: AppConfig.textPrimaryColor,
                ),
                items: _educationLevels.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEducationLevel = value!;
                  });
                },
              ),
              const SizedBox(height: AppConfig.spacingMD),
              TextFormField(
                controller: _sectionController,
                decoration: InputDecoration(
                  labelText: 'الشعبة',
                  labelStyle: GoogleFonts.cairo(
                    color: AppConfig.textSecondaryColor,
                    fontSize: AppConfig.fontSizeMedium,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                    borderSide: BorderSide(color: AppConfig.primaryColor),
                  ),
                ),
                style: GoogleFonts.cairo(
                  fontSize: AppConfig.fontSizeMedium,
                  color: AppConfig.textPrimaryColor,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الشعبة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConfig.spacingMD),
              TextFormField(
                controller: _studentCountController,
                decoration: InputDecoration(
                  labelText: 'عدد الطلاب',
                  labelStyle: GoogleFonts.cairo(
                    color: AppConfig.textSecondaryColor,
                    fontSize: AppConfig.fontSizeMedium,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
                    borderSide: BorderSide(color: AppConfig.primaryColor),
                  ),
                ),
                style: GoogleFonts.cairo(
                  fontSize: AppConfig.fontSizeMedium,
                  color: AppConfig.textPrimaryColor,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال عدد الطلاب';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'يرجى إدخال رقم صحيح أكبر من صفر';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            'إلغاء',
            style: GoogleFonts.cairo(
              color: AppConfig.textSecondaryColor,
              fontSize: AppConfig.fontSizeMedium,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConfig.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConfig.spacingLG,
              vertical: AppConfig.spacingSM,
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'حفظ التغييرات',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w600,
                    fontSize: AppConfig.fontSizeMedium,
                  ),
                ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final updatedSchool = widget.school.copyWith(
      name: _nameController.text.trim(),
      educationLevel: _selectedEducationLevel,
      section: _sectionController.text.trim(),
      studentCount: int.parse(_studentCountController.text.trim()),
    );

    final success = await SchoolService.updateSchool(updatedSchool);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.of(context).pop();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تحديث المدرسة بنجاح',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppConfig.successColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          ),
        ),
      );
      // إعادة تحميل البيانات
      context.findAncestorStateOfType<_SchoolsListPageState>()?._loadSchools();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل في تحديث المدرسة',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppConfig.errorColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          ),
        ),
      );
    }
  }
}
