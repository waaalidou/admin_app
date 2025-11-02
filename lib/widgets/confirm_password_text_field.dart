import 'package:flutter/material.dart';
import 'package:project/widgets/auth_text_field.dart';

class ConfirmPasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController passwordController;
  final FocusNode focusNode;
  final GlobalKey<FormState>? formKey;
  final void Function(String)? onChanged;

  const ConfirmPasswordTextField({
    super.key,
    required this.controller,
    required this.passwordController,
    required this.focusNode,
    this.formKey,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      focusNode: focusNode,
      labelText: 'Confirm Password',
      obscureText: true,
      onChanged: onChanged ??
          (_) {
            // Don't validate on change
          },
      onEditingComplete: () {
        focusNode.unfocus();
        formKey?.currentState?.validate();
      },
      validator: (value) {
        final text = value ?? '';
        if (text.isEmpty) return 'Please confirm your password';
        if (text != passwordController.text) return 'Passwords do not match';
        return null;
      },
    );
  }
}

