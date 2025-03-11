import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/student.dart';
import '../providers/student_provider.dart';

class AddEditStudentScreen extends ConsumerStatefulWidget {
  final Student? student;
  
  const AddEditStudentScreen({
    super.key,
    this.student,
  });

  @override
  ConsumerState<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends ConsumerState<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _admissionNumberController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _parentNameController;
  late TextEditingController _parentPhoneController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _medicalConditionsController;
  late TextEditingController _dateOfBirthController;
  
  String _grade = '';
  String _section = '';
  String _gender = '';
  String _bloodGroup = '';
  DateTime? _dateOfBirth;
  
  bool _isEditing = false;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _isEditing = widget.student != null;
    
    // Initialize controllers
    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _admissionNumberController = TextEditingController(text: widget.student?.admissionNumber ?? '');
    _phoneController = TextEditingController(text: widget.student?.phone ?? '');
    _emailController = TextEditingController(text: widget.student?.email ?? '');
    _addressController = TextEditingController(text: widget.student?.address ?? '');
    _parentNameController = TextEditingController(text: widget.student?.parentName ?? '');
    _parentPhoneController = TextEditingController(text: widget.student?.parentPhone ?? '');
    _emergencyContactController = TextEditingController(text: widget.student?.emergencyContact ?? '');
    _medicalConditionsController = TextEditingController(text: widget.student?.medicalConditions ?? '');
    
    // Initialize dropdown values
    _grade = widget.student?.grade ?? '';
    _section = widget.student?.section ?? '';
    _gender = widget.student?.gender ?? '';
    _bloodGroup = widget.student?.bloodGroup ?? '';
    
    // Initialize date of birth
    _dateOfBirth = widget.student?.dateOfBirth;
    _dateOfBirthController = TextEditingController(
      text: _dateOfBirth != null 
          ? DateFormat('yyyy-MM-dd').format(_dateOfBirth!) 
          : '',
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _admissionNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _emergencyContactController.dispose();
    _medicalConditionsController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
        _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
  
  Future<void> _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final student = Student(
          id: widget.student?.id,
          name: _nameController.text,
          admissionNumber: _admissionNumberController.text,
          grade: _grade,
          section: _section,
          phone: _phoneController.text,
          email: _emailController.text,
          address: _addressController.text,
          parentName: _parentNameController.text,
          parentPhone: _parentPhoneController.text,
          dateOfBirth: _dateOfBirth,
          gender: _gender,
          bloodGroup: _bloodGroup,
          medicalConditions: _medicalConditionsController.text,
          emergencyContact: _emergencyContactController.text,
          photoUrl: widget.student?.photoUrl,
          joinDate: widget.student?.joinDate ?? DateTime.now(),
          lastUpdated: DateTime.now(),
        );
        
        if (_isEditing) {
          await ref.read(studentRepositoryProvider).updateStudent(student);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppConstants.studentUpdatedSuccess),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          await ref.read(studentRepositoryProvider).addStudent(student);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppConstants.studentAddedSuccess),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
        
        // Refresh student list
        ref.refresh(allStudentsProvider);
        
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing 
                  ? AppConstants.studentUpdatedError 
                  : AppConstants.studentAddedError),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom app bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    _isEditing ? 'Edit Student' : 'Add Student',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  children: [
                    // Personal Information Section
                    _SectionHeader(title: 'Personal Information'),
                    
                    const SizedBox(height: 16),
                    
                    // Name field
                    _FormField(
                      label: 'Full Name',
                      controller: _nameController,
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppConstants.requiredField;
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Admission Number field
                    _FormField(
                      label: 'Admission Number',
                      controller: _admissionNumberController,
                      icon: Icons.numbers_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppConstants.requiredField;
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Grade and Section in a row
                    Row(
                      children: [
                        // Grade dropdown
                        Expanded(
                          child: _DropdownField(
                            label: 'Grade',
                            value: _grade.isEmpty ? null : _grade,
                            items: AppConstants.gradeOptions,
                            icon: Icons.grade_outlined,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _grade = value;
                                });
                              }
                            },
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Section dropdown
                        Expanded(
                          child: _DropdownField(
                            label: 'Section',
                            value: _section.isEmpty ? null : _section,
                            items: AppConstants.sectionOptions,
                            icon: Icons.group_outlined,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _section = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Gender and Blood Group in a row
                    Row(
                      children: [
                        // Gender dropdown
                        Expanded(
                          child: _DropdownField(
                            label: 'Gender',
                            value: _gender.isEmpty ? null : _gender,
                            items: AppConstants.genderOptions,
                            icon: Icons.people_outline,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _gender = value;
                                });
                              }
                            },
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Blood Group dropdown
                        Expanded(
                          child: _DropdownField(
                            label: 'Blood Group',
                            value: _bloodGroup.isEmpty ? null : _bloodGroup,
                            items: AppConstants.bloodGroupOptions,
                            icon: Icons.bloodtype_outlined,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _bloodGroup = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Date of Birth field
                    _DatePickerField(
                      label: 'Date of Birth',
                      controller: _dateOfBirthController,
                      icon: Icons.calendar_today_outlined,
                      onTap: () => _selectDate(context),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Contact Information Section
                    _SectionHeader(title: 'Contact Information'),
                    
                    const SizedBox(height: 16),
                    
                    // Phone field
                    _FormField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Email field
                    _FormField(
                      label: 'Email Address',
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          // Simple email validation
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return AppConstants.invalidEmail;
                          }
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Address field
                    _FormField(
                      label: 'Address',
                      controller: _addressController,
                      icon: Icons.home_outlined,
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Parent/Guardian Information Section
                    _SectionHeader(title: 'Parent/Guardian Information'),
                    
                    const SizedBox(height: 16),
                    
                    // Parent Name field
                    _FormField(
                      label: 'Parent/Guardian Name',
                      controller: _parentNameController,
                      icon: Icons.person_outline,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Parent Phone field
                    _FormField(
                      label: 'Parent/Guardian Phone',
                      controller: _parentPhoneController,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Emergency Contact field
                    _FormField(
                      label: 'Emergency Contact',
                      controller: _emergencyContactController,
                      icon: Icons.emergency_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Medical Information Section
                    _SectionHeader(title: 'Medical Information'),
                    
                    const SizedBox(height: 16),
                    
                    // Medical Conditions field
                    _FormField(
                      label: 'Medical Conditions (if any)',
                      controller: _medicalConditionsController,
                      icon: Icons.medical_services_outlined,
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Save button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _isEditing ? 'Update Student' : 'Add Student',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Cancel button
                    SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Divider(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          thickness: 2,
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _FormField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final IconData icon;
  final void Function(String?)? onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
    );
  }
} 