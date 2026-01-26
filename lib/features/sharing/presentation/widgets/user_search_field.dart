import 'dart:async';

import 'package:flutter/material.dart';

/// A search text field with debounced input for searching users.
///
/// Features:
/// - Search icon prefix
/// - Clear button suffix when text is present
/// - Debounced onChanged callback (300ms default)
///
/// Example:
/// ```dart
/// UserSearchField(
///   onChanged: (query) => searchUsers(query),
///   debounceDuration: Duration(milliseconds: 300),
/// )
/// ```
class UserSearchField extends StatefulWidget {
  /// Creates a [UserSearchField] widget.
  const UserSearchField({
    super.key,
    required this.onChanged,
    this.hintText = 'Search by username...',
    this.debounceDuration = const Duration(milliseconds: 300),
    this.controller,
    this.autofocus = false,
  });

  /// Callback invoked when the text changes (after debounce).
  final ValueChanged<String> onChanged;

  /// Hint text shown when the field is empty.
  final String hintText;

  /// Duration to wait before invoking [onChanged] after user stops typing.
  final Duration debounceDuration;

  /// Optional text controller for external control.
  final TextEditingController? controller;

  /// Whether to autofocus the field when it appears.
  final bool autofocus;

  @override
  State<UserSearchField> createState() => _UserSearchFieldState();
}

class _UserSearchFieldState extends State<UserSearchField> {
  late TextEditingController _controller;
  Timer? _debounceTimer;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _showClearButton = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _showClearButton) {
      setState(() {
        _showClearButton = hasText;
      });
    }

    // Debounce the callback
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onChanged(_controller.text);
    });
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged('');
    setState(() {
      _showClearButton = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: Icon(
          Icons.search,
          color: colorScheme.onSurfaceVariant,
        ),
        suffixIcon: _showClearButton
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: _clearText,
                tooltip: 'Clear search',
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      textInputAction: TextInputAction.search,
      keyboardType: TextInputType.text,
      autocorrect: false,
      enableSuggestions: false,
    );
  }
}
