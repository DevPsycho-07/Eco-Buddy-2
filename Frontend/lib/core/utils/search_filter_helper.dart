// ignore_for_file: dangling_library_doc_comments

/// Search and filter utilities
/// 
/// Provides reusable search and filtering functionality.
/// 
/// Example:
/// ```dart
/// final filtered = SearchHelper.filterList(
///   items: activities,
///   query: searchQuery,
///   searchFields: (activity) => [
///     activity.name,
///     activity.category,
///   ],
/// );
/// ```
library;

import 'package:flutter/material.dart';

/// Search and filter helper
class SearchHelper {
  /// Filter a list based on search query
  /// 
  /// Returns items that match the query in any of the search fields.
  static List<T> filterList<T>({
    required List<T> items,
    required String query,
    required List<String> Function(T item) searchFields,
  }) {
    if (query.isEmpty) return items;

    final lowerQuery = query.toLowerCase();
    return items.where((item) {
      final fields = searchFields(item);
      return fields.any((field) => 
        field.toLowerCase().contains(lowerQuery)
      );
    }).toList();
  }

  /// Sort a list by a field
  static List<T> sortList<T>({
    required List<T> items,
    required Comparable Function(T item) sortField,
    bool descending = false,
  }) {
    final sorted = List<T>.from(items);
    sorted.sort((a, b) {
      final comparison = sortField(a).compareTo(sortField(b));
      return descending ? -comparison : comparison;
    });
    return sorted;
  }

  /// Filter by category
  static List<T> filterByCategory<T>({
    required List<T> items,
    required String? category,
    required String Function(T item) categoryField,
  }) {
    if (category == null || category.isEmpty) return items;
    return items.where((item) => categoryField(item) == category).toList();
  }

  /// Filter by date range
  static List<T> filterByDateRange<T>({
    required List<T> items,
    required DateTime? startDate,
    required DateTime? endDate,
    required DateTime Function(T item) dateField,
  }) {
    return items.where((item) {
      final date = dateField(item);
      if (startDate != null && date.isBefore(startDate)) return false;
      if (endDate != null && date.isAfter(endDate)) return false;
      return true;
    }).toList();
  }
}

/// Reusable search bar widget
class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final bool autoFocus;

  const SearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.hintText = 'Search...',
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autoFocus,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                  onClear?.call();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}

/// Filter chip widget
class FilterChipGroup extends StatelessWidget {
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String?> onSelected;
  final bool allowDeselect;

  const FilterChipGroup({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
    this.allowDeselect = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option == selectedOption;
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            if (allowDeselect && isSelected) {
              onSelected(null);
            } else {
              onSelected(option);
            }
          },
        );
      }).toList(),
    );
  }
}

/// Sort options widget
class SortOptions extends StatelessWidget {
  final List<SortOption> options;
  final String selectedOption;
  final ValueChanged<String> onChanged;

  const SortOptions({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort),
      onSelected: onChanged,
      itemBuilder: (context) => options.map((option) {
        return PopupMenuItem<String>(
          value: option.value,
          child: Row(
            children: [
              Icon(
                option.icon,
                size: 20,
                color: option.value == selectedOption
                    ? Theme.of(context).primaryColor
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                option.label,
                style: TextStyle(
                  fontWeight: option.value == selectedOption
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Sort option model
class SortOption {
  final String value;
  final String label;
  final IconData icon;

  const SortOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}
