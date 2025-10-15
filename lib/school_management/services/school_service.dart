import 'package:school_app/core/app_config.dart';
import 'package:school_app/school_management/models/school.dart';
import 'package:school_app/school_management/models/school_stage.dart';
import 'package:school_app/school_management/models/class_group.dart';

class SchoolService {
  // محاكاة قاعدة البيانات المحلية
  static final Map<String, School> _schools = {};
  static final Map<String, SchoolStage> _stages = {};
  static final Map<String, ClassGroup> _classGroups = {};

  // إضافة مدرسة جديدة
  static Future<bool> addSchool(School school) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // محاكاة التأخير
      _schools[school.id] = school;
      return true;
    } catch (e) {
      return false;
    }
  }

  // الحصول على جميع المدارس
  static Future<List<School>> getAllSchools() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _schools.values.where((school) => school.isActive).toList();
    } catch (e) {
      return [];
    }
  }

  // الحصول على مدرسة بالمعرف
  static Future<School?> getSchoolById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      return _schools[id];
    } catch (e) {
      return null;
    }
  }

  // تحديث مدرسة
  static Future<bool> updateSchool(School school) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      if (_schools.containsKey(school.id)) {
        _schools[school.id] = school;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // حذف مدرسة
  static Future<bool> deleteSchool(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      if (_schools.containsKey(id)) {
        _schools[id] = _schools[id]!.copyWith(isActive: false);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // إضافة مرحلة دراسية
  static Future<bool> addSchoolStage(SchoolStage stage) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      _stages[stage.id] = stage;
      return true;
    } catch (e) {
      return false;
    }
  }

  // الحصول على المراحل الدراسية لمدرسة معينة
  static Future<List<SchoolStage>> getStagesBySchool(String schoolId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _stages.values
          .where((stage) => stage.schoolId == schoolId && stage.isActive)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      return [];
    }
  }

  // إضافة شعبة جديدة
  static Future<bool> addClassGroup(ClassGroup classGroup) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      _classGroups[classGroup.id] = classGroup;
      return true;
    } catch (e) {
      return false;
    }
  }

  // الحصول على الشعب لمرحلة معينة
  static Future<List<ClassGroup>> getClassGroupsByStage(String stageId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _classGroups.values
          .where((group) => group.stageId == stageId && group.isActive)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      return [];
    }
  }

  // الحصول على شعبة بالمعرف
  static Future<ClassGroup?> getClassGroupById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      return _classGroups[id];
    } catch (e) {
      return null;
    }
  }

  // تحديث شعبة
  static Future<bool> updateClassGroup(ClassGroup classGroup) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      if (_classGroups.containsKey(classGroup.id)) {
        _classGroups[classGroup.id] = classGroup;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // حذف شعبة
  static Future<bool> deleteClassGroup(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      if (_classGroups.containsKey(id)) {
        _classGroups[id] = _classGroups[id]!.copyWith(isActive: false);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // البحث عن المدارس
  static Future<List<School>> searchSchools(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final lowercaseQuery = query.toLowerCase();
      return _schools.values.where((school) {
        return school.isActive &&
            (school.name.toLowerCase().contains(lowercaseQuery) ||
                school.address.toLowerCase().contains(lowercaseQuery) ||
                school.directorName.toLowerCase().contains(lowercaseQuery));
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // الحصول على إحصائيات المدرسة
  static Future<Map<String, dynamic>> getSchoolStats(String schoolId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final stages = await getStagesBySchool(schoolId);
      final allClassGroups = <ClassGroup>[];

      for (var stage in stages) {
        final groups = await getClassGroupsByStage(stage.id);
        allClassGroups.addAll(groups);
      }

      final totalCapacity = allClassGroups.fold<int>(
        0,
        (sum, group) => sum + group.capacity,
      );
      final totalStudents = allClassGroups.fold<int>(
        0,
        (sum, group) => sum + group.currentStudents,
      );

      return {
        'totalStages': stages.length,
        'totalClassGroups': allClassGroups.length,
        'totalCapacity': totalCapacity,
        'totalStudents': totalStudents,
        'occupancyRate': totalCapacity > 0
            ? totalStudents / totalCapacity
            : 0.0,
      };
    } catch (e) {
      return {};
    }
  }

  // تهيئة بيانات تجريبية
  static Future<void> initializeDemoData() async {
    if (_schools.isEmpty) {
      // إضافة مدرسة تجريبية
      final school = School(
        id: 'school_1',
        name: 'مدرسة النور الابتدائية',
        address: 'شارع الملك فيصل، الرياض',
        phone: '+966501234567',
        email: 'info@alnour.edu.sa',
        directorName: 'د. أحمد محمد علي',
        createdAt: DateTime.now(),
        educationLevel: 'ابتدائي',
        section: 'أ',
        studentCount: 120,
      );

      await addSchool(school);

      // إضافة مراحل دراسية
      final stages = [
        SchoolStage(
          id: 'stage_1',
          schoolId: school.id,
          name: 'الصف الأول',
          order: 1,
          createdAt: DateTime.now(),
        ),
        SchoolStage(
          id: 'stage_2',
          schoolId: school.id,
          name: 'الصف الثاني',
          order: 2,
          createdAt: DateTime.now(),
        ),
        SchoolStage(
          id: 'stage_3',
          schoolId: school.id,
          name: 'الصف الثالث',
          order: 3,
          createdAt: DateTime.now(),
        ),
      ];

      for (var stage in stages) {
        await addSchoolStage(stage);
      }

      // إضافة شعب تجريبية
      final classGroups = [
        ClassGroup(
          id: 'group_1',
          schoolId: school.id,
          stageId: stages[0].id,
          name: 'شعبة أ',
          capacity: 30,
          teacherId: 'teacher_1',
          teacherName: 'أ. فاطمة أحمد',
          createdAt: DateTime.now(),
        ),
        ClassGroup(
          id: 'group_2',
          schoolId: school.id,
          stageId: stages[0].id,
          name: 'شعبة ب',
          capacity: 25,
          teacherId: 'teacher_2',
          teacherName: 'أ. محمد علي',
          createdAt: DateTime.now(),
        ),
      ];

      for (var group in classGroups) {
        await addClassGroup(group);
      }
    }
  }
}
