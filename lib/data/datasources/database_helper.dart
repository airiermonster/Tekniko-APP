import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/student_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'student_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id TEXT PRIMARY KEY,
        admissionNumber TEXT,
        name TEXT,
        phoneNumber TEXT,
        email TEXT,
        courseName TEXT,
        ntaLevel TEXT
      )
    ''');
    await _loadInitialData(db);
  }

  Future<void> _loadInitialData(Database db) async {
    try {
      print('Database: Loading initial student data');
      final String data = await rootBundle.loadString('assets/data/students.json');
      final List<dynamic> jsonData = json.decode(data);
      
      print('Database: Loaded ${jsonData.length} rows from JSON data');
      
      if (jsonData.isEmpty || jsonData[0].isEmpty) {
        print('Database: JSON data is empty or malformed');
        return;
      }
      
      // The first row contains the column headers
      final List<String> headers = List<String>.from(jsonData[0].map((header) {
        // Remove the backticks from the headers
        return header.toString().replaceAll('`', '');
      }));
      
      print('Database: Column headers: $headers');
      
      final Uuid uuid = Uuid();
      int inserted = 0;
      
      // Start from index 1 to skip the headers
      for (int i = 1; i < jsonData.length; i++) { // Removed the limit to load all students
        final rowData = jsonData[i];
        
        // Skip empty rows or incomplete data
        if (rowData.length < headers.length) {
          print('Database: Skipping row $i due to incomplete data');
          continue;
        }
        
        // Create a map from headers to values
        final Map<String, dynamic> studentData = {};
        for (int j = 0; j < headers.length; j++) {
          studentData[headers[j]] = rowData[j].toString();
        }
        
        // Create a student model with the data
        final student = StudentModel.fromJsonV2(
          studentData,
          // Generate a UUID for the ID if not present
          id: uuid.v4(),
        );
        
        await db.insert('students', student.toJson());
        inserted++;
        
        // Print progress periodically
        if (inserted % 500 == 0) {
          print('Database: Inserted $inserted students so far...');
        }
      }
      
      print('Database: Successfully inserted $inserted students');
      
      // Verify that students were inserted
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM students'));
      print('Database: Students count after initialization: $count');
    } catch (e) {
      print('Error loading initial data: $e');
    }
  }

  Future<int> insertStudent(StudentModel student) async {
    final db = await database;
    return await db.insert(
      'students',
      student.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<StudentModel>> getAllStudents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('students');
    
    print('Database: getAllStudents returned ${maps.length} records');
    if (maps.isEmpty) {
      print('Database: No students found in the database!');
    } else {
      print('Database: First student: ${maps.first}');
    }
    
    return List.generate(maps.length, (i) {
      return StudentModel.fromJson(maps[i]);
    });
  }

  Future<List<StudentModel>> searchStudentsByName(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    
    return List.generate(maps.length, (i) {
      return StudentModel.fromJson(maps[i]);
    });
  }

  Future<List<StudentModel>> searchStudentsByField(String query, String field) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: '$field LIKE ?',
      whereArgs: ['%$query%'],
    );
    
    return List.generate(maps.length, (i) {
      return StudentModel.fromJson(maps[i]);
    });
  }
  
  Future<List<StudentModel>> advancedSearch(String query, {String? field}) async {
    if (query.isEmpty) {
      return getAllStudents();
    }
    
    final db = await database;
    List<Map<String, dynamic>> maps = [];
    
    if (field != null && field != 'all') {
      maps = await db.query(
        'students',
        where: '$field LIKE ?',
        whereArgs: ['%$query%'],
      );
    } else {
      // Search across all specified fields
      maps = await db.rawQuery('''
        SELECT * FROM students 
        WHERE name LIKE ? 
        OR admissionNumber LIKE ? 
        OR phoneNumber LIKE ?
      ''', ['%$query%', '%$query%', '%$query%']);
    }
    
    return List.generate(maps.length, (i) {
      return StudentModel.fromJson(maps[i]);
    });
  }
  
  Future<List<StudentModel>> fuzzySearch(String query, {String? field}) async {
    if (query.isEmpty) {
      return getAllStudents();
    }
    
    print('DB Helper: Fuzzy search for "$query" in field "$field"');
    
    // For fuzzy search, we need to get all students and filter in-memory
    final List<StudentModel> allStudents = await getAllStudents();
    print('DB Helper: Got ${allStudents.length} total students to filter');
    
    query = query.toLowerCase();
    List<StudentModel> results = [];
    
    // Lower thresholds to be more lenient with matches
    const double nameThreshold = 0.4;      // Was 0.6, lowered to increase matches
    const double numberThreshold = 0.5;    // Was 0.7, lowered to increase matches
    
    // Filter based on field
    if (field == 'name' || field == null || field == 'all') {
      results = allStudents.where((student) {
        final nameMatch = student.name.toLowerCase().contains(query);
        final similarityScore = _calculateSimilarity(student.name, query);
        final fuzzyMatch = similarityScore > nameThreshold;
        final matched = nameMatch || fuzzyMatch;
        
        if (similarityScore > nameThreshold - 0.1) {  // Log near matches too
          print('DB Helper: Name "${student.name}" for query "$query" - similarity: $similarityScore, matched: $matched');
        }
        return matched;
      }).toList();
    } else if (field == 'admissionNumber') {
      results = allStudents.where((student) {
        final exactMatch = student.admissionNumber.toLowerCase().contains(query);
        final similarityScore = _calculateSimilarity(student.admissionNumber, query);
        final fuzzyMatch = similarityScore > numberThreshold;
        final matched = exactMatch || fuzzyMatch;
        
        if (matched) {
          print('DB Helper: Admission match: "${student.admissionNumber}" for query "$query" - similarity: $similarityScore');
        }
        return matched;
      }).toList();
    } else if (field == 'phoneNumber') {
      results = allStudents.where((student) {
        final exactMatch = student.phoneNumber.toLowerCase().contains(query);
        final similarityScore = _calculateSimilarity(student.phoneNumber, query);
        final fuzzyMatch = similarityScore > numberThreshold;
        final matched = exactMatch || fuzzyMatch;
        
        if (matched) {
          print('DB Helper: Phone match: "${student.phoneNumber}" for query "$query" - similarity: $similarityScore');
        }
        return matched;
      }).toList();
    } else {
      // If no specific field or invalid field, search across all fields
      results = allStudents.where((student) {
        final nameMatch = student.name.toLowerCase().contains(query);
        final admissionMatch = student.admissionNumber.toLowerCase().contains(query);
        final phoneMatch = student.phoneNumber.toLowerCase().contains(query);
        
        final nameSimilarity = _calculateSimilarity(student.name, query);
        final admissionSimilarity = _calculateSimilarity(student.admissionNumber, query);
        final phoneSimilarity = _calculateSimilarity(student.phoneNumber, query);
        
        final nameFuzzy = nameSimilarity > nameThreshold;
        final admissionFuzzy = admissionSimilarity > numberThreshold;
        final phoneFuzzy = phoneSimilarity > numberThreshold;
        
        final matched = nameMatch || admissionMatch || phoneMatch || nameFuzzy || admissionFuzzy || phoneFuzzy;
        
        if (matched) {
          print('DB Helper: Multi-field match for "$query": ${student.name} - name similarity: $nameSimilarity');
        }
        return matched;
      }).toList();
    }
    
    print('DB Helper: Fuzzy search returned ${results.length} results');
    return results;
  }
  
  double _calculateSimilarity(String source, String query) {
    source = source.toLowerCase();
    query = query.toLowerCase();
    
    // Exact match or contains check
    if (source == query) return 1.0;
    if (source.contains(query)) return 0.9;
    
    // Check if query is part of a word in source (word boundary match)
    final words = source.split(RegExp(r'\s+'));
    for (var word in words) {
      if (word.startsWith(query)) return 0.8;
      if (word.contains(query)) return 0.7;
    }
    
    // Simple Levenshtein distance based similarity
    int maxLength = source.length > query.length ? source.length : query.length;
    if (maxLength == 0) return 0.0;
    
    int distance = _levenshteinDistance(source, query);
    
    // Normalize the distance to get a similarity score
    // Use query length in denominator to favor partial matches in longer source strings
    return 1.0 - (distance / (query.length * 2 + 0.1));
  }
  
  int _levenshteinDistance(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;
    
    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);
    
    for (int i = 0; i < v0.length; i++) {
      v0[i] = i;
    }
    
    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      
      for (int j = 0; j < t.length; j++) {
        int cost = s[i] == t[j] ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      
      // Swap v0 and v1
      List<int> temp = v0;
      v0 = v1;
      v1 = temp;
    }
    
    return v0[t.length];
  }
  
  int min(int a, int b) => a < b ? a : b;

  Future<StudentModel?> getStudentByAdmissionNumber(String admissionNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'admissionNumber = ?',
      whereArgs: [admissionNumber],
    );
    
    if (maps.isNotEmpty) {
      return StudentModel.fromJson(maps.first);
    }
    return null;
  }

  Future<StudentModel?> getStudentByPhoneNumber(String phoneNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'phoneNumber = ?',
      whereArgs: [phoneNumber],
    );
    
    if (maps.isNotEmpty) {
      return StudentModel.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateStudent(StudentModel student) async {
    final db = await database;
    return await db.update(
      'students',
      student.toJson(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(String id) async {
    final db = await database;
    return await db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('students');
  }

  Future<void> importFromJson(String jsonData) async {
    try {
      // If jsonData is empty, load the bundled data
      if (jsonData.isEmpty) {
        await clearDatabase();
        final db = await database;
        await _loadInitialData(db);
        return;
      }
      
      final db = await database;
      final List<dynamic> data = json.decode(jsonData);
      final Uuid uuid = Uuid();
      
      await db.transaction((txn) async {
        // Check if first row has headers
        if (data.isNotEmpty && data[0] is List && data[0].length > 0) {
          final List<String> headers = List<String>.from(data[0].map((header) {
            return header.toString().replaceAll('`', '');
          }));
          
          // Start from index 1 to skip the headers
          for (int i = 1; i < data.length; i++) {
            final rowData = data[i];
            
            // Skip empty rows or incomplete data
            if (rowData.length < headers.length) continue;
            
            // Create a map from headers to values
            final Map<String, dynamic> studentData = {};
            for (int j = 0; j < headers.length; j++) {
              studentData[headers[j]] = rowData[j].toString();
            }
            
            // Create a student model with the data
            final student = StudentModel.fromJsonV2(
              studentData,
              id: uuid.v4(),
            );
            
            await txn.insert(
              'students',
              student.toJson(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        } else {
          // Handle regular JSON objects
          for (var item in data) {
            if (item is Map<String, dynamic>) {
              final student = StudentModel.fromJson(item);
              await txn.insert(
                'students',
                student.toJson(),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
        }
      });
    } catch (e) {
      print('Error importing from JSON: $e');
      rethrow;
    }
  }

  Future<String> exportToJson() async {
    try {
      final students = await getAllStudents();
      final List<Map<String, dynamic>> jsonList = 
          students.map((student) => student.toJson()).toList();
      return json.encode(jsonList);
    } catch (e) {
      print('Error exporting to JSON: $e');
      rethrow;
    }
  }

  // Debug method to check database and import if needed
  Future<void> checkAndDebugDatabase() async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM students'));
    print('DATABASE CHECK: Found $count students in database');
    
    if (count == 0 || count == null) {
      print('DATABASE CHECK: No students found, importing default data');
      await _loadInitialData(db);
      final newCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM students'));
      print('DATABASE CHECK: After import, found $newCount students');
    }
    
    // Check a few records to ensure proper mapping
    final records = await db.query('students', limit: 3);
    if (records.isNotEmpty) {
      print('DATABASE CHECK: Sample records:');
      for (var record in records) {
        print('Record: $record');
        final model = StudentModel.fromJson(record);
        print('Mapped to: Name=${model.name}, AdmissionNumber=${model.admissionNumber}, Phone=${model.phoneNumber}');
      }
    }
  }

  // Method to clear and reload all students from JSON
  Future<void> resetAndReloadDatabase() async {
    print('Database: Starting full reset and reload...');
    final db = await database;
    
    // Clear existing data
    await clearDatabase();
    print('Database: Cleared existing data');
    
    // Load all student data from the JSON file
    await _loadInitialData(db);
    
    // Verify the count after reload
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM students'));
    print('Database: After complete reload, found $count students');
  }
} 