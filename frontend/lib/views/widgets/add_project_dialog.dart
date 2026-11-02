import 'package:flutter/material.dart';

// Interactive dialog for creating a new project.
// Designed following the 8px border guidelines, colors of the
// Diag Plus palette, and input fields with top labels.
class AddProjectDialog extends StatefulWidget {
  const AddProjectDialog({super.key});

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Active';
  String _selectedPriority = 'Normal';
  String _selectedIcon = 'rocket_launch';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Submits the form if valid and creates the new object.
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
      });
    }
  }

  // Common input field with top label.
  Widget _buildField({
    required BuildContext context,
    required String label,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11.0,
          ),
        ),
        const SizedBox(height: 8.0),
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Common decoration for inputs.
    InputDecoration inputDecoration(String hint) {
      return InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.all(12.0),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      backgroundColor: theme.colorScheme.surface,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400.0),
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Create Project',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24.0),
                // Title.
                _buildField(
                  context: context,
                  label: 'Project Title',
                  child: TextFormField(
                    controller: _titleController,
                    decoration: inputDecoration('Enter title...'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                // Description.
                _buildField(
                  context: context,
                  label: 'Description',
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: inputDecoration(
                      'Describe the project...',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                // Row with Category and Priority.
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        context: context,
                        label: 'Category',
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: inputDecoration(''),
                          items: const [
                            DropdownMenuItem(
                              value: 'Active',
                              child: Text('Active'),
                            ),
                            DropdownMenuItem(
                              value: 'Planning',
                              child: Text('Planning'),
                            ),
                            DropdownMenuItem(
                              value: 'Dev',
                              child: Text('Dev'),
                            ),
                            DropdownMenuItem(
                              value: 'Creative',
                              child: Text('Creative'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _buildField(
                        context: context,
                        label: 'Priority',
                        child: DropdownButtonFormField<String>(
                          value: _selectedPriority,
                          decoration: inputDecoration(''),
                          items: const [
                            DropdownMenuItem(
                              value: 'Normal',
                              child: Text('Normal'),
                            ),
                            DropdownMenuItem(
                              value: 'High',
                              child: Text('High'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedPriority = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                // Icon.
                _buildField(
                  context: context,
                  label: 'Project Icon',
                  child: DropdownButtonFormField<String>(
                    value: _selectedIcon,
                    decoration: inputDecoration(''),
                    items: const [
                      DropdownMenuItem(
                        value: 'rocket_launch',
                        child: Row(
                          children: [
                            Icon(Icons.rocket_launch, size: 20.0),
                            SizedBox(width: 8.0),
                            Text('Rocket'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'folder_open',
                        child: Row(
                          children: [
                            Icon(Icons.folder_open, size: 20.0),
                            SizedBox(width: 8.0),
                            Text('Folder'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'query_stats',
                        child: Row(
                          children: [
                            Icon(Icons.query_stats, size: 20.0),
                            SizedBox(width: 8.0),
                            Text('Stats'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'terminal',
                        child: Row(
                          children: [
                            Icon(Icons.terminal, size: 20.0),
                            SizedBox(width: 8.0),
                            Text('Terminal'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'brush',
                        child: Row(
                          children: [
                            Icon(Icons.brush, size: 20.0),
                            SizedBox(width: 8.0),
                            Text('Brush'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedIcon = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24.0),
                // Action buttons.
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Secondary Cancel button.
                    SizedBox(
                      height: 40.0,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: theme.colorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    // Primary Create button.
                    SizedBox(
                      height: 40.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: _submitForm,
                        child: const Text('Create'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
