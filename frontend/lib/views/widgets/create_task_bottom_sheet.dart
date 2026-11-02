import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/member.dart';
import '../../models/task.dart';
import '../../viewmodels/task_viewmodel.dart';

/// Bottom sheet for creating or editing a task.
/// Includes fields for Title, Description, Assignee (from project members), and Priority.
class CreateTaskBottomSheet extends ConsumerStatefulWidget {
  final String projectId;
  final Task? taskToEdit;
  final String? initialDueDate;

  const CreateTaskBottomSheet({
    super.key,
    required this.projectId,
    this.taskToEdit,
    this.initialDueDate,
  });

  @override
  ConsumerState<CreateTaskBottomSheet> createState() => _CreateTaskBottomSheetState();
}

class _CreateTaskBottomSheetState extends ConsumerState<CreateTaskBottomSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  
  String? _selectedAssigneeId;
  int _selectedPriority = 2; // Default to Normal (2)
  String? _selectedDueDate;
  bool _isLoading = false;

  bool get _isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title ?? '');
    _descriptionController = TextEditingController(text: widget.taskToEdit?.description ?? '');
    _selectedAssigneeId = widget.taskToEdit?.assignedTo;
    _selectedPriority = widget.taskToEdit?.priority ?? 2;
    _selectedDueDate = widget.taskToEdit?.dueDate ?? widget.initialDueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime initialDate;
    if (_selectedDueDate != null) {
      initialDate = DateTime.tryParse(_selectedDueDate!) ?? DateTime.now();
    } else {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF87941),
              onPrimary: Color(0xFFFDFCFC),
              onSurface: Color(0xFF2F3035),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isEditing) {
        await ref.read(taskViewModelProvider.notifier).updateTask(
          taskId: widget.taskToEdit!.id,
          title: title,
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          assignedTo: _selectedAssigneeId,
          dueDate: _selectedDueDate,
        );
      } else {
        await ref.read(taskViewModelProvider.notifier).addTask(
          title: title,
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          assignedTo: _selectedAssigneeId,
          dueDate: _selectedDueDate,
        );
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get actual project members from taskViewModel state.
    final taskState = ref.watch(taskViewModelProvider).valueOrNull;
    final List<Member> members = taskState?.members ?? [];

    // Safeguard to ensure selected assignee exists in loaded members list
    final bool assigneeExists = members.any((m) => m.id == _selectedAssigneeId);
    final String? dropdownAssigneeValue = assigneeExists ? _selectedAssigneeId : null;

    final inputDecorationTheme = InputDecorationTheme(
      filled: true,
      fillColor: theme.colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFFE6E4E6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24.0,
        right: 24.0,
        top: 24.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditing ? 'Modifier la tâche' : 'Créer une tâche',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Title
            Text(
              'Titre de la tâche',
              style: theme.textTheme.labelMedium?.copyWith(
                color: const Color(0xFFB1B1B1),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _titleController,
              autofocus: !_isEditing,
              style: TextStyle(color: theme.colorScheme.onSurface),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Ex: Faire le design...',
                hintStyle: const TextStyle(color: Color(0xFFB1B1B1)),
              ).applyDefaults(inputDecorationTheme),
            ),
            const SizedBox(height: 20.0),

            // Description
            Text(
              'Description',
              style: theme.textTheme.labelMedium?.copyWith(
                color: const Color(0xFFB1B1B1),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: TextStyle(color: theme.colorScheme.onSurface),
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Détails de la tâche...',
                hintStyle: const TextStyle(color: Color(0xFFB1B1B1)),
              ).applyDefaults(inputDecorationTheme),
            ),
            const SizedBox(height: 20.0),

            // Assignee Dropdown
            Text(
              'Assigner à',
              style: theme.textTheme.labelMedium?.copyWith(
                color: const Color(0xFFB1B1B1),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<String>(
              value: dropdownAssigneeValue,
              hint: const Text(
                'Sélectionner des membres',
                style: TextStyle(color: Color(0xFFB1B1B1)),
              ),
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: const InputDecoration().applyDefaults(inputDecorationTheme),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Non assigné', style: TextStyle(color: Color(0xFFB1B1B1))),
                ),
                ...members.map(
                  (member) => DropdownMenuItem<String>(
                    value: member.id,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: NetworkImage(member.avatarUrl),
                        ),
                        const SizedBox(width: 8),
                        Text(member.name),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedAssigneeId = val;
                });
              },
            ),
            const SizedBox(height: 20.0),

            // Priority Dropdown
            Text(
              'Priorité',
              style: theme.textTheme.labelMedium?.copyWith(
                color: const Color(0xFFB1B1B1),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<int>(
              value: _selectedPriority,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: const InputDecoration().applyDefaults(inputDecorationTheme),
              items: const [
                DropdownMenuItem<int>(
                  value: 1,
                  child: Text('Basse'),
                ),
                DropdownMenuItem<int>(
                  value: 2,
                  child: Text('Normale'),
                ),
                DropdownMenuItem<int>(
                  value: 3,
                  child: Text('Haute'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedPriority = val;
                  });
                }
              },
            ),
            const SizedBox(height: 20.0),

            // Due Date Selector
            Text(
              "Date d'échéance",
              style: theme.textTheme.labelMedium?.copyWith(
                color: const Color(0xFFB1B1B1),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8.0),
            InkWell(
              onTap: () => _selectDueDate(context),
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: const Color(0xFFE6E4E6)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 20,
                            color: _selectedDueDate != null
                                ? theme.colorScheme.primary
                                : const Color(0xFFB1B1B1),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDueDate ?? 'Aucune date',
                            style: TextStyle(
                              color: _selectedDueDate != null
                                  ? theme.colorScheme.onSurface
                                  : const Color(0xFFB1B1B1),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedDueDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20, color: Color(0xFFB1B1B1)),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            _selectedDueDate = null;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32.0),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48.0,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFB1B1B1),
                        side: const BorderSide(color: Color(0xFFE6E4E6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: SizedBox(
                    height: 48.0,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isEditing ? 'Enregistrer' : 'Créer',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}

/// Utility function to show the create or edit task bottom sheet.
void showCreateTaskBottomSheet(
  BuildContext context,
  String projectId, {
  Task? taskToEdit,
  String? initialDueDate,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFFDFCFC),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
    builder: (context) => CreateTaskBottomSheet(
      projectId: projectId,
      taskToEdit: taskToEdit,
      initialDueDate: initialDueDate,
    ),
  );
}
