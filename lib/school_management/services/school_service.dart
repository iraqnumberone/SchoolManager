import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:logging/logging.dart';
import '../../core/database_helper.dart';
import '../models/school.dart';
import '../../features/teacher/models/teacher.dart';
import '../models/school_stage.dart';
import '../models/class_group.dart';

final _logger = Logger('SchoolService');

class SchoolService {
  // Singleton pattern
  SchoolService._privateConstructor();
  static final SchoolService instance = SchoolService._privateConstructor();
  
  // Database helper instance
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  // Get database instance
  Future<Database> get _db async {
    return await _dbHelper.database;
  }
  
  // Convert Map to School
  School _schoolFromMap(Map<String, dynamic> map) {
    return School(
      id: map[DatabaseHelper.columnId].toString(),
      name: map[DatabaseHelper.columnName] ?? '',
      address: map[DatabaseHelper.columnAddress] ?? '',
      phone: map[DatabaseHelper.columnPhone] ?? '',
      email: map[DatabaseHelper.columnEmail] ?? '',
      logo: map['logo']?.toString(),
      directorName: map['director_name']?.toString() ?? 'غير محدد',
      isActive: map['is_active'] == 1,
      educationLevel: map['education_level']?.toString() ?? 'غير محدد',
      section: map['section']?.toString() ?? 'أ',
      studentCount: (map['student_count'] is int) 
          ? map['student_count'] as int 
          : int.tryParse(map['student_count']?.toString() ?? '0') ?? 0,
      createdAt: DateTime.tryParse(map[DatabaseHelper.columnCreatedAt]?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map[DatabaseHelper.columnUpdatedAt]?.toString() ?? '') ?? DateTime.now(),
    );
  }
  
  // Convert School to Map
  Map<String, dynamic> _schoolToMap(School school) {
    return {
      DatabaseHelper.columnId: int.tryParse(school.id) ?? 0,
      DatabaseHelper.columnName: school.name,
      DatabaseHelper.columnAddress: school.address,
      DatabaseHelper.columnPhone: school.phone,
      DatabaseHelper.columnEmail: school.email,
      'logo': school.logo,
      'director_name': school.directorName,
      'is_active': school.isActive ? 1 : 0,
      'education_level': school.educationLevel,
      'section': school.section,
      'student_count': school.studentCount,
      DatabaseHelper.columnCreatedAt: school.createdAt.toIso8601String(),
      DatabaseHelper.columnUpdatedAt: school.updatedAt.toIso8601String(),
    };
  }

  // Convert Map to SchoolStage
  SchoolStage _schoolStageFromMap(Map<String, dynamic> map) {
    return SchoolStage(
      id: map[DatabaseHelper.columnId].toString(),
      schoolId: map[DatabaseHelper.columnSchoolId].toString(),
      name: map[DatabaseHelper.columnName] ?? '',
      order: map['sort_order'] is int ? map['sort_order'] : int.tryParse(map['sort_order']?.toString() ?? '0') ?? 0,
      isActive: map['is_active'] == 1,
      createdAt: DateTime.tryParse(map[DatabaseHelper.columnCreatedAt]?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map[DatabaseHelper.columnUpdatedAt]?.toString() ?? '') ?? DateTime.now(),
    );
  }

  // Convert SchoolStage to Map
  Map<String, dynamic> _schoolStageToMap(SchoolStage stage) {
    return {
      DatabaseHelper.columnId: int.tryParse(stage.id) ?? 0,
      DatabaseHelper.columnSchoolId: int.tryParse(stage.schoolId) ?? 0,
      DatabaseHelper.columnName: stage.name,
      'sort_order': stage.order,
      'is_active': stage.isActive ? 1 : 0,
      DatabaseHelper.columnCreatedAt: stage.createdAt.toIso8601String(),
      DatabaseHelper.columnUpdatedAt: stage.updatedAt.toIso8601String(),
    };
  }

