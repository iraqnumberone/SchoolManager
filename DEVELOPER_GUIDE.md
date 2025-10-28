# دليل المطور - نظام إدارة المدرسة الذكية

## 📖 نظرة عامة

هذا الدليل يوضح كيفية استخدام قاعدة البيانات SQLite والخدمات (Services) في التطبيق.

## 🗄️ قاعدة البيانات (DatabaseHelper)

### الموقع
`lib/core/database_helper.dart`

### الاستخدام

```dart
// الحصول على مثيل قاعدة البيانات
final dbHelper = DatabaseHelper();
final db = await dbHelper.database;

// تهيئة البيانات التجريبية
await dbHelper.initializeDemoData();

// مزامنة البيانات
await dbHelper.syncStudentSchoolLinks();

// تنظيف الذاكرة المؤقتة
await dbHelper.clearAppCache();
```

### الجداول المتاحة

#### 1. جدول المدارس (schools)
```sql
CREATE TABLE schools (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT NOT NULL,
  logo TEXT,
  director_name TEXT,
  is_active INTEGER DEFAULT 1,
  education_level TEXT,
  section TEXT,
  student_count INTEGER DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
```

#### 2. جدول المراحل الدراسية (school_stages)
```sql
CREATE TABLE school_stages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  school_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  sort_order INTEGER DEFAULT 0,
  is_active INTEGER DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (school_id) REFERENCES schools (id) ON DELETE CASCADE
)
```

#### 3. جدول الشعب (class_groups)
```sql
CREATE TABLE class_groups (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  school_id INTEGER NOT NULL,
  stage_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  capacity INTEGER DEFAULT 30,
  current_students INTEGER DEFAULT 0,
  teacher_id INTEGER,
  teacher_name TEXT,
  is_active INTEGER DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (school_id) REFERENCES schools (id) ON DELETE CASCADE,
  FOREIGN KEY (stage_id) REFERENCES school_stages (id) ON DELETE CASCADE
)
```

#### 4. جدول الطلاب (students)
```sql
CREATE TABLE students (
  id TEXT PRIMARY KEY,
  firstName TEXT,
  lastName TEXT,
  fullName TEXT,
  studentId TEXT,
  birthDate TEXT,
  gender TEXT,
  address TEXT,
  phone TEXT,
  parentPhone TEXT,
  schoolId TEXT,
  stageId TEXT,
  classGroupId TEXT,
  status TEXT,
  photo TEXT,
  enrollmentDate TEXT,
  additionalInfo TEXT,
  is_active INTEGER DEFAULT 1,
  created_at TEXT,
  updated_at TEXT
)
```

#### 5. جدول المعلمين (teachers)
```sql
CREATE TABLE teachers (
  id TEXT PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  full_name TEXT NOT NULL,
  employee_id TEXT UNIQUE NOT NULL,
  email TEXT,
  phone TEXT,
  national_id TEXT,
  qualification TEXT,
  specialization TEXT,
  school_id TEXT,
  status TEXT,
  hire_date INTEGER,
  profile_image TEXT,
  contact_info TEXT,
  emergency_contact TEXT,
  settings TEXT,
  created_at INTEGER,
  updated_at INTEGER,
  is_active INTEGER DEFAULT 1
)
```

#### 6. جدول الحضور (attendance)
```sql
CREATE TABLE attendance (
  id TEXT PRIMARY KEY,
  studentId TEXT NOT NULL,
  schoolId TEXT NOT NULL,
  date TEXT NOT NULL,
  status TEXT NOT NULL,
  notes TEXT,
  recordedBy TEXT,
  recordedAt TEXT,
  checkInTime TEXT,
  checkOutTime TEXT,
  additionalData TEXT
)
```

#### 7. جدول الدرجات (grades)
```sql
CREATE TABLE grades (
  id TEXT PRIMARY KEY,
  studentId TEXT NOT NULL,
  schoolId TEXT NOT NULL,
  subject TEXT NOT NULL,
  gradeType TEXT NOT NULL,
  score REAL NOT NULL,
  maxScore REAL NOT NULL,
  date TEXT NOT NULL,
  recordedBy TEXT,
  recordedAt TEXT,
  notes TEXT,
  additionalData TEXT
)
```

## 🔧 خدمة المدرسة (SchoolService)

### الموقع
`lib/school_management/services/school_service.dart`

### إنشاء مثيل Singleton

```dart
final schoolService = SchoolService.instance;
```

### العمليات الأساسية

