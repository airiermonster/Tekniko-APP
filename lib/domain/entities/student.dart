class Student {
  final String id;
  final String admissionNumber;
  final String name;
  final String phoneNumber;
  final String email;
  final String courseName;
  final String ntaLevel;

  const Student({
    required this.id,
    required this.admissionNumber,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.courseName,
    required this.ntaLevel,
  });

  @override
  String toString() {
    return 'Student(id: $id, admissionNumber: $admissionNumber, name: $name, phoneNumber: $phoneNumber, email: $email, courseName: $courseName, ntaLevel: $ntaLevel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Student &&
        other.id == id &&
        other.admissionNumber == admissionNumber &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.courseName == courseName &&
        other.ntaLevel == ntaLevel;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        admissionNumber.hashCode ^
        name.hashCode ^
        phoneNumber.hashCode ^
        email.hashCode ^
        courseName.hashCode ^
        ntaLevel.hashCode;
  }
} 