  // Convert Map to ClassGroup
  ClassGroup _classGroupFromMap(Map<String, dynamic> map) {
    return ClassGroup(
      id: map[DatabaseHelper.columnId].toString(),
      schoolId: map[DatabaseHelper.columnSchoolId].toString(),
      stageId: map['stage_id'].toString(),
      name: map[DatabaseHelper.columnName] ?? '',
      description: map[DatabaseHelper.columnDescription]?.toString(),
      capacity: map['capacity'] is int ? map['capacity'] : int.tryParse(map['capacity']?.toString() ?? '0') ?? 0,
      teacherId: map['teacher_id']?.toString(),
      teacherName: map['teacher_name']?.toString() ?? 'غير محدد',
      isActive: map['is_active'] == 1,
      createdAt: DateTime.tryParse(map[DatabaseHelper.columnCreatedAt]?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map[DatabaseHelper.columnUpdatedAt]?.toString() ?? '') ?? DateTime.now(),
    );
  }

  // Convert ClassGroup to Map
  Map<String, dynamic> _classGroupToMap(ClassGroup group) {
    return {
      DatabaseHelper.columnId: int.tryParse(group.id) ?? 0,
      DatabaseHelper.columnSchoolId: int.tryParse(group.schoolId) ?? 0,
      'stage_id': int.tryParse(group.stageId) ?? 0,
      DatabaseHelper.columnName: group.name,
      'description': group.description,
      'capacity': group.capacity,
      'teacher_id': group.teacherId != null ? int.tryParse(group.teacherId!) : null,
      'teacher_name': group.teacherName,
      'is_active': group.isActive ? 1 : 0,
      DatabaseHelper.columnCreatedAt: group.createdAt.toIso8601String(),
      DatabaseHelper.columnUpdatedAt: group.updatedAt.toIso8601String(),
    };
  }

  // Add a new school
  Future<bool> addSchool(School school) async {
    final db = await _db;
    try {
      final now = DateTime.now();
      final schoolToAdd = school.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: now,
        updatedAt: now,
      );
      
      await db.insert(
        DatabaseHelper.tableSchools,
        _schoolToMap(schoolToAdd),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      _logger.severe('Error adding school', e);
      return false;
    }
  }

