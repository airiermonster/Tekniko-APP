import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/database_helper.dart';
import '../models/student_model.dart';

class StudentRepositoryImpl implements StudentRepository {
  final DatabaseHelper _databaseHelper;

  StudentRepositoryImpl({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper() {
    // Debug on init
    _debugInit();
  }
  
  Future<void> _debugInit() async {
    print('REPOSITORY: Initializing and checking database');
    await _databaseHelper.checkAndDebugDatabase();
  }

  @override
  Future<List<Student>> getAllStudents() async {
    final students = await _databaseHelper.getAllStudents();
    return students;
  }

  @override
  Future<List<Student>> searchStudentsByName(String query) async {
    final students = await _databaseHelper.searchStudentsByName(query);
    return students;
  }

  @override
  Future<Student?> getStudentByAdmissionNumber(String admissionNumber) async {
    final student = await _databaseHelper.getStudentByAdmissionNumber(admissionNumber);
    return student;
  }

  @override
  Future<Student?> getStudentByPhoneNumber(String phoneNumber) async {
    final student = await _databaseHelper.getStudentByPhoneNumber(phoneNumber);
    return student;
  }

  @override
  Future<void> clearDatabase() async {
    await _databaseHelper.clearDatabase();
  }

  @override
  Future<void> importFromJson(String jsonData) async {
    if (jsonData.isEmpty) {
      // If empty string, use the resetAndReload method for full initialization
      await _databaseHelper.resetAndReloadDatabase();
    } else {
      await _databaseHelper.importFromJson(jsonData);
    }
  }

  @override
  Future<String> exportToJson() async {
    return await _databaseHelper.exportToJson();
  }

  @override
  Future<List<Student>> searchStudentsByField(String query, String field) async {
    final students = await _databaseHelper.searchStudentsByField(query, field);
    return students;
  }

  @override
  Future<List<Student>> advancedSearch(String query, {String? field}) async {
    final students = await _databaseHelper.advancedSearch(query, field: field);
    return students;
  }

  @override
  Future<List<Student>> fuzzySearch(String query, {String? field}) async {
    final students = await _databaseHelper.fuzzySearch(query, field: field);
    return students;
  }
} 