class AppConstants {
  // App information
  static const String appName = 'Tekniko';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Offline Student Information App for Arusha Technical College';
  static const String appDeveloper = 'Maxmillian Urio';
  static const String appContactEmail = 'airiermonster@gmail.com';
  
  // Developer social links
  static const String developerGithub = 'https://github.com/airiermonster';
  static const String developerTwitter = 'https://x.com/airiermonster';
  static const String developerFacebook = 'https://facebook.com/airiermonster';
  static const String developerInstagram = 'https://instagram.com/airiermonster';
  
  // Routes
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String homeRoute = '/';
  static const String studentDetailsRoute = '/student-details';
  static const String settingsRoute = '/settings';
  static const String addStudentRoute = '/add-student';
  static const String editStudentRoute = '/edit-student';
  
  // Database
  static const String databaseName = 'tekniko_database.db';
  static const int databaseVersion = 1;
  
  // Tables
  static const String studentTable = 'students';
  
  // Student fields
  static const String idField = 'id';
  static const String nameField = 'name';
  static const String admissionNumberField = 'admission_number';
  static const String gradeField = 'grade';
  static const String sectionField = 'section';
  static const String phoneField = 'phone';
  static const String emailField = 'email';
  static const String addressField = 'address';
  static const String parentNameField = 'parent_name';
  static const String parentPhoneField = 'parent_phone';
  static const String dateOfBirthField = 'date_of_birth';
  static const String genderField = 'gender';
  static const String bloodGroupField = 'blood_group';
  static const String medicalConditionsField = 'medical_conditions';
  static const String emergencyContactField = 'emergency_contact';
  static const String photoUrlField = 'photo_url';
  static const String joinDateField = 'join_date';
  static const String lastUpdatedField = 'last_updated';
  
  // Shared Preferences Keys
  static const String firstRunPref = 'first_run';
  static const String themePref = 'theme_mode';
  static const String themePreference = 'theme_preference';
  static const String lastSyncPreference = 'last_sync';
  static const String userPreference = 'user_preference';
  
  // Messages
  static const String studentAddedSuccess = 'Student added successfully';
  static const String studentUpdatedSuccess = 'Student updated successfully';
  static const String studentDeletedSuccess = 'Student deleted successfully';
  static const String studentAddedError = 'Failed to add student';
  static const String studentUpdatedError = 'Failed to update student';
  static const String studentDeletedError = 'Failed to delete student';
  static const String reloadDataConfirmation = 'Are you sure you want to reload all student data from the source file? This may take a moment.';
  static const String reloadDataSuccess = 'Student data reloaded successfully';
  static const String reloadDataError = 'Failed to reload data';
  static const String importSuccess = 'Data imported successfully';
  static const String importError = 'Failed to import data';
  static const String exportSuccess = 'Data exported successfully';
  static const String exportError = 'Failed to export data';
  static const String noStudentsFound = 'No students found';
  static const String searchHint = 'Search by name, admission number, grade...';
  static const String copiedToClipboard = 'Copied to clipboard';
  static const String shareStudentInfo = 'Share student information';
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String invalidAdmissionNumber = 'Please enter a valid admission number';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  static const double defaultElevation = 2.0;
  static const double defaultIconSize = 24.0;
  static const double smallIconSize = 16.0;
  static const double largeIconSize = 32.0;
  static const double avatarSize = 120.0;
  static const double smallAvatarSize = 40.0;
  static const double cardElevation = 0.0;
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Default values
  static const String defaultAvatarAsset = 'assets/images/default_avatar.png';
  static const List<String> genderOptions = ['Male', 'Female', 'Other'];
  static const List<String> bloodGroupOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  static const List<String> gradeOptions = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];
  static const List<String> sectionOptions = ['A', 'B', 'C', 'D', 'E', 'F'];
  
  // Feature flags
  static const bool enableDarkMode = true;
  static const bool enableNotifications = false;
  static const bool enableCloudSync = false;
  static const bool enableBiometricAuth = false;
  static const bool enableExport = true;
  static const bool enableImport = true;
  
  // Error messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String databaseErrorMessage = 'Database error. Please restart the app.';
  
  // Placeholders
  static const String namePlaceholder = 'Enter student name';
  static const String admissionNumberPlaceholder = 'Enter admission number';
  static const String gradePlaceholder = 'Select grade';
  static const String sectionPlaceholder = 'Select section';
  static const String phonePlaceholder = 'Enter phone number';
  static const String emailPlaceholder = 'Enter email address';
  static const String addressPlaceholder = 'Enter address';
  static const String parentNamePlaceholder = 'Enter parent name';
  static const String parentPhonePlaceholder = 'Enter parent phone number';
  static const String dateOfBirthPlaceholder = 'Select date of birth';
  static const String genderPlaceholder = 'Select gender';
  static const String bloodGroupPlaceholder = 'Select blood group';
  static const String medicalConditionsPlaceholder = 'Enter medical conditions (if any)';
  static const String emergencyContactPlaceholder = 'Enter emergency contact';
} 