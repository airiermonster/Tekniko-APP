import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SearchUtils {
  /// Performs fuzzy search on a string
  static bool fuzzyMatch(String source, String pattern) {
    // Properly handle empty strings
    if (pattern.isEmpty) return true;
    if (source.isEmpty) return false;
    
    // Convert both to lowercase for case-insensitive search
    final sourceLC = source.toLowerCase();
    final patternLC = pattern.toLowerCase();
    
    // Exact match check
    if (sourceLC.contains(patternLC)) return true;
    
    // Simple fuzzy matching algorithm
    int sourceIndex = 0;
    int patternIndex = 0;
    int lastMatchIndex = -1;
    int consecutiveMatches = 0;
    bool skippedChar = false;

    while (sourceIndex < sourceLC.length && patternIndex < patternLC.length) {
      if (sourceLC[sourceIndex] == patternLC[patternIndex]) {
        // Characters match
        if (lastMatchIndex == -1 || lastMatchIndex == sourceIndex - 1) {
          consecutiveMatches++;
        } else {
          consecutiveMatches = 1;
        }
        
        lastMatchIndex = sourceIndex;
        patternIndex++;
        
        // If consecutive matches are half the pattern length, it's likely a good match
        if (consecutiveMatches >= patternLC.length / 2) {
          return true;
        }
      } else {
        // Allow one character to be skipped
        if (!skippedChar && patternIndex > 0) {
          skippedChar = true;
          sourceIndex--;  // Retry with the next character
        }
      }
      
      sourceIndex++;
    }
    
    // Match if we've gone through the entire pattern
    return patternIndex == patternLC.length;
  }
  
  /// Calculate the similarity score between two strings (0 to 1)
  static double similarityScore(String source, String pattern) {
    if (pattern.isEmpty) return 1.0;
    if (source.isEmpty) return 0.0;
    
    source = source.toLowerCase();
    pattern = pattern.toLowerCase();
    
    // Exact match
    if (source == pattern) return 1.0;
    if (source.contains(pattern)) return 0.9;
    
    // Calculate Levenshtein distance
    int distance = _levenshteinDistance(source, pattern);
    int maxLength = max(source.length, pattern.length);
    
    // Convert distance to similarity score
    return 1.0 - (distance / maxLength);
  }
  
  /// Calculate Levenshtein distance between two strings
  static int _levenshteinDistance(String s, String t) {
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
  
  static int min(int a, int b) => a < b ? a : b;
  static int max(int a, int b) => a > b ? a : b;
}

/// Enum for search fields
enum SearchField {
  name,
  admissionNumber,
  phoneNumber,
  all
}

extension SearchFieldExtension on SearchField {
  String get displayName {
    switch (this) {
      case SearchField.name:
        return 'Name';
      case SearchField.admissionNumber:
        return 'Admission No.';
      case SearchField.phoneNumber:
        return 'Phone No.';
      case SearchField.all:
        return 'All Fields';
    }
  }
  
  IconData get icon {
    switch (this) {
      case SearchField.name:
        return Icons.person_outline;
      case SearchField.admissionNumber:
        return Icons.numbers_outlined;
      case SearchField.phoneNumber:
        return Icons.phone_outlined;
      case SearchField.all:
        return Icons.search_outlined;
    }
  }
} 