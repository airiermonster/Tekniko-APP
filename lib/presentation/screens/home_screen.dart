import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/student.dart';
import '../../utils/search_utils.dart';
import '../providers/student_provider.dart';
import '../widgets/asset_image_with_fallback.dart';
import '../widgets/placeholder_logo.dart';
import '../widgets/multi_format_image.dart';
import '../widgets/animated_slide_transition.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  String _searchQuery = '';
  bool _showSearchFields = false;

  @override
  void initState() {
    super.initState();
    // Add a listener to detect changes in the search field
    _searchController.addListener(_onSearchChanged);
    
    // Debug: Check if database has data
    _checkDatabaseStatus();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final newQuery = _searchController.text;
    print('SEARCH: Text changed to "$newQuery"');
    
    setState(() {
      _searchQuery = newQuery;
    });
    
    // Update the search provider
    print('SEARCH: Updating provider with query "$newQuery"');
    ref.read(studentSearchQueryProvider.notifier).state = newQuery;
  }

  void _handleStudentTap(Student student) {
    // Add to recent searches
    ref.read(recentSearchesProvider.notifier).addSearch(student.name);
    
    // Set the selected student
    ref.read(selectedStudentProvider.notifier).state = student;
    
    // Navigate to student details screen
    Navigator.pushNamed(context, AppConstants.studentDetailsRoute);
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _isSearching = false;
      _showSearchFields = false;
    });
    ref.read(studentSearchQueryProvider.notifier).state = '';
    FocusScope.of(context).unfocus();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
    _searchFocusNode.requestFocus();
  }
  
  void _toggleSearchFieldsVisibility() {
    setState(() {
      _showSearchFields = !_showSearchFields;
    });
  }
  
  void _setSearchField(SearchField field) {
    ref.read(searchFieldProvider.notifier).state = field;
    // Close the search fields panel if a field is selected
    if (field != SearchField.all) {
      setState(() {
        _showSearchFields = false;
      });
    }
  }
  
  void _toggleFuzzySearch() {
    final currentValue = ref.read(fuzzySearchEnabledProvider);
    ref.read(fuzzySearchEnabledProvider.notifier).state = !currentValue;
  }

  void _checkDatabaseStatus() async {
    // Get all students to check if database is populated
    final repository = ref.read(studentRepositoryProvider);
    final students = await repository.getAllStudents();
    print('DEBUG: Database has ${students.length} students');
    if (students.isNotEmpty) {
      print('DEBUG: First student: ${students[0].name}');
    } else {
      print('DEBUG: No students in database! Importing default data...');
      await repository.importFromJson('');  // Empty string triggers loading bundled data
      final newStudents = await repository.getAllStudents();
      print('DEBUG: After import, database has ${newStudents.length} students');
    }
  }

  // Show confirmation dialog before reloading database
  void _showReloadConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reload Student Data'),
        content: const Text(AppConstants.reloadDataConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              try {
                // Get the repository
                final repository = ref.read(studentRepositoryProvider);
                
                // Import fresh data
                await repository.importFromJson('');
                
                // Refresh UI
                ref.invalidate(allStudentsProvider);
                ref.invalidate(filteredStudentsProvider);
                
                // Hide loading indicator and show success message
                if (mounted) Navigator.pop(context);
                
                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppConstants.reloadDataSuccess),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // Hide loading indicator and show error message
                if (mounted) Navigator.pop(context);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${AppConstants.reloadDataError}: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Reload'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final students = ref.watch(filteredStudentsProvider);
    final recentSearches = ref.watch(recentSearchesProvider);
    final selectedSearchField = ref.watch(searchFieldProvider);
    final fuzzyEnabled = ref.watch(fuzzySearchEnabledProvider);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo and settings
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'app_logo',
                        child: MultiFormatImage(
                          imagePath: 'assets/images/logo.png',
                          width: 40,
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  // Reload data button
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Reload all students',
                    onPressed: () async {
                      _showReloadConfirmDialog();
                    },
                  ),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Search field selection button
                        IconButton(
                          icon: Icon(
                            selectedSearchField.icon,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: _toggleSearchFieldsVisibility,
                          tooltip: 'Search by ${selectedSearchField.displayName}',
                        ),
                        
                        // Search input field
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Search by ${selectedSearchField.displayName.toLowerCase()}',
                              border: InputBorder.none,
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: _clearSearch,
                                    )
                                  : null,
                            ),
                            onTap: _startSearch,
                          ),
                        ),
                        
                        // Fuzzy search toggle
                        IconButton(
                          icon: Icon(
                            fuzzyEnabled ? Icons.api : Icons.text_fields,
                            color: fuzzyEnabled
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          onPressed: _toggleFuzzySearch,
                          tooltip: fuzzyEnabled ? 'Fuzzy Search Enabled' : 'Exact Search Only',
                        ),
                      ],
                    ),
                  ),
                  
                  // Search fields dropdown
                  if (_showSearchFields)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(top: 4.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _SearchFieldOption(
                            field: SearchField.all,
                            isSelected: selectedSearchField == SearchField.all,
                            onTap: () => _setSearchField(SearchField.all),
                            index: 0,
                          ),
                          _SearchFieldOption(
                            field: SearchField.name,
                            isSelected: selectedSearchField == SearchField.name,
                            onTap: () => _setSearchField(SearchField.name),
                            index: 1,
                          ),
                          _SearchFieldOption(
                            field: SearchField.admissionNumber,
                            isSelected: selectedSearchField == SearchField.admissionNumber,
                            onTap: () => _setSearchField(SearchField.admissionNumber),
                            index: 2,
                          ),
                          _SearchFieldOption(
                            field: SearchField.phoneNumber,
                            isSelected: selectedSearchField == SearchField.phoneNumber,
                            onTap: () => _setSearchField(SearchField.phoneNumber),
                            index: 3,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // Recent searches section
            if (_isSearching && _searchQuery.isEmpty && recentSearches.isNotEmpty) 
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Searches',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(recentSearchesProvider.notifier).clearSearches();
                          },
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      children: recentSearches.map((search) {
                        return Chip(
                          label: Text(search),
                          onDeleted: () {
                            // Remove from recent searches and set as current search
                            _searchController.text = search;
                            _searchFocusNode.unfocus();
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            
            // Students list or loading indicator
            Expanded(
              child: students.when(
                data: (studentsList) {
                  if (studentsList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? AppConstants.noStudentsFound
                                : 'No results found for "$_searchQuery"',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (_searchQuery.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Try searching with different keywords or filters',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }
                  
                  return Column(
                    children: [
                      // Students count
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${studentsList.length} ${studentsList.length == 1 ? 'Student' : 'Students'} Found',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              Text(
                                'Search: "$_searchQuery"',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // Students list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: studentsList.length,
                          itemBuilder: (context, index) {
                            final student = studentsList[index];
                            return AnimatedSlideTransition(
                              index: index,
                              child: _StudentCard(
                                student: student,
                                onTap: () => _handleStudentTap(student),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text('Error: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchFieldOption extends StatelessWidget {
  final SearchField field;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  const _SearchFieldOption({
    required this.field,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        // Apply a staggered delay effect by using the index to calculate the animation value
        final delayedValue = index == 0 ? value : (value - (0.1 * index) < 0 ? 0.0 : value - (0.1 * index));
        return Transform.translate(
          offset: Offset(20 * (1 - delayedValue), 0),
          child: Opacity(
            opacity: delayedValue,
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: () {
          // Add haptic feedback
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  field.icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Search by ${field.displayName}',
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;

  const _StudentCard({
    required this.student,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      Theme.of(context).colorScheme.primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    student.name.isNotEmpty
                        ? student.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join().substring(0, student.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join().length > 2 ? 2 : 1).toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Student information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          student.admissionNumber,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            student.courseName,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          student.phoneNumber,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Navigation indicator
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 