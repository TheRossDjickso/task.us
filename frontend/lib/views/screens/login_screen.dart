import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/inbox_viewmodel.dart';
import '../../viewmodels/project_viewmodel.dart';
import 'main_layout_screen.dart';
import 'register_screen.dart';

/// Page de connexion pour les utilisateurs existants.
/// Propose une connexion par Email et via Google.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Clé pour le formulaire
  final _formKey = GlobalKey<FormState>();
  
  // Contrôleurs pour les champs de texte
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Gère la connexion par email
  Future<void> _handleEmailLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(authViewModelProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
        );
        if (mounted) {
          // Invalidate user-dependent providers so they reload
          // with the newly authenticated user's data.
          ref.invalidate(projectViewModelProvider);
          ref.invalidate(inboxViewModelProvider);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  /// Gère la connexion via Google
  void _handleGoogleLogin() {
    // Ici, vous intégreriez le package 'google_sign_in'
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Logo de l'application (Task.us)
                Center(
                  child: Image.asset(
                    'images/logo-1024.png',
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 60),
                
                Text(
                  'Bon retour !',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Connectez-vous pour gérer vos projets.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Champ Email
                _buildTextField(
                  label: 'Email',
                  hint: 'votre.email@exemple.com',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Veuillez entrer votre email';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Champ Mot de Passe
                _buildTextField(
                  label: 'Mot de passe',
                  hint: '••••••••',
                  controller: _passwordController,
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Veuillez entrer votre mot de passe';
                    return null;
                  },
                ),
                
                // Mot de passe oublié
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Bouton Connexion Email
                ElevatedButton(
                  onPressed: isLoading ? null : _handleEmailLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: isLoading 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        )
                      : const Text('Se connecter', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                
                const SizedBox(height: 24),
                
                // Séparateur "OU"
                Row(
                  children: [
                    Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OU', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ),
                    Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
                  ],
                ),
                
                const SizedBox(height: 24),

                /* Bouton Google masqué pour le moment
                OutlinedButton.icon(
                  onPressed: _handleGoogleLogin,
                  icon: SizedBox(
                    width: 24,
                    height: 24,
                    child: Image(image: 
                        AssetImage('images/logo-google.png',
                        )
                    ),
                  ),
                  label: Text(
                    'Continuer avec Google',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                */
                
                const SizedBox(height: 32),
                
                // Lien vers l'inscription
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Nouveau ici ? ', style: theme.textTheme.bodyMedium),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: Text(
                        'Créer un compte',
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
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

  /// Widget helper pour les champs de texte (identique à RegisterScreen pour la cohérence)
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
