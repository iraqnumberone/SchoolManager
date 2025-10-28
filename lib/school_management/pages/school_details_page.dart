import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/school.dart';
import 'package:uuid/uuid.dart';
import '../../student_management/models/student.dart';
import '../../core/app_config.dart'; // Added to resolve undefined AppConfig errors
import '../services/school_service.dart'; // Ensure SchoolService is imported
import '../models/school_stage.dart';
import '../models/class_group.dart';

class SchoolDetailsPage extends StatefulWidget {
  final School school;
  const SchoolDetailsPage({super.key, required this.school});

  @override
  State<SchoolDetailsPage> createState() => _SchoolDetailsPageState();
}

class _SchoolDetailsPageState extends State<SchoolDetailsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.school.name,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'قائمة الطلاب في ${widget.school.name}',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w700,
              fontSize: AppConfig.fontSizeLarge,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConfig.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppConfig.borderColor.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'أضف طالباً جديداً لهذه المدرسة',
                    style: GoogleFonts.cairo(
                      fontSize: AppConfig.fontSizeMedium,
                      color: AppConfig.textSecondaryColor,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddStudentSheet(context, widget.school),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: Text(
                    'إضافة طالب',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStudentSheet(context, widget.school),
        icon: const Icon(Icons.person_add_alt_1),
        label: Text('إضافة طالب', style: GoogleFonts.cairo()),
        backgroundColor: AppConfig.secondaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class AddStudentForm extends StatefulWidget {
  final School school;
  const AddStudentForm({super.key, required this.school});

  @override
  State<AddStudentForm> createState() => _AddStudentFormState();
}

class _AddStudentFormState extends State<AddStudentForm> {
  List<SchoolStage> stages = [];
  List<ClassGroup> groups = [];
  String? selectedStageId;
  String? selectedGroupId;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController familyNameController = TextEditingController();
  String? selectedGender;
  final FocusNode _fn1 = FocusNode();
  final FocusNode _fn2 = FocusNode();
  final FocusNode _fn3 = FocusNode();
  final FocusNode _fn4 = FocusNode();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    // Ensure default stages (متوسط + إعدادي) and 5 sections per stage exist
    await SchoolService.instance.ensureDefaultStagesAndGroups(widget.school.id);
    await _loadStages();
  }

  Future<void> _loadStages() async {
    final data = await SchoolService.instance.getStagesBySchool(
      widget.school.id,
    );
    if (!mounted) return;
    setState(() {
      stages = data;
    });
  }

  Future<void> _loadGroups(String stageId) async {
    final data = await SchoolService.instance.getClassGroupsByStage(stageId);
    if (!mounted) return;
    setState(() {
      groups = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // First name
          TextFormField(
            controller: firstNameController,
            focusNode: _fn1,
            decoration: InputDecoration(
              labelText: 'الاسم الأول',
              labelStyle: GoogleFonts.cairo(
                color: AppConfig.textSecondaryColor,
              ),
            ),
            style: GoogleFonts.cairo(),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_fn2),
            validator: (v) =>
                v?.isEmpty == true ? 'يرجى إدخال الاسم الأول' : null,
          ),

          // Middle name
          TextFormField(
            controller: middleNameController,
            focusNode: _fn2,
            decoration: InputDecoration(
              labelText: 'الاسم الثاني',
              labelStyle: GoogleFonts.cairo(
                color: AppConfig.textSecondaryColor,
              ),
            ),
            style: GoogleFonts.cairo(),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_fn3),
            validator: (v) =>
                v?.isEmpty == true ? 'يرجى إدخال الاسم الثاني' : null,
          ),

          // Last name
          TextFormField(
            controller: lastNameController,
            focusNode: _fn3,
            decoration: InputDecoration(
              labelText: 'الاسم الثالث',
              labelStyle: GoogleFonts.cairo(
                color: AppConfig.textSecondaryColor,
              ),
            ),
            style: GoogleFonts.cairo(),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_fn4),
            validator: (v) =>
                v?.isEmpty == true ? 'يرجى إدخال الاسم الثالث' : null,
          ),

          // Family name
          TextFormField(
            controller: familyNameController,
            focusNode: _fn4,
            decoration: InputDecoration(
              labelText: 'اسم العائلة',
              labelStyle: GoogleFonts.cairo(
                color: AppConfig.textSecondaryColor,
              ),
            ),
            style: GoogleFonts.cairo(),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
            validator: (v) =>
                v?.isEmpty == true ? 'يرجى إدخال اسم العائلة' : null,
          ),

          // Stage
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'المرحلة',
              labelStyle: GoogleFonts.cairo(
                color: AppConfig.textSecondaryColor,
              ),
            ),
            initialValue: selectedStageId,
            items: stages
                .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                .toList(),
            onChanged: (value) async {
              setState(() {
                selectedStageId = value;
                selectedGroupId = null;
                groups = [];
              });
              if (value != null) {
                await _loadGroups(value);
              }
            },
            validator: (v) => v == null ? 'يرجى اختيار المرحلة' : null,
          ),

          // Group
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'الشعبة',
              labelStyle: GoogleFonts.cairo(
                color: AppConfig.textSecondaryColor,
              ),
            ),
            initialValue: selectedGroupId,
            items: groups
                .map((g) => DropdownMenuItem(value: g.id, child: Text(g.name)))
                .toList(),
            onChanged: (value) => setState(() => selectedGroupId = value),
            validator: (v) => v == null ? 'يرجى اختيار الشعبة' : null,
          ),

          // Gender
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'النوع',
              labelStyle: GoogleFonts.cairo(
                color: AppConfig.textSecondaryColor,
              ),
            ),
            initialValue: selectedGender,
            items: const [
              DropdownMenuItem(value: 'male', child: Text('ذكر')),
              DropdownMenuItem(value: 'female', child: Text('أنثى')),
            ],
            onChanged: (v) => setState(() => selectedGender = v),
            validator: (v) => v == null ? 'يرجى اختيار النوع' : null,
          ),

          // Save button
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate() &&
                  selectedStageId != null &&
                  selectedGroupId != null &&
                  selectedGender != null) {
                final fullName =
                    '${firstNameController.text} ${middleNameController.text} ${lastNameController.text} ${familyNameController.text}';
                final newStudent = Student(
                  id: Uuid().v4(),
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  fullName: fullName,
                  studentId: DateTime.now().millisecondsSinceEpoch.toString(),
                  birthDate: DateTime.now(),
                  gender: selectedGender!,
                  address: '',
                  phone: '',
                  parentPhone: '',
                  schoolId: widget.school.id,
                  stageId: selectedStageId!,
                  classGroupId: selectedGroupId!,
                  status: 'active',
                  photo: '',
                  enrollmentDate: DateTime.now(),
                  additionalInfo: {},
                );
                await SchoolService.instance.addStudent(newStudent);
                if (!mounted) return;
                // Also guard the local BuildContext specifically
                if (!context.mounted) return;
                // Capture messenger before popping to avoid using a disposed context
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(context).pop();
                // Schedule snackbar after pop in next frame
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم إضافة الطالب بنجاح',
                        style: GoogleFonts.cairo(color: Colors.white),
                      ),
                      backgroundColor: AppConfig.successColor,
                    ),
                  );
                });
              }
            },
            child: Text('حفظ الطالب'),
          ),
        ],
      ),
    );
  }
}

void _showAddStudentSheet(BuildContext context, School school) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppConfig.cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      final bottomInset = MediaQuery.of(context).viewInsets.bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'إضافة طالب إلى ${school.name}',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: AppConfig.fontSizeLarge,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AddStudentForm(school: school),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
