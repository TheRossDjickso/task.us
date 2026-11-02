import 'package:flutter/material.dart';

/// Modal bottom sheet for inviting a new member to the project.
/// The roles match the backend: admin, member, viewer.
class InviteMemberModal extends StatefulWidget {
  final Future<void> Function(String email, String role) onInvite;

  const InviteMemberModal({super.key, required this.onInvite});

  @override
  State<InviteMemberModal> createState() => _InviteMemberModalState();
}

class _InviteMemberModalState extends State<InviteMemberModal> {
  final _emailController = TextEditingController();
  String _selectedRole = 'member';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleInvite() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer une adresse email.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.onInvite(email, _selectedRole);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  /// Returns a user-friendly description for each role.
  String _roleDescription(String role) {
    switch (role) {
      case 'admin':
        return 'Les administrateurs ont un accès complet au projet.';
      case 'member':
        return 'Les membres peuvent modifier les tâches et le contenu du projet.';
      case 'viewer':
        return 'Les observateurs peuvent uniquement consulter le projet.';
      default:
        return '';
    }
  }

  /// Returns a French display label for a role.
  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Administrateur';
      case 'member':
        return 'Membre';
      case 'viewer':
        return 'Observateur';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24.0,
        right: 24.0,
        top: 24.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Inviter un membre',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            "Envoyez une invitation pour rejoindre l'équipe du projet.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFB1B1B1),
            ),
          ),
          const SizedBox(height: 24.0),

          // Email input
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Adresse email',
              hintText: 'collegue@entreprise.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              prefixIcon: const Icon(Icons.email_outlined),
              errorText: _errorMessage,
            ),
          ),
          const SizedBox(height: 16.0),

          // Role dropdown
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: InputDecoration(
              labelText: 'Rôle',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
            items: [
              DropdownMenuItem(
                value: 'admin',
                child: Text(_roleLabel('admin')),
              ),
              DropdownMenuItem(
                value: 'member',
                child: Text(_roleLabel('member')),
              ),
              DropdownMenuItem(
                value: 'viewer',
                child: Text(_roleLabel('viewer')),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedRole = value;
                });
              }
            },
          ),
          const SizedBox(height: 8.0),
          Text(
            _roleDescription(_selectedRole),
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFFB1B1B1),
            ),
          ),
          const SizedBox(height: 32.0),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                child: Text(
                  'Annuler',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleInvite,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Envoyer',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }
}
