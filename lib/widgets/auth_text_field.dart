import 'package:flutter/material.dart';
import 'package:project/utils/app_colors.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String labelText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function()? onEditingComplete;
  final void Function(String)? onChanged;
  final FocusNode? nextFocusNode;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.labelText,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onEditingComplete,
    this.onChanged,
    this.nextFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderFocused, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderError, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      onChanged: onChanged,
      onEditingComplete: onEditingComplete ??
          (nextFocusNode != null
              ? () {
                  focusNode.unfocus();
                  nextFocusNode!.requestFocus();
                }
              : null),
      validator: validator,
    );
  }
}

class EmailTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final GlobalKey<FormState>? formKey;
  final void Function(String)? onChanged;

  const EmailTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.nextFocusNode,
    this.formKey,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      focusNode: focusNode,
      labelText: 'Email',
      keyboardType: TextInputType.emailAddress,
      nextFocusNode: nextFocusNode,
      onChanged: onChanged ??
          (_) {
            // Don't validate on change
          },
      onEditingComplete: () {
        formKey?.currentState?.validate();
        if (nextFocusNode != null) {
          focusNode.unfocus();
          nextFocusNode!.requestFocus();
        } else {
          focusNode.unfocus();
        }
      },
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return 'Email is required';
        final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
        if (!emailRegex.hasMatch(text)) return 'Enter a valid email';
        return null;
      },
    );
  }
}

class PasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final GlobalKey<FormState>? formKey;
  final void Function(String)? onChanged;
  final String? Function(String?)? additionalValidator;

  const PasswordTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.nextFocusNode,
    this.formKey,
    this.onChanged,
    this.additionalValidator,
  });

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      focusNode: focusNode,
      labelText: 'Password',
      obscureText: true,
      nextFocusNode: nextFocusNode,
      onChanged: onChanged,
      onEditingComplete: () {
        formKey?.currentState?.validate();
        if (nextFocusNode != null) {
          focusNode.unfocus();
          nextFocusNode!.requestFocus();
        } else {
          focusNode.unfocus();
        }
      },
      validator: (value) {
        final text = value ?? '';
        if (text.isEmpty) return 'Password is required';
        if (text.length < 6) return 'Minimum 6 characters';
        if (additionalValidator != null) {
          return additionalValidator!(value);
        }
        return null;
      },
    );
  }
}

