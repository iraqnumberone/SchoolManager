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
  static const int databaseVersion = 3;

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
        $columnUpdatedAt TEXT
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
        additionalData TEXT
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
        additionalData TEXT
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
          $columnUpdatedAt TEXT
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
          additionalData TEXT
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
          additionalData TEXT
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
        try { await shm.delete(); } catch (_) {}
      }
      if (await wal.exists()) {
        try { await wal.delete(); } catch (_) {}
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
}