#### إدارة المدارس

```dart
// إضافة مدرسة
final school = School(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  name: 'مدرسة النجاح',
  address: 'بغداد',
  phone: '07701234567',
  email: 'info@school.com',
  directorName: 'أحمد محمد',
  educationLevel: 'متوسط وإعدادي',
  section: 'أ',
  studentCount: 0,
  isActive: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
await schoolService.addSchool(school);

// الحصول على جميع المدارس
final schools = await schoolService.getSchools();

// الحصول على مدرسة بالمعرف
final school = await schoolService.getSchoolById('1');

// تحديث مدرسة
await schoolService.updateSchool(updatedSchool);

// حذف مدرسة (حذف ناعم)
await schoolService.deleteSchool('1');

// البحث عن مدارس
final results = await schoolService.searchSchools('النجاح');
```

#### إدارة المراحل الدراسية

```dart
// إضافة مرحلة
final stage = SchoolStage(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  schoolId: '1',
  name: 'الصف الأول المتوسط',
  order: 1,
  isActive: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
await schoolService.addSchoolStage(stage);

// الحصول على المراحل حسب المدرسة
final stages = await schoolService.getStagesBySchool('1');

// ضمان وجود المراحل والشعب الافتراضية
await schoolService.ensureDefaultStagesAndGroups('1');
```

#### إدارة الشعب الدراسية

```dart
// إضافة شعبة
final classGroup = ClassGroup(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  schoolId: '1',
  stageId: '1',
  name: 'شعبة أ',
  capacity: 40,
  currentStudents: 0,
  teacherId: 'teacher_1',
  teacherName: 'أحمد محمد',
  isActive: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
await schoolService.addClassGroup(classGroup);

// الحصول على الشعب حسب المرحلة
final groups = await schoolService.getClassGroupsByStage('1');

// الحصول على شعبة بالمعرف
final group = await schoolService.getClassGroupById('1');

// تحديث شعبة
await schoolService.updateClassGroup(updatedGroup);

// حذف شعبة
await schoolService.deleteClassGroup('1');
```

#### إدارة الطلاب

```dart
// إضافة طالب
final student = Student(
  id: Uuid().v4(),
  firstName: 'أحمد',
  lastName: 'محمد',
  fullName: 'أحمد محمد',
  studentId: 'S20240001',
  birthDate: DateTime(2008, 1, 1),
  gender: 'ذكر',
  address: 'بغداد',
  phone: '07701234567',
  parentPhone: '07801234567',
  schoolId: '1',
  stageId: '1',
  classGroupId: '1',
  status: 'active',
  enrollmentDate: DateTime.now(),
);
await schoolService.addStudent(student);

// الحصول على جميع الطلاب
final students = await schoolService.getAllStudents();

// الحصول على طلاب حسب المدرسة
final students = await schoolService.getStudentsBySchool('1');

// الحصول على طلاب حسب المرحلة
final students = await schoolService.getStudentsByStage('1');

// الحصول على طلاب حسب الشعبة
final students = await schoolService.getStudentsByClassGroup('1');

// الحصول على طالب بالمعرف
final student = await schoolService.getStudentById('student_1');

// تحديث طالب
await schoolService.updateStudent(updatedStudent);

// حذف طالب
await schoolService.deleteStudent('student_1');

// البحث عن طلاب
final results = await schoolService.searchStudents('أحمد');
```

#### إدارة المعلمين

```dart
// إضافة معلم
final teacher = Teacher(
  id: Uuid().v4(),
  firstName: 'أحمد',
  lastName: 'محمود',
  fullName: 'أحمد محمود',
  employeeId: 'T001',
  email: 't001@school.com',
  phone: '07701234567',
  qualification: 'بكالوريوس',
  specialization: 'الرياضيات',
  schoolId: '1',
  status: 'active',
  hireDate: DateTime.now(),
);
await schoolService.addTeacher(teacher);

// الحصول على معلمين حسب المدرسة
final teachers = await schoolService.getTeachersBySchool('1');

// الحصول على معلم بالمعرف
final teacher = await schoolService.getTeacherById('teacher_1');

// تحديث معلم
await schoolService.updateTeacher(updatedTeacher);

// حذف معلم
await schoolService.deleteTeacher('teacher_1');

// تخصيص معلم لشعبة
await schoolService.assignTeacherToClass(
  teacherId: 'teacher_1',
  classGroupId: '1',
  subjectId: 'math_001',
  academicYear: '2024-2025',
  isHomeroom: true,
);

// الحصول على تخصيصات المعلم
final assignments = await schoolService.getTeacherAssignments('teacher_1');

// الحصول على معلمين حسب الشعبة
final teachers = await schoolService.getTeachersByClass('1');
```

