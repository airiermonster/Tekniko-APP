import '../../domain/entities/student.dart';

class StudentModel extends Student {
  const StudentModel({
    required String id,
    required String admissionNumber,
    required String name,
    required String phoneNumber,
    required String email,
    required String courseName,
    required String ntaLevel,
  }) : super(
          id: id,
          admissionNumber: admissionNumber,
          name: name,
          phoneNumber: phoneNumber,
          email: email,
          courseName: courseName,
          ntaLevel: ntaLevel,
        );

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? '',
      admissionNumber: json['admissionNumber'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      courseName: json['courseName'] ?? '',
      ntaLevel: json['ntaLevel'] ?? '',
    );
  }

  // New method to handle the format from students.json
  factory StudentModel.fromJsonV2(Map<String, dynamic> json, {required String id}) {
    return StudentModel(
      id: id,
      admissionNumber: json['Admission_Number'] ?? '',
      name: json['Full_Name'] ?? '',
      phoneNumber: json['Mobile_Phone'] ?? '',
      email: json['Email'] ?? '',
      courseName: json['Programme_Enrolled'] ?? '',
      ntaLevel: json['NTA_Level'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admissionNumber': admissionNumber,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'courseName': courseName,
      'ntaLevel': ntaLevel,
    };
  }

  factory StudentModel.fromEntity(Student student) {
    return StudentModel(
      id: student.id,
      admissionNumber: student.admissionNumber,
      name: student.name,
      phoneNumber: student.phoneNumber,
      email: student.email,
      courseName: student.courseName,
      ntaLevel: student.ntaLevel,
    );
  }
} 