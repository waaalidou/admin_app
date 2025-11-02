import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project/screens/auth/services/auth_service.dart';
import 'package:project/services/database_service.dart';
import 'package:project/widgets/auth_button.dart';
import 'package:project/widgets/auth_text_field.dart';
import 'package:project/utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // get auth service and database service
  final AuthService authService = AuthService();
  final DatabaseService databaseService = DatabaseService();

  //text fields controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) {
      return;
    }
    final email = emailController.text.trim();
    final password = passwordController.text;
    try {
      setState(() {
        _submitting = true;
      });
      final response = await authService.signInWithEmail(email, password);
      if (!mounted) return;

      // Check if login was successful
      if (response.session != null) {
        // Create a student record from the logged-in user
        // This happens in the background and won't block navigation
        databaseService.createStudentFromCurrentUser().then((_) {
          // Student created successfully (or already exists)
        }).catchError((error) {
          // Silently handle errors - table might not exist yet
          print('Note: Student creation from login skipped: $error');
        });
        
        // AuthGate will automatically navigate to HomeScreen
        // No need for manual navigation
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'An error occurred';
        if (e is AuthException) {
          errorMessage = e.message;
        } else if (e is Exception) {
          errorMessage = e.toString();
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build UI
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text(
          'Login',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: ListView(
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Image.asset(
                    'images/OIP.jpg',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 32),
                EmailTextField(
                  controller: emailController,
                  focusNode: _emailFocusNode,
                  nextFocusNode: _passwordFocusNode,
                  formKey: _formKey,
                ),
                const SizedBox(height: 16),
                PasswordTextField(
                  controller: passwordController,
                  focusNode: _passwordFocusNode,
                  formKey: _formKey,
                ),
                const SizedBox(height: 24),
                AuthButton(
                  text: 'Login',
                  onPressed: login,
                  isLoading: _submitting,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