#### الإحصائيات

```dart
// إحصائيات الطلاب
final studentStats = await schoolService.getStudentStats('1');
print('إجمالي الطلاب: ${studentStats['totalStudents']}');
print('توزيع الجنس: ${studentStats['genderDistribution']}');
print('توزيع المراحل: ${studentStats['stageDistribution']}');

// إحصائيات المدرسة الشاملة
final schoolStats = await schoolService.getSchoolStats('1');
print('إجمالي الطلاب: ${schoolStats['totalStudents']}');
print('إجمالي المعلمين: ${schoolStats['totalTeachers']}');
print('إجمالي الشعب: ${schoolStats['totalClassGroups']}');
print('معدل الإشغال: ${schoolStats['occupancyRate']}');
```

#### تهيئة البيانات التجريبية

```dart
// إنشاء بيانات تجريبية كاملة
await schoolService.initializeDemoData();
```

## 🎯 أفضل الممارسات

### 1. استخدام try-catch

```dart
try {
  await schoolService.addStudent(student);
  print('تم إضافة الطالب بنجاح');
} catch (e) {
  print('خطأ في إضافة الطالب: $e');
}
```

### 2. التحقق من null

```dart
final student = await schoolService.getStudentById('1');
if (student != null) {
  print('اسم الطالب: ${student.fullName}');
} else {
  print('الطالب غير موجود');
}
```

### 3. استخدام FutureBuilder في الواجهة

```dart
FutureBuilder<List<Student>>(
  future: schoolService.getStudentsBySchool('1'),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    
    if (snapshot.hasError) {
      return Text('خطأ: ${snapshot.error}');
    }
    
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Text('لا يوجد طلاب');
    }
    
    final students = snapshot.data!;
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return ListTile(
          title: Text(student.fullName),
          subtitle: Text(student.studentId),
        );
      },
    );
  },
)
```

### 4. تحديث الواجهة بعد التغيير

```dart
// في StatefulWidget
await schoolService.addStudent(student);
setState(() {
  // تحديث الواجهة
});
```

## 🔍 استكشاف الأخطاء

### مشاكل شائعة وحلولها

1. **خطأ: قاعدة البيانات غير موجودة**
```dart
// الحل: تأكد من تهيئة قاعدة البيانات
await DatabaseHelper().database;
```

2. **خطأ: الجدول غير موجود**
```dart
// الحل: تحديث إصدار قاعدة البيانات
// في database_helper.dart قم بزيادة databaseVersion
static const int databaseVersion = 5; // زيادة الرقم
```

3. **خطأ: البيانات لا تظهر**
```dart
// الحل: تحقق من حالة is_active
final students = await db.query(
  'students',
  where: 'is_active = ?',
  whereArgs: [1],
);
```

## 📝 ملاحظات مهمة

1. جميع العمليات asynchronous تحتاج `await`
2. استخدم Singleton للخدمات لتجنب مثيلات متعددة
3. الحذف في التطبيق هو "حذف ناعم" (soft delete) يضع `is_active = 0`
4. المعرفات (IDs) تستخدم `String` في الطلاب والمعلمين و `int` في المدارس
5. التواريخ تحفظ كـ `String` بصيغة ISO8601
6. استخدم `Uuid().v4()` لتوليد معرفات فريدة للطلاب والمعلمين

## 🧪 الاختبار

```dart
void main() async {
  // تهيئة قاعدة البيانات للاختبار
  WidgetsFlutterBinding.ensureInitialized();
  
  final schoolService = SchoolService.instance;
  
  // اختبار إضافة مدرسة
  final school = School(/* ... */);
  final result = await schoolService.addSchool(school);
  assert(result == true, 'فشل في إضافة المدرسة');
  
  // اختبار الحصول على المدارس
  final schools = await schoolService.getSchools();
  assert(schools.isNotEmpty, 'لا توجد مدارس');
  
  print('جميع الاختبارات نجحت! ✅');
}
```

## 🆘 الدعم

للحصول على المساعدة:
- راجع الأمثلة في `examples/`
- اقرأ التوثيق في الكود
- افتح Issue في GitHub
- تواصل مع الفريق

---

**نتمنى لك برمجة سعيدة! 💻✨**
