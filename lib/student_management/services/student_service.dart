import 'package:school_app/core/app_config.dart';
import 'package:school_app/student_management/models/student.dart';
import 'package:school_app/student_management/models/attendance.dart';
import 'package:school_app/student_management/models/grade.dart';

class StudentService {
  // محاكاة قاعدة البيانات المحلية
  static final Map<String, Student> _students = {};
  static final Map<String, List<Attendance>> _attendance = {};
  static final Map<String, List<Grade>> _grades = {};

  // إضافة طالب جديد
  static Future<bool> addStudent(Student student) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _students[student.id] = student;

      // إنشاء قوائم فارغة للحضور والدرجات
      _attendance[student.id] = [];
      _grades[student.id] = [];

      return true;
    } catch (e) {
      return false;
    }
  }

  // الحصول على جميع الطلاب
  static Future<List<Student>> getAllStudents() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _students.values.where((student) => student.status == AppConfig.studentStatusActive).toList();
    } catch (e) {
      return [];
    }
  }

  // الحصول على الطلاب حسب المدرسة
  static Future<List<Student>> getStudentsBySchool(String schoolId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _students.values.where((student) =>
        student.schoolId == schoolId &&
        student.status == AppConfig.studentStatusActive
      ).toList();
    } catch (e) {
      return [];
    }
  }

  // الحصول على الطلاب حسب المرحلة
  static Future<List<Student>> getStudentsByStage(String stageId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _students.values.where((student) =>
        student.stageId == stageId &&
        student.status == AppConfig.studentStatusActive
      ).toList();
    } catch (e) {
      return [];
    }
  }

  // الحصول على الطلاب حسب الشعبة
  static Future<List<Student>> getStudentsByClassGroup(String classGroupId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _students.values.where((student) =>
        student.classGroupId == classGroupId &&
        student.status == AppConfig.studentStatusActive
      ).toList();
    } catch (e) {
      return [];
    }
  }

  // الحصول على طالب بالمعرف
  static Future<Student?> getStudentById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      return _students[id];
    } catch (e) {
      return null;
    }
  }

  // تحديث طالب
  static Future<bool> updateStudent(Student student) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      if (_students.containsKey(student.id)) {
        _students[student.id] = student;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // حذف طالب (تعطيل)
  static Future<bool> deleteStudent(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      if (_students.containsKey(id)) {
        _students[id] = _students[id]!.copyWith(status: AppConfig.studentStatusInactive);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // البحث عن الطلاب
  static Future<List<Student>> searchStudents(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final lowercaseQuery = query.toLowerCase();
      return _students.values.where((student) {
        return student.status == AppConfig.studentStatusActive &&
            (student.fullName.toLowerCase().contains(lowercaseQuery) ||
             student.studentId.toLowerCase().contains(lowercaseQuery) ||
             student.phone.toLowerCase().contains(lowercaseQuery));
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // تسجيل الحضور
  static Future<bool> recordAttendance(Attendance attendance) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));

      if (!_attendance.containsKey(attendance.studentId)) {
        _attendance[attendance.studentId] = [];
      }

      // التحقق من عدم وجود سجل حضور لنفس الطالب في نفس التاريخ
      final existingIndex = _attendance[attendance.studentId]!
          .indexWhere((a) =>
            a.studentId == attendance.studentId &&
            a.date.year == attendance.date.year &&
            a.date.month == attendance.date.month &&
            a.date.day == attendance.date.day);

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

  // الحصول على سجلات الحضور للطالب
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

  // الحصول على إحصائيات الحضور للطالب
  static Future<Map<String, dynamic>> getStudentAttendanceStats(String studentId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      if (!_attendance.containsKey(studentId)) {
        return {};
      }

      final attendanceList = _attendance[studentId]!;
      final totalDays = attendanceList.length;

      if (totalDays == 0) {
        return {
          'totalDays': 0,
          'presentDays': 0,
          'absentDays': 0,
          'excusedDays': 0,
          'lateDays': 0,
          'attendanceRate': 0.0,
        };
      }

      final presentDays = attendanceList.where((a) => a.status == AppConfig.attendancePresent).length;
      final absentDays = attendanceList.where((a) => a.status == AppConfig.attendanceAbsent).length;
      final excusedDays = attendanceList.where((a) => a.status == AppConfig.attendanceExcused).length;
      final lateDays = attendanceList.where((a) => a.status == AppConfig.attendanceLate).length;

      return {
        'totalDays': totalDays,
        'presentDays': presentDays,
        'absentDays': absentDays,
        'excusedDays': excusedDays,
        'lateDays': lateDays,
        'attendanceRate': (presentDays / totalDays) * 100,
      };
    } catch (e) {
      return {};
    }
  }

  // إضافة درجة جديدة
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
            g.subject == grade.subject &&
            g.date.year == grade.date.year &&
            g.date.month == grade.date.month &&
            g.date.day == grade.date.day);

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

  // الحصول على درجات الطالب
  static Future<List<Grade>> getStudentGrades(String studentId, {String? subject, String? gradeType}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      if (!_grades.containsKey(studentId)) {
        return [];
      }

      var gradesList = _grades[studentId]!;

      if (subject != null) {
        gradesList = gradesList.where((g) => g.subject == subject).toList();
      }

      if (gradeType != null) {
        gradesList = gradesList.where((g) => g.gradeType == gradeType).toList();
      }

      return gradesList..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      return [];
    }
  }

  // الحصول على إحصائيات الدرجات للطالب
  static Future<Map<String, dynamic>> getStudentGradeStats(String studentId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      if (!_grades.containsKey(studentId)) {
        return {};
      }

      final gradesList = _grades[studentId]!;
      final subjects = gradesList.map((g) => g.subject).toSet();

      double totalPercentage = 0.0;
      int count = 0;

      for (var subject in subjects) {
        final subjectGrades = gradesList.where((g) => g.subject == subject).toList();
        if (subjectGrades.isNotEmpty) {
          final avgPercentage = subjectGrades.map((g) => g.percentage).reduce((a, b) => a + b) / subjectGrades.length;
          totalPercentage += avgPercentage;
          count++;
        }
      }

      final overallAverage = count > 0 ? totalPercentage / count : 0.0;

      return {
        'totalSubjects': subjects.length,
        'totalGrades': gradesList.length,
        'overallAverage': overallAverage,
        'performanceLevel': _getPerformanceLevel(overallAverage),
      };
    } catch (e) {
      return {};
    }
  }

  // الحصول على مستوى الأداء بناءً على النسبة المئوية
  static String _getPerformanceLevel(double percentage) {
    if (percentage >= 90) return AppConfig.performanceExcellent;
    if (percentage >= 80) return AppConfig.performanceGood;
    if (percentage >= 70) return AppConfig.performanceAverage;
    return AppConfig.performanceWeak;
  }

  // تهيئة بيانات تجريبية للطلاب
  static Future<void> initializeDemoStudents() async {
    if (_students.isEmpty) {
      // إضافة طلاب تجريبيين
      final students = [
        Student(
          id: 'student_1',
          firstName: 'أحمد',
          lastName: 'محمد',
          fullName: 'أحمد محمد علي',
          studentId: '2024001',
          birthDate: DateTime(2010, 5, 15),
          gender: 'male',
          address: 'شارع الملك فيصل، الرياض',
          phone: '+966501234567',
          parentPhone: '+966507654321',
          schoolId: 'school_1',
          stageId: 'stage_1',
          classGroupId: 'group_1',
          status: AppConfig.studentStatusActive,
          enrollmentDate: DateTime.now(),
        ),
        Student(
          id: 'student_2',
          firstName: 'فاطمة',
          lastName: 'أحمد',
          fullName: 'فاطمة أحمد حسن',
          studentId: '2024002',
          birthDate: DateTime(2011, 3, 22),
          gender: 'female',
          address: 'حي النخيل، جدة',
          phone: '+966509876543',
          parentPhone: '+966501112233',
          schoolId: 'school_1',
          stageId: 'stage_1',
          classGroupId: 'group_1',
          status: AppConfig.studentStatusActive,
          enrollmentDate: DateTime.now(),
        ),
        Student(
          id: 'student_3',
          firstName: 'محمد',
          lastName: 'علي',
          fullName: 'محمد علي سالم',
          studentId: '2024003',
          birthDate: DateTime(2009, 8, 10),
          gender: 'male',
          address: 'حي الروضة، الدمام',
          phone: '+966508765432',
          parentPhone: '+966502223344',
          schoolId: 'school_1',
          stageId: 'stage_2',
          classGroupId: 'group_2',
          status: AppConfig.studentStatusActive,
          enrollmentDate: DateTime.now(),
        ),
      ];

      for (var student in students) {
        await addStudent(student);
      }

      // إضافة بيانات حضور تجريبية
      for (var student in students) {
        for (int i = 0; i < 30; i++) {
          final date = DateTime.now().subtract(Duration(days: i));
          final status = i % 7 == 0 ? AppConfig.attendanceAbsent :
                        i % 5 == 0 ? AppConfig.attendanceLate :
                        AppConfig.attendancePresent;

          await recordAttendance(Attendance(
            id: 'attendance_${student.id}_${date.millisecondsSinceEpoch}',
            studentId: student.id,
            schoolId: student.schoolId,
            date: date,
            status: status,
            recordedBy: 'teacher_1',
            recordedAt: date.add(const Duration(hours: 8)),
          ));
        }
      }

      // إضافة درجات تجريبية
      final subjects = ['الرياضيات', 'العربية', 'الإنجليزية', 'العلوم'];
      for (var student in students) {
        for (var subject in subjects) {
          for (int i = 0; i < 3; i++) {
            final date = DateTime.now().subtract(Duration(days: i * 30));
            final score = 75 + (student.id.hashCode % 20) + (i * 5);

            await addGrade(Grade(
              id: 'grade_${student.id}_${subject}_${date.millisecondsSinceEpoch}',
              studentId: student.id,
              schoolId: student.schoolId,
              subject: subject,
              gradeType: i == 0 ? 'monthly' : 'daily',
              score: score.toDouble(),
              maxScore: 100.0,
              date: date,
              recordedBy: 'teacher_1',
              recordedAt: DateTime.now(),
            ));
          }
        }
      }
    }
  }
}
