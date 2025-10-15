import 'package:school_app/features/school/models/school.dart';
import 'package:school_app/features/classroom/models/classroom.dart';
import 'package:school_app/features/teacher/models/teacher.dart';
import 'package:school_app/features/student/models/student.dart';
import 'package:school_app/features/attendance/models/attendance.dart';
import 'package:school_app/features/grade/models/grade.dart';

class SchoolService {
  // محاكاة قاعدة البيانات المحلية
  static final Map<String, School> _schools = {};
  static final Map<String, Classroom> _classrooms = {};
  static final Map<String, Teacher> _teachers = {};
  static final Map<String, Student> _students = {};
  static final Map<String, List<Attendance>> _attendance = {};
  static final Map<String, List<Grade>> _grades = {};

  // إدارة المدارس
  static Future<bool> addSchool(School school) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _schools[school.id] = school;
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<School>> getAllSchools() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _schools.values.toList();
    } catch (e) {
      return [];
    }
  }

  static Future<School?> getSchoolById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      return _schools[id];
    } catch (e) {
      return null;
    }
  }

  // إدارة الفصول
  static Future<bool> addClassroom(Classroom classroom) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      _classrooms[classroom.id] = classroom;
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Classroom>> getClassroomsBySchool(String schoolId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _classrooms.values.where((c) => c.schoolId == schoolId).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Classroom>> getClassroomsByTeacher(String teacherId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _classrooms.values.where((c) =>
        c.classTeacherId == teacherId || c.assistantTeacherId == teacherId
      ).toList();
    } catch (e) {
      return [];
    }
  }

  // إدارة المعلمين
  static Future<bool> addTeacher(Teacher teacher) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      _teachers[teacher.id] = teacher;
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Teacher>> getTeachersBySchool(String schoolId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _teachers.values.where((t) => t.schoolId == schoolId).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Teacher>> getTeachersBySubject(String subject) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _teachers.values.where((t) => t.subjects.contains(subject)).toList();
    } catch (e) {
      return [];
    }
  }

  // إدارة الطلاب
  static Future<bool> addStudent(Student student) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      _students[student.id] = student;

      // إنشاء قوائم فارغة للحضور والدرجات
      _attendance[student.id] = [];
      _grades[student.id] = [];

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Student>> getStudentsByClassroom(String classroomId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _students.values.where((s) =>
        s.classroomId == classroomId && s.status == 'active'
      ).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Student>> getStudentsBySchool(String schoolId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _students.values.where((s) =>
        s.schoolId == schoolId && s.status == 'active'
      ).toList();
    } catch (e) {
      return [];
    }
  }

  // إدارة الحضور
  static Future<bool> recordAttendance(Attendance attendance) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));

      if (!_attendance.containsKey(attendance.studentId)) {
        _attendance[attendance.studentId] = [];
      }

      // التحقق من عدم وجود سجل حضور لنفس الطالب في نفس التاريخ والفصل
      final existingIndex = _attendance[attendance.studentId]!
          .indexWhere((a) =>
            a.studentId == attendance.studentId &&
            a.date.year == attendance.date.year &&
            a.date.month == attendance.date.month &&
            a.date.day == attendance.date.day &&
            a.classroomId == attendance.classroomId);

      if (existingIndex >= 0) {
        _attendance[attendance.studentId]![existingIndex] = attendance;
      } else {
        _attendance[attendance.studentId]!.add(attendance);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Attendance>> getStudentAttendance(String studentId, {DateTime? fromDate, DateTime? toDate}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      if (!_attendance.containsKey(studentId)) {
        return [];
      }

      var attendanceList = _attendance[studentId]!;

      if (fromDate != null) {
        attendanceList = attendanceList.where((a) => a.date.isAfter(fromDate.subtract(const Duration(days: 1)))).toList();
      }

      if (toDate != null) {
        attendanceList = attendanceList.where((a) => a.date.isBefore(toDate.add(const Duration(days: 1)))).toList();
      }

      return attendanceList..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      return [];
    }
  }

  static Future<List<Attendance>> getClassroomAttendance(String classroomId, DateTime date) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final allAttendance = <Attendance>[];
      for (var studentAttendance in _attendance.values) {
        allAttendance.addAll(
          studentAttendance.where((a) =>
            a.classroomId == classroomId &&
            a.date.year == date.year &&
            a.date.month == date.month &&
            a.date.day == date.day
          )
        );
      }

      return allAttendance;
    } catch (e) {
      return [];
    }
  }

  // إدارة الدرجات
  static Future<bool> addGrade(Grade grade) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));

      if (!_grades.containsKey(grade.studentId)) {
        _grades[grade.studentId] = [];
      }

      // التحقق من عدم وجود درجة لنفس المادة في نفس التاريخ
      final existingIndex = _grades[grade.studentId]!
          .indexWhere((g) =>
            g.studentId == grade.studentId &&
            g.subjectId == grade.subjectId &&
            g.date.year == grade.date.year &&
            g.date.month == grade.date.month &&
            g.date.day == grade.date.day &&
            g.gradeType == grade.gradeType);

      if (existingIndex >= 0) {
        _grades[grade.studentId]![existingIndex] = grade;
      } else {
        _grades[grade.studentId]!.add(grade);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Grade>> getStudentGrades(String studentId, {String? subjectId, String? gradeType}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      if (!_grades.containsKey(studentId)) {
        return [];
      }

      var gradesList = _grades[studentId]!;

      if (subjectId != null) {
        gradesList = gradesList.where((g) => g.subjectId == subjectId).toList();
      }

      if (gradeType != null) {
        gradesList = gradesList.where((g) => g.gradeType == gradeType).toList();
      }

      return gradesList..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      return [];
    }
  }

  static Future<List<Grade>> getClassroomGrades(String classroomId, String subjectId, {String? gradeType}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final allGrades = <Grade>[];
      for (var studentGrades in _grades.values) {
        allGrades.addAll(
          studentGrades.where((g) =>
            g.classroomId == classroomId &&
            g.subjectId == subjectId &&
            (gradeType == null || g.gradeType == gradeType)
          )
        );
      }

      return allGrades..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      return [];
    }
  }

  // التقارير والإحصائيات
  static Future<Map<String, dynamic>> getSchoolStats(String schoolId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final classrooms = await getClassroomsBySchool(schoolId);
      final teachers = await getTeachersBySchool(schoolId);
      final students = await getStudentsBySchool(schoolId);

      int totalPresentToday = 0;
      int totalAbsentToday = 0;

      for (var classroom in classrooms) {
        final todayAttendance = await getClassroomAttendance(classroom.id, DateTime.now());
        totalPresentToday += todayAttendance.where((a) => a.status == 'present').length;
        totalAbsentToday += todayAttendance.where((a) => a.status == 'absent').length;
      }

      return {
        'totalClassrooms': classrooms.length,
        'totalTeachers': teachers.length,
        'totalStudents': students.length,
        'totalPresentToday': totalPresentToday,
        'totalAbsentToday': totalAbsentToday,
        'attendanceRate': students.isNotEmpty ? (totalPresentToday / (totalPresentToday + totalAbsentToday)) * 100 : 0.0,
      };
    } catch (e) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> getClassroomStats(String classroomId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));

      final students = await getStudentsByClassroom(classroomId);
      final todayAttendance = await getClassroomAttendance(classroomId, DateTime.now());

      final presentCount = todayAttendance.where((a) => a.status == 'present').length;
      final absentCount = todayAttendance.where((a) => a.status == 'absent').length;
      final lateCount = todayAttendance.where((a) => a.status == 'late').length;
      final excusedCount = todayAttendance.where((a) => a.status == 'excused').length;

      return {
        'totalStudents': students.length,
        'presentToday': presentCount,
        'absentToday': absentCount,
        'lateToday': lateCount,
        'excusedToday': excusedCount,
        'attendanceRate': students.isNotEmpty ? (presentCount / students.length) * 100 : 0.0,
      };
    } catch (e) {
      return {};
    }
  }

  // تهيئة البيانات التجريبية
  static Future<void> initializeDemoData() async {
    if (_schools.isEmpty) {
      // إضافة مدرسة تجريبية
      final school = School(
        id: 'school_1',
        name: 'مدرسة الرياض الذكية',
        nameEn: 'Al Riyadh Smart School',
        address: 'شارع الملك عبدالعزيز، الرياض',
        phone: '+966114567890',
        email: 'info@riyadhsmart.edu.sa',
        principalName: 'د. أحمد محمد علي',
        schoolType: 'private',
        establishedDate: DateTime(2010, 9, 1),
        description: 'مدرسة خاصة متميزة تركز على التعليم الذكي والتكنولوجيا',
      );
      await addSchool(school);

      // إضافة فصول تجريبية
      final classrooms = [
        Classroom(
          id: 'class_1',
          name: 'الصف الأول أ',
          nameEn: 'Grade 1 A',
          schoolId: 'school_1',
          stageId: 'elementary',
          grade: 'الأول',
          section: 'أ',
          maxStudents: 25,
          currentStudents: 22,
          academicYear: '2024-2025',
          roomNumber: '101',
          classTeacherId: 'teacher_1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Classroom(
          id: 'class_2',
          name: 'الصف الأول ب',
          nameEn: 'Grade 1 B',
          schoolId: 'school_1',
          stageId: 'elementary',
          grade: 'الأول',
          section: 'ب',
          maxStudents: 25,
          currentStudents: 24,
          academicYear: '2024-2025',
          roomNumber: '102',
          classTeacherId: 'teacher_2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (var classroom in classrooms) {
        await addClassroom(classroom);
      }

      // إضافة معلمين تجريبيين
      final teachers = [
        Teacher(
          id: 'teacher_1',
          firstName: 'فاطمة',
          lastName: 'أحمد',
          fullName: 'فاطمة أحمد محمد',
          employeeId: 'T2024001',
          email: 'fatima.ahmed@riyadhsmart.edu.sa',
          phone: '+966501234567',
          nationalId: '1234567890',
          qualification: 'bachelor',
          specialization: 'التربية الابتدائية',
          subjects: ['اللغة العربية', 'التربية الإسلامية'],
          schoolId: 'school_1',
          status: 'active',
          hireDate: DateTime(2020, 9, 1),
        ),
        Teacher(
          id: 'teacher_2',
          firstName: 'سارة',
          lastName: 'علي',
          fullName: 'سارة علي حسن',
          employeeId: 'T2024002',
          email: 'sara.ali@riyadhsmart.edu.sa',
          phone: '+966509876543',
          nationalId: '0987654321',
          qualification: 'master',
          specialization: 'الرياضيات',
          subjects: ['الرياضيات', 'العلوم'],
          schoolId: 'school_1',
          status: 'active',
          hireDate: DateTime(2019, 9, 1),
        ),
      ];

      for (var teacher in teachers) {
        await addTeacher(teacher);
      }

      // إضافة طلاب تجريبيين
      final students = [
        Student(
          id: 'student_1',
          firstName: 'أحمد',
          lastName: 'محمد',
          fullName: 'أحمد محمد علي',
          studentId: '2024001',
          nationalId: '1122334455',
          birthDate: DateTime(2016, 5, 15),
          gender: 'male',
          nationality: 'سعودي',
          address: 'حي النخيل، الرياض',
          phone: '+966501112233',
          parentPhone: '+966507654321',
          parentEmail: 'parent1@email.com',
          schoolId: 'school_1',
          classroomId: 'class_1',
          status: 'active',
          bloodType: 'O+',
        ),
        Student(
          id: 'student_2',
          firstName: 'فاطمة',
          lastName: 'أحمد',
          fullName: 'فاطمة أحمد حسن',
          studentId: '2024002',
          nationalId: '2233445566',
          birthDate: DateTime(2016, 3, 22),
          gender: 'female',
          nationality: 'سعودي',
          address: 'حي الروضة، الرياض',
          phone: '+966502223344',
          parentPhone: '+966508765432',
          parentEmail: 'parent2@email.com',
          schoolId: 'school_1',
          classroomId: 'class_1',
          status: 'active',
          bloodType: 'A+',
        ),
      ];

      for (var student in students) {
        await addStudent(student);
      }

      // إضافة بيانات حضور تجريبية
      for (var student in students) {
        for (int i = 0; i < 7; i++) {
          final date = DateTime.now().subtract(Duration(days: i));
          final status = i == 0 ? 'present' : (i % 3 == 0 ? 'absent' : 'present');

          await recordAttendance(Attendance(
            id: 'attendance_${student.id}_${date.millisecondsSinceEpoch}',
            studentId: student.id,
            classroomId: student.classroomId,
            schoolId: student.schoolId,
            date: date,
            status: status,
            checkInTime: '08:00',
            recordedBy: 'teacher_1',
          ));
        }
      }

      // إضافة درجات تجريبية
      final subjects = ['اللغة العربية', 'الرياضيات', 'العلوم'];
      for (var student in students) {
        for (var subject in subjects) {
          for (int i = 0; i < 3; i++) {
            final date = DateTime.now().subtract(Duration(days: i * 30));
            final score = 75 + (student.id.hashCode % 20) + (i * 5);

            await addGrade(Grade(
              id: 'grade_${student.id}_${subject}_${date.millisecondsSinceEpoch}',
              studentId: student.id,
              subjectId: subject,
              classroomId: student.classroomId,
              schoolId: student.schoolId,
              gradeType: i == 0 ? 'monthly' : 'daily',
              score: score.toDouble(),
              maxScore: 100.0,
              date: date,
              recordedBy: 'teacher_1',
            ));
          }
        }
      }
    }
  }
}