  // Get all schools
  Future<List<School>> getSchools() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableSchools,
      where: '${DatabaseHelper.columnIsActive} = ?',
      whereArgs: [1],
    );

    return List.generate(maps.length, (i) => _schoolFromMap(maps[i]));
  }
  
  // Alias for getSchools to maintain backward compatibility
  Future<List<School>> getAllSchools() => getSchools();

  // Get school by ID
  Future<School?> getSchoolById(String id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableSchools,
      where: '${DatabaseHelper.columnId} = ? AND ${DatabaseHelper.columnIsActive} = ?',
      whereArgs: [int.tryParse(id) ?? 0, 1],
    );

    if (maps.isNotEmpty) {
      return _schoolFromMap(maps.first);
    }
    return null;
  }

  // Update a school
  Future<bool> updateSchool(School school) async {
    final db = await _db;
    try {
      final updatedSchool = school.copyWith(updatedAt: DateTime.now());
      final count = await db.update(
        DatabaseHelper.tableSchools,
        _schoolToMap(updatedSchool),
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [int.tryParse(school.id) ?? 0],
      );
      return count > 0;
    } catch (e) {
      _logger.severe('Error updating school', e);
      return false;
    }
  }

  // Delete a school (soft delete)
  Future<bool> deleteSchool(String id) async {
    final db = await _db;
    try {
      final school = await getSchoolById(id);
      if (school == null) return false;
      
      // Start a transaction to ensure data consistency
      await db.transaction((txn) async {
        // First, deactivate all related stages
        await txn.update(
          DatabaseHelper.tableSchoolStages,
          {
            DatabaseHelper.columnIsActive: 0, 
            DatabaseHelper.columnUpdatedAt: DateTime.now().toIso8601String()
          },
          where: '${DatabaseHelper.columnSchoolId} = ?',
          whereArgs: [int.tryParse(id) ?? 0],
        );
        
        // Then, deactivate all related class groups
        await txn.update(
          DatabaseHelper.tableClassGroups,
          {
            DatabaseHelper.columnIsActive: 0, 
            DatabaseHelper.columnUpdatedAt: DateTime.now().toIso8601String()
          },
          where: '${DatabaseHelper.columnSchoolId} = ?',
          whereArgs: [int.tryParse(id) ?? 0],
        );
        
        // Finally, deactivate the school
        await txn.update(
          DatabaseHelper.tableSchools,
          {
            DatabaseHelper.columnIsActive: 0, 
            DatabaseHelper.columnUpdatedAt: DateTime.now().toIso8601String()
          },
          where: '${DatabaseHelper.columnId} = ?',
          whereArgs: [int.tryParse(id) ?? 0],
        );
      });
      
      return true;
    } catch (e) {
      _logger.severe('Error deleting school', e);
      return false;
    }
  }

  // إضافة مرحلة دراسية
  Future<bool> addSchoolStage(SchoolStage stage) async {
    final db = await _db;
    try {
      final now = DateTime.now();
      final stageToAdd = stage.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: now,
        updatedAt: now,
      );
      
      await db.insert(
        DatabaseHelper.tableSchoolStages,
        _schoolStageToMap(stageToAdd),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      _logger.severe('Error adding school stage', e);
      return false;
    }
  }

  // الحصول على المراحل الدراسية لمدرسة معينة
  Future<List<SchoolStage>> getStagesBySchool(String schoolId) async {
    final db = await _db;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableSchoolStages,
        where: '${DatabaseHelper.columnSchoolId} = ? AND ${DatabaseHelper.columnIsActive} = ?',
        whereArgs: [int.tryParse(schoolId) ?? 0, 1],
      );
      return List.generate(maps.length, (i) => _schoolStageFromMap(maps[i]));
    } catch (e) {
      _logger.severe('Error getting school stages', e);
      return [];
    }
  }

  // إضافة شعبة جديدة
  Future<bool> addClassGroup(ClassGroup classGroup) async {
    final db = await _db;
    try {
      await db.insert(
        DatabaseHelper.tableClassGroups,
        _classGroupToMap(classGroup),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      _logger.severe('Error adding class group', e);
      return false;
    }
  }

  // الحصول على الشعب لمرحلة معينة
  Future<List<ClassGroup>> getClassGroupsByStage(String stageId) async {
    final db = await _db;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableClassGroups,
        where: '${DatabaseHelper.columnStageId} = ? AND ${DatabaseHelper.columnIsActive} = ?',
        whereArgs: [int.tryParse(stageId) ?? 0, 1],
      );
      return List.generate(maps.length, (i) => _classGroupFromMap(maps[i]));
    } catch (e) {
      _logger.severe('Error getting class groups by stage', e);
      return [];
    }
  }

  // الحصول على شعبة بالمعرف
  Future<ClassGroup?> getClassGroupById(String id) async {
    final db = await _db;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableClassGroups,
        where: '${DatabaseHelper.columnId} = ? AND ${DatabaseHelper.columnIsActive} = ?',
        whereArgs: [int.tryParse(id) ?? 0, 1],
      );
      if (maps.isNotEmpty) {
        return _classGroupFromMap(maps.first);
      }
      return null;
    } catch (e) {
      _logger.severe('Error getting class group by ID', e);
      return null;
    }
  }

  // تحديث شعبة
  Future<bool> updateClassGroup(ClassGroup classGroup) async {
    final db = await _db;
    try {
      final updatedGroup = classGroup.copyWith(updatedAt: DateTime.now());
      final count = await db.update(
        DatabaseHelper.tableClassGroups,
        _classGroupToMap(updatedGroup),
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [int.tryParse(classGroup.id) ?? 0],
      );
      return count > 0;
    } catch (e) {
      _logger.severe('Error updating class group', e);
      return false;
    }
  }

  // حذف شعبة (حذف ناعم)
  Future<bool> deleteClassGroup(String id) async {
    final db = await _db;
    try {
      final now = DateTime.now();
      final count = await db.update(
        DatabaseHelper.tableClassGroups,
        {
          DatabaseHelper.columnIsActive: 0,
          DatabaseHelper.columnUpdatedAt: now.toIso8601String(),
        },
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [int.tryParse(id) ?? 0],
      );
      return count > 0;
    } catch (e) {
      _logger.severe('Error deleting class group', e);
      return false;
    }
  }

  // البحث عن المدارس
  Future<List<School>> searchSchools(String query) async {
    final db = await _db;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableSchools,
        where: '${DatabaseHelper.columnName} LIKE ? AND ${DatabaseHelper.columnIsActive} = ?',
        whereArgs: ['%$query%', 1],
      );
      return List.generate(maps.length, (i) => _schoolFromMap(maps[i]));
    } catch (e) {
      _logger.severe('Error searching schools', e);
      return [];
    }
  }

  // الحصول على إحصائيات المدرسة
  Future<Map<String, dynamic>> getSchoolStats(String schoolId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final school = await getSchoolById(schoolId);
      if (school == null) return {};

      // Get all class groups for the school
      final db = await _db;
      final classGroups = await db.query(
        DatabaseHelper.tableClassGroups,
        where: '${DatabaseHelper.columnSchoolId} = ? AND ${DatabaseHelper.columnIsActive} = ?',
        whereArgs: [int.tryParse(schoolId) ?? 0, 1],
      );

      // Calculate statistics
      final totalStudents = classGroups.fold(0, (sum, group) => 
        sum + (group['current_students'] as int? ?? 0));
      
      final totalCapacity = classGroups.fold(0, (sum, group) => 
        sum + (group['capacity'] as int? ?? 0));

      // Get total number of teachers in the school
      final teachers = await getTeachersBySchool(schoolId);
      final totalTeachers = teachers.length;
      
      return {
        'totalStudents': totalStudents,
        'totalTeachers': totalTeachers,
        'totalClassGroups': classGroups.length,
        'totalStages': (await getStagesBySchool(schoolId)).length,
        'occupancyRate': totalCapacity > 0 ? totalStudents / totalCapacity : 0.0,
      };
    } catch (e) {
      return {};
    }
  }

  // Teacher management methods
  Future<void> _ensureTeachersTableExists() async {
    final db = await DatabaseHelper().database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS teachers (
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
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (school_id) REFERENCES schools (id) ON DELETE CASCADE
      )
    ''');

    // Teacher-class assignments table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS teacher_class_assignments (
        id TEXT PRIMARY KEY,
        teacher_id TEXT NOT NULL,
        class_group_id TEXT NOT NULL,
        subject_id TEXT,
        academic_year TEXT,
        is_homeroom INTEGER DEFAULT 0,
        created_at INTEGER,
        updated_at INTEGER,
        FOREIGN KEY (teacher_id) REFERENCES teachers (id) ON DELETE CASCADE,
        FOREIGN KEY (class_group_id) REFERENCES class_groups (id) ON DELETE CASCADE,
        UNIQUE(teacher_id, class_group_id, subject_id, academic_year)
      )
    ''');
  }


  // Initialize the database tables if they don't exist
  Future<void> _initDatabase() async {
    await _ensureTeachersTableExists();
  }

  // Initialize the database when the service is created
  SchoolService() {
    _initDatabase();
  }

  // Convert Teacher to map for database
  Map<String, dynamic> _teacherToMap(Teacher teacher) {
    return {
      'id': teacher.id,
      'first_name': teacher.firstName,
      'last_name': teacher.lastName,
      'full_name': teacher.fullName,
      'employee_id': teacher.employeeId,
      'email': teacher.email,
      'phone': teacher.phone,
      'national_id': teacher.nationalId,
      'qualification': teacher.qualification,
      'specialization': teacher.specialization,
      'school_id': teacher.schoolId,
      'status': teacher.status,
      'hire_date': teacher.hireDate.millisecondsSinceEpoch,
      'profile_image': teacher.profileImage,
      'contact_info': teacher.contactInfo.toString(),
      'emergency_contact': teacher.emergencyContact.toString(),
      'settings': teacher.settings.toString(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
      'is_active': 1,
    };
  }

  // Convert map to Teacher object
  Teacher _teacherFromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      fullName: map['full_name'],
      employeeId: map['employee_id'],
      email: map['email'],
      phone: map['phone'],
      nationalId: map['national_id'],
      qualification: map['qualification'],
      specialization: map['specialization'],
      subjects: [], // Will be populated separately
      schoolId: map['school_id'],
      status: map['status'],
      hireDate: DateTime.fromMillisecondsSinceEpoch(map['hire_date']),
      profileImage: map['profile_image'],
      contactInfo: _parseMapString(map['contact_info']),
      emergencyContact: _parseMapString(map['emergency_contact']),
      settings: _parseMapString(map['settings']),
    );
  }

  // Helper to parse stringified maps
  Map<String, dynamic> _parseMapString(String? mapString) {
    if (mapString == null || mapString.isEmpty) return {};
    try {
      // Simple parsing for the demo - in production, use proper JSON parsing
      return Map<String, dynamic>.from(mapString as Map);
    } catch (e) {
      return {};
    }
  }

  // Add a new teacher
  Future<Teacher> addTeacher(Teacher teacher) async {
    final db = await DatabaseHelper().database;
    await _ensureTeachersTableExists();
    await db.insert('teachers', _teacherToMap(teacher));
    return teacher;
  }

  // Update an existing teacher
  Future<int> updateTeacher(Teacher teacher) async {
    final db = await DatabaseHelper().database;
    await _ensureTeachersTableExists();
    return await db.update(
      'teachers',
      _teacherToMap(teacher),
      where: 'id = ?',
      whereArgs: [teacher.id],
    );
  }

  // Get teacher by ID
  Future<Teacher?> getTeacherById(String id) async {
    final db = await DatabaseHelper().database;
    await _ensureTeachersTableExists();
    final List<Map<String, dynamic>> maps = await db.query(
      'teachers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return _teacherFromMap(maps.first);
    }
    return null;
  }

  // Get all teachers in a school
  Future<List<Teacher>> getTeachersBySchool(String schoolId) async {
    final db = await DatabaseHelper().database;
    await _ensureTeachersTableExists();
    final List<Map<String, dynamic>> maps = await db.query(
      'teachers',
      where: 'school_id = ?',
      whereArgs: [schoolId],
    );
    return List.generate(maps.length, (i) => _teacherFromMap(maps[i]));
  }

  // Delete a teacher
  Future<int> deleteTeacher(String id) async {
    final db = await DatabaseHelper().database;
    await _ensureTeachersTableExists();
    return await db.delete(
      'teachers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Assign teacher to class/subject
  Future<void> assignTeacherToClass({
    required String teacherId,
    required String classGroupId,
    String? subjectId,
    String academicYear = '2023-2024',
    bool isHomeroom = false,
  }) async {
    final db = await DatabaseHelper().database;
    await _ensureTeachersTableExists();
    await db.insert('teacher_class_assignments', {
      'id': '${teacherId}_${classGroupId}_${subjectId ?? 'homeroom'}',
      'teacher_id': teacherId,
      'class_group_id': classGroupId,
      'subject_id': subjectId,
      'academic_year': academicYear,
      'is_homeroom': isHomeroom ? 1 : 0,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Get teacher's class assignments
  Future<List<Map<String, dynamic>>> getTeacherAssignments(String teacherId) async {
    final db = await DatabaseHelper().database;
    await _ensureTeachersTableExists();
    return await db.query(
      'teacher_class_assignments',
      where: 'teacher_id = ?',
      whereArgs: [teacherId],
    );
  }

  // Get teachers for a specific class
  Future<List<Teacher>> getTeachersByClass(String classGroupId) async {
    final db = await DatabaseHelper().database;
    await _ensureTeachersTableExists();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.* FROM teachers t
      INNER JOIN teacher_class_assignments tca ON t.id = tca.teacher_id
      WHERE tca.class_group_id = ?
    ''', [classGroupId]);
    
    return List.generate(maps.length, (i) => _teacherFromMap(maps[i]));
  }

  // Initialize demo data
  Future<void> initializeDemoData() async {
    try {
      // Check if we already have schools
      final schools = await getSchools();
      if (schools.isNotEmpty) return;

      // Add a demo school
      final school = School(
        id: '1',
        name: 'مدرسة النموذجية',
        address: 'شارع الرياض، الرياض',
        phone: '0112345678',
        email: 'info@school.edu.sa',
        directorName: 'أحمد محمد',
        educationLevel: 'ابتدائي',
        section: 'أ',
        studentCount: 150,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await addSchool(school);
      
      // Add demo stages
      final stages = [
        SchoolStage(
          id: '1',
          schoolId: '1',
          name: 'الصف الأول الابتدائي',
          order: 1,
          isActive: true,
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

      for (final stage in stages) {
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

      for (final group in classGroups) {
        await addClassGroup(group);
      }
    } catch (e) {
      _logger.severe('Error initializing demo data', e);
      rethrow; // Re-throw to allow callers to handle the error
    }
  }
}
