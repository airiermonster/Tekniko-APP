import '../entities/student.dart';

abstract class StudentRepository {
  Future<List<Student>> getAllStudents();
  Future<List<Student>> searchStudentsByName(String query);
  Future<Student?> getStudentByAdmissionNumber(String admissionNumber);
  Future<Student?> getStudentByPhoneNumber(String phoneNumber);
  Future<void> clearDatabase();
  Future<void> importFromJson(String jsonData);
  Future<String> exportToJson();
  
  // New search methods
  Future<List<Student>> searchStudentsByField(String query, String field);
  Future<List<Student>> advancedSearch(String query, {String? field});
  Future<List<Student>> fuzzySearch(String query, {String? field});
} 