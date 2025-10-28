import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Database info
  static const String databaseName = 'school_manager.db';
  static const int databaseVersion = 4;

  // Table names
  static const String tableSchools = 'schools';
  static const String tableSchoolStages = 'school_stages';
  static const String tableClassGroups = 'class_groups';

  // Common column names
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnDescription = 'description';
  static const String columnSchoolId = 'school_id';
  static const String columnIsActive = 'is_active';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  // Schools table columns
  static const String columnAddress = 'address';
  static const String columnPhone = 'phone';
  static const String columnEmail = 'email';
  static const String columnLogo = 'logo';
  static const String columnDirectorName = 'director_name';
  static const String columnEducationLevel = 'education_level';
  static const String columnSection = 'section';
  static const String columnStudentCount = 'student_count';

  // School Stages table columns
  static const String columnSortOrder = 'sort_order';

  // Class Groups table columns
  static const String columnStageId = 'stage_id';
  static const String columnCapacity = 'capacity';
  static const String columnTeacherId = 'teacher_id';
  static const String columnTeacherName = 'teacher_name';
  static const String columnCurrentStudents = 'current_students';

  // Get the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, databaseName);

    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        // Enable foreign key constraints
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // Create tables
  Future<void> _onCreate(Database db, int version) async {
    // Create schools table
    await db.execute('''
      CREATE TABLE $tableSchools (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnAddress TEXT NOT NULL,
        $columnPhone TEXT NOT NULL,
        $columnEmail TEXT NOT NULL,
        $columnLogo TEXT,
        $columnDirectorName TEXT,
        $columnIsActive INTEGER DEFAULT 1,
        $columnEducationLevel TEXT,
        $columnSection TEXT,
        $columnStudentCount INTEGER DEFAULT 0,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL
      )
    ''');

    // Create school_stages table
    await db.execute('''
      CREATE TABLE $tableSchoolStages (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnSchoolId INTEGER NOT NULL,
        $columnName TEXT NOT NULL,
        $columnDescription TEXT,
        $columnSortOrder INTEGER DEFAULT 0,
        $columnIsActive INTEGER DEFAULT 1,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL,
        FOREIGN KEY ($columnSchoolId) REFERENCES $tableSchools ($columnId) ON DELETE CASCADE
      )
    ''');

    // Create class_groups table
    await db.execute('''
      CREATE TABLE $tableClassGroups (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnSchoolId INTEGER NOT NULL,
        $columnStageId INTEGER NOT NULL,
        $columnName TEXT NOT NULL,
        $columnDescription TEXT,
        $columnCapacity INTEGER DEFAULT 30,
        $columnCurrentStudents INTEGER DEFAULT 0,
        $columnTeacherId INTEGER,
        $columnTeacherName TEXT,
        $columnIsActive INTEGER DEFAULT 1,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL,
        FOREIGN KEY ($columnSchoolId) REFERENCES $tableSchools ($columnId) ON DELETE CASCADE,
        FOREIGN KEY ($columnStageId) REFERENCES $tableSchoolStages ($columnId) ON DELETE CASCADE
      )
    ''');

    // Create students table (used by StudentService)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS students (
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
        $columnIsActive INTEGER DEFAULT 1,
        $columnCreatedAt TEXT,
        $columnUpdatedAt TEXT,
        FOREIGN KEY (schoolId) REFERENCES $tableSchools (id) ON DELETE CASCADE,
        FOREIGN KEY (stageId) REFERENCES $tableSchoolStages (id) ON DELETE SET NULL,
        FOREIGN KEY (classGroupId) REFERENCES $tableClassGroups (id) ON DELETE SET NULL
      )
    ''');

    // Create attendance table (used by StudentService)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS attendance (
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
        additionalData TEXT,
        FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE,
        FOREIGN KEY (schoolId) REFERENCES $tableSchools (id) ON DELETE CASCADE
      )
    ''');

    // Create grades table (used by StudentService)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS grades (
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
        additionalData TEXT,
        FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE,
        FOREIGN KEY (schoolId) REFERENCES $tableSchools (id) ON DELETE CASCADE
      )
    ''');

    // Optional: reports table stub for future use
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reports (
        id TEXT PRIMARY KEY,
        student_id TEXT,
        schoolId TEXT,
        title TEXT,
        content TEXT,
        report_date TEXT,
        $columnCreatedAt TEXT
      )
    ''');

    // Create teachers table
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

    // Create subjects table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS subjects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT UNIQUE NOT NULL,
        school_id TEXT,
        stage_id TEXT,
        description TEXT,
        credits INTEGER DEFAULT 3,
        is_active INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (school_id) REFERENCES schools (id) ON DELETE CASCADE,
        FOREIGN KEY (stage_id) REFERENCES school_stages (id) ON DELETE CASCADE
      )
    ''');
  }

  // Upgrade database
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations
    if (oldVersion < 2) {
      // Ensure new tables exist if upgrading from v1
      await db.execute('''
        CREATE TABLE IF NOT EXISTS students (
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
          $columnIsActive INTEGER DEFAULT 1,
          $columnCreatedAt TEXT,
          $columnUpdatedAt TEXT,
          FOREIGN KEY (schoolId) REFERENCES $tableSchools (id) ON DELETE CASCADE,
          FOREIGN KEY (stageId) REFERENCES $tableSchoolStages (id) ON DELETE SET NULL,
          FOREIGN KEY (classGroupId) REFERENCES $tableClassGroups (id) ON DELETE SET NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS attendance (
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
          additionalData TEXT,
          FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE,
          FOREIGN KEY (schoolId) REFERENCES $tableSchools (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS grades (
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
          additionalData TEXT,
          FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE,
          FOREIGN KEY (schoolId) REFERENCES $tableSchools (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS reports (
          id TEXT PRIMARY KEY,
          student_id TEXT,
          schoolId TEXT,
          title TEXT,
          content TEXT,
          report_date TEXT,
          $columnCreatedAt TEXT
        )
      ''');
    }
    if (oldVersion < 3) {
      // Add schoolId to reports if it doesn't exist (older installs)
      try {
        await db.execute('ALTER TABLE reports ADD COLUMN schoolId TEXT');
      } catch (_) {
        // Column may already exist; ignore
      }

      // Backfill reports.schoolId from students table
      await db.execute('''
        UPDATE reports
        SET schoolId = (
          SELECT schoolId FROM students s WHERE s.id = reports.student_id
        )
        WHERE schoolId IS NULL OR schoolId = ''
      ''');

      // Ensure attendance.schoolId is aligned with students.schoolId
      await db.execute('''
        UPDATE attendance
        SET schoolId = (
          SELECT schoolId FROM students s WHERE s.id = attendance.studentId
        )
        WHERE studentId IN (SELECT id FROM students)
      ''');

      // Ensure grades.schoolId is aligned with students.schoolId
      await db.execute('''
        UPDATE grades
        SET schoolId = (
          SELECT schoolId FROM students s WHERE s.id = grades.studentId
        )
        WHERE studentId IN (SELECT id FROM students)
      ''');
    }
    if (oldVersion < 4) {
      // Add teachers table
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

      // Create subjects table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS subjects (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          code TEXT UNIQUE NOT NULL,
          school_id TEXT,
          stage_id TEXT,
          description TEXT,
          credits INTEGER DEFAULT 3,
          is_active INTEGER DEFAULT 1,
          created_at TEXT,
          updated_at TEXT,
          FOREIGN KEY (school_id) REFERENCES schools (id) ON DELETE CASCADE,
          FOREIGN KEY (stage_id) REFERENCES school_stages (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  // Close the database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Clear OS-level temporary cache and SQLite auxiliary cache files (WAL/SHM)
  Future<void> clearAppCache() async {
    // 1) Delete temp directory files
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        for (final entity in tempDir.listSync(recursive: true)) {
          try {
            if (entity is File) {
              await entity.delete();
            } else if (entity is Directory) {
              // Avoid deleting the root temp dir itself; clear its contents
              final dir = entity;
              if (await dir.exists()) {
                await dir.delete(recursive: true);
              }
            }
          } catch (_) {}
        }
      }
    } catch (_) {}

    // 2) Delete SQLite WAL/SHM files if present
    try {
      final dbsPath = await getDatabasesPath();
      final base = join(dbsPath, databaseName);
      final shm = File('$base-shm');
      final wal = File('$base-wal');
      if (await shm.exists()) {
        try {
          await shm.delete();
        } catch (_) {}
      }
      if (await wal.exists()) {
        try {
          await wal.delete();
        } catch (_) {}
      }
    } catch (_) {}
  }

  // Explicit utility to sync schoolId in attendance/grades/reports from students table
  Future<void> syncStudentSchoolLinks() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.execute('''
        UPDATE attendance
        SET schoolId = (
          SELECT schoolId FROM students s WHERE s.id = attendance.studentId
        )
        WHERE studentId IN (SELECT id FROM students)
      ''');

      await txn.execute('''
        UPDATE grades
        SET schoolId = (
          SELECT schoolId FROM students s WHERE s.id = grades.studentId
        )
        WHERE studentId IN (SELECT id FROM students)
      ''');

      await txn.execute('''
        UPDATE reports
        SET schoolId = (
          SELECT schoolId FROM students s WHERE s.id = reports.student_id
        )
        WHERE (schoolId IS NULL OR schoolId = '') AND student_id IN (SELECT id FROM students)
      ''');
    });
  }

  // Initialize demo data
  Future<void> initializeDemoData() async {
    final db = await database;

    // Check if data already exists
    final schoolsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM schools WHERE is_active = 1'),
    );

    if (schoolsCount != null && schoolsCount > 0) {
      return; // Data already exists
    }

    await db.transaction((txn) async {
      final now = DateTime.now();
      final nowStr = now.toIso8601String();
      final nowMs = now.millisecondsSinceEpoch;

      // Insert demo school
      await txn.insert('schools', {
        'id': 1,
        'name': 'مدرسة النجاح النموذجية',
        'address': 'بغداد - الكرخ',
        'phone': '07701234567',
        'email': 'info@najah.edu.iq',
        'director_name': 'د. أحمد محمد علي',
        'education_level': 'متوسطة وإعدادية',
        'section': 'أ',
        'student_count': 0,
        'is_active': 1,
        'created_at': nowStr,
        'updated_at': nowStr,
      });

      // Insert stages (6 stages: 3 متوسط + 3 إعدادي)
      final stages = [
        'الصف الأول المتوسط',
        'الصف الثاني المتوسط',
        'الصف الثالث المتوسط',
        'الرابع الإعدادي',
        'الخامس الإعدادي',
        'السادس الإعدادي',
      ];

      for (int i = 0; i < stages.length; i++) {
        await txn.insert('school_stages', {
          'id': i + 1,
          'school_id': 1,
          'name': stages[i],
          'sort_order': i + 1,
          'is_active': 1,
          'created_at': nowStr,
          'updated_at': nowStr,
        });

        // Insert 5 class groups for each stage (أ، ب، ج، د، هـ)
        final sections = ['أ', 'ب', 'ج', 'د', 'هـ'];
        for (int j = 0; j < sections.length; j++) {
          final groupId = (i * 5) + j + 1;
          await txn.insert('class_groups', {
            'id': groupId,
            'school_id': 1,
            'stage_id': i + 1,
            'name': 'شعبة ${sections[j]}',
            'capacity': 40,
            'current_students': 0,
            'is_active': 1,
            'created_at': nowStr,
            'updated_at': nowStr,
          });
        }
      }

      // Insert demo subjects
      final subjects = [
        {'name': 'الرياضيات', 'code': 'MATH'},
        {'name': 'اللغة العربية', 'code': 'ARAB'},
        {'name': 'اللغة الإنجليزية', 'code': 'ENG'},
        {'name': 'العلوم', 'code': 'SCI'},
        {'name': 'التاريخ', 'code': 'HIST'},
        {'name': 'الجغرافية', 'code': 'GEO'},
        {'name': 'التربية الإسلامية', 'code': 'ISLAM'},
        {'name': 'الفيزياء', 'code': 'PHYS'},
        {'name': 'الكيمياء', 'code': 'CHEM'},
        {'name': 'الأحياء', 'code': 'BIO'},
      ];

      for (int i = 0; i < subjects.length; i++) {
        await txn.insert('subjects', {
          'id': 'subj_${i + 1}',
          'name': subjects[i]['name'],
          'code': subjects[i]['code'],
          'school_id': '1',
          'credits': 3,
          'is_active': 1,
          'created_at': nowStr,
          'updated_at': nowStr,
        });
      }

      // Insert demo teachers (3 teachers)
      final teachers = [
        {
          'first_name': 'أحمد',
          'last_name': 'محمود',
          'specialization': 'الرياضيات',
          'employee_id': 'T001',
        },
        {
          'first_name': 'فاطمة',
          'last_name': 'حسن',
          'specialization': 'اللغة العربية',
          'employee_id': 'T002',
        },
        {
          'first_name': 'محمد',
          'last_name': 'علي',
          'specialization': 'العلوم',
          'employee_id': 'T003',
        },
      ];

      for (int i = 0; i < teachers.length; i++) {
        final t = teachers[i];
        await txn.insert('teachers', {
          'id': 'teacher_${i + 1}',
          'first_name': t['first_name'],
          'last_name': t['last_name'],
          'full_name': '${t['first_name']} ${t['last_name']}',
          'employee_id': t['employee_id'],
          'email': '${t['employee_id']?.toString().toLowerCase()}@najah.edu.iq',
          'phone': '07701234${567 + i}',
          'qualification': 'بكالوريوس',
          'specialization': t['specialization'],
          'school_id': '1',
          'status': 'active',
          'hire_date': nowMs,
          'is_active': 1,
          'created_at': nowMs,
          'updated_at': nowMs,
        });
      }

      // Insert demo students (10 students in first stage, first class)
      final maleNames = ['أحمد', 'محمد', 'علي', 'حسن', 'حسين'];
      final femaleNames = ['فاطمة', 'زينب', 'مريم', 'سارة', 'نور'];
      final lastNames = ['عبدالله', 'محمود', 'حسن', 'علي', 'صالح'];

      for (int i = 0; i < 10; i++) {
        final isMale = i < 5;
        final firstName = isMale ? maleNames[i % 5] : femaleNames[i % 5];
        final lastName = lastNames[i % 5];
        final birthDate = DateTime(2008, 1 + (i % 12), 1 + (i % 28));

        await txn.insert('students', {
          'id': 'student_${i + 1}',
          'firstName': firstName,
          'lastName': lastName,
          'fullName': '$firstName $lastName',
          'studentId': 'S${2024}${(i + 1).toString().padLeft(4, '0')}',
          'birthDate': birthDate.toIso8601String(),
          'gender': isMale ? 'ذكر' : 'أنثى',
          'address': 'بغداد - الكرخ',
          'phone': '07701234${567 + i}',
          'parentPhone': '07801234${567 + i}',
          'schoolId': '1',
          'stageId': '1',
          'classGroupId': '1',
          'status': 'active',
          'enrollmentDate': now.toIso8601String(),
          'is_active': 1,
          'created_at': nowStr,
          'updated_at': nowStr,
        });
      }

      // Update class group student count
      await txn.update('class_groups', {
        'current_students': 10,
      }, where: 'id = 1');

      // Update school student count
      await txn.update('schools', {'student_count': 10}, where: 'id = 1');
    });
  }
}
