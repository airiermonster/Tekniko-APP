import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/student_repository_impl.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';
import '../../utils/search_utils.dart';

// Provider for the student repository
final studentRepositoryProvider = Provider<StudentRepository>(
  (ref) => StudentRepositoryImpl(),
);

// Provider for all students
final allStudentsProvider = FutureProvider<List<Student>>(
  (ref) => ref.watch(studentRepositoryProvider).getAllStudents(),
);

// Provider for student search query
final studentSearchQueryProvider = StateProvider<String>(
  (ref) => '',
);

// Provider for search field
final searchFieldProvider = StateProvider<SearchField>(
  (ref) => SearchField.all,
);

// Provider for enabling/disabling fuzzy search
final fuzzySearchEnabledProvider = StateProvider<bool>(
  (ref) => true,
);

// Provider for filtered students based on search (with enhanced search capabilities)
final filteredStudentsProvider = FutureProvider<List<Student>>((ref) async {
  final query = ref.watch(studentSearchQueryProvider);
  final searchField = ref.watch(searchFieldProvider);
  final fuzzyEnabled = ref.watch(fuzzySearchEnabledProvider);
  final repository = ref.watch(studentRepositoryProvider);
  
  print('Search query: "$query" | Field: ${searchField.displayName} | Fuzzy: $fuzzyEnabled');
  
  if (query.isEmpty) {
    print('Empty query, returning all students');
    return repository.getAllStudents();
  }
  
  // Determine which field to search based on selected search field
  String? fieldName;
  switch (searchField) {
    case SearchField.name:
      fieldName = 'name';
      break;
    case SearchField.admissionNumber:
      fieldName = 'admissionNumber';
      break;
    case SearchField.phoneNumber:
      fieldName = 'phoneNumber';
      break;
    case SearchField.all:
      fieldName = 'all';
      break;
  }
  
  print('Using field: $fieldName for search');
  
  // Use fuzzy search if enabled, otherwise use regular search
  List<Student> results;
  if (fuzzyEnabled) {
    print('Performing fuzzy search');
    results = await repository.fuzzySearch(query, field: fieldName);
  } else {
    print('Performing regular search');
    results = await repository.advancedSearch(query, field: fieldName);
  }
  
  print('Search returned ${results.length} results');
  return results;
});

// Provider for selected student
final selectedStudentProvider = StateProvider<Student?>(
  (ref) => null,
);

// Provider for getting student by admission number
final studentByAdmissionNumberProvider = FutureProvider.family<Student?, String>(
  (ref, admissionNumber) => 
      ref.watch(studentRepositoryProvider).getStudentByAdmissionNumber(admissionNumber),
);

// Provider for getting student by phone number
final studentByPhoneNumberProvider = FutureProvider.family<Student?, String>(
  (ref, phoneNumber) => 
      ref.watch(studentRepositoryProvider).getStudentByPhoneNumber(phoneNumber),
);

// Recent searches provider
class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier() : super([]);

  void addSearch(String query) {
    if (query.isEmpty) return;
    
    // Remove if already exists to avoid duplicates
    state = state.where((element) => element != query).toList();
    
    // Add to the beginning of the list
    state = [query, ...state];
    
    // Keep only the last 5 searches
    if (state.length > 5) {
      state = state.sublist(0, 5);
    }
  }

  void clearSearches() {
    state = [];
  }
}

final recentSearchesProvider = StateNotifierProvider<RecentSearchesNotifier, List<String>>(
  (ref) => RecentSearchesNotifier(),
); 