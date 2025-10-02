import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healer_map_flutter/app/router.dart';
import 'package:healer_map_flutter/common/widgets/app_scaffold.dart';
import 'package:healer_map_flutter/features/auth/presentation/controllers/auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:healer_map_flutter/common/widgets/custom_button.dart';
import 'package:healer_map_flutter/common/widgets/custom_text_form_field.dart';
import 'package:healer_map_flutter/core/constants/app_constants.dart';
import 'package:healer_map_flutter/core/localization/app_localization.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController(text: "Jon");
  final _lastNameCtrl = TextEditingController(text: 'Don');
  final _usernameCtrl = TextEditingController(text: 'johndoe@123');
  final _emailCtrl = TextEditingController(text: 'john@example.com');
  final _passwordCtrl = TextEditingController(text: '12345678');
  final _confirmPasswordCtrl = TextEditingController(text: '12345678');

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final localizations = AppLocalizations.of(context);
    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.passwordMismatch)),
      );
      return;
    }

    final fullName = [
      _firstNameCtrl.text.trim(),
      _lastNameCtrl.text.trim(),
    ].where((e) => e.isNotEmpty).join(' ');

    await ref.read(authControllerProvider.notifier).signup(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      name: fullName.isEmpty ? null : fullName,
    );
    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      final err = state.error;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $err')),
      );
    } else if (state.hasValue && state.value != null && mounted) {
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.signupSuccessful),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Navigate to login screen on successful signup
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final localizations = AppLocalizations.of(context);

    return AppScaffold(
      title: localizations.signup,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Illustration
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                child: SizedBox(
                  height: 150,
                  child: Image.asset('assets/images/sign_up.png', fit: BoxFit.contain),
                ),
              ),
              // First Name
              CustomTextFormField(
                title: localizations.fullName.split(' ')[0], // Use first word of "Full Name"
                controller: _firstNameCtrl,
                isForm: true,
                isRequired: true,
                validator: (v) => (v == null || v.trim().isEmpty) ? localizations.nameRequired : null,
              ),
              const SizedBox(height: 12),
              // Last Name
              CustomTextFormField(
                title: 'Last Name',
                controller: _lastNameCtrl,
                isForm: true,
                isRequired: true,
                validator: (v) => (v == null || v.trim().isEmpty) ? localizations.nameRequired : null,
              ),
              const SizedBox(height: 12),
              // Username
              CustomTextFormField(
                title: 'Username',
                controller: _usernameCtrl,
                isForm: true,
                isRequired: true,
                validator: (v) => (v == null || v.trim().isEmpty) ? localizations.nameRequired : null,
              ),
              const SizedBox(height: 12),
              // Email
              CustomTextFormField(
                title: localizations.email,
                controller: _emailCtrl,
                textFormFieldType: TextFormFieldType.email,
                textInputType: TextInputType.emailAddress,
                isForm: true,
                isRequired: true,
                validator: (v) => (v == null || v.trim().isEmpty) ? localizations.emailRequired : null,
              ),
              const SizedBox(height: 12),
              // Password
              CustomTextFormField(
                title: localizations.password,
                controller: _passwordCtrl,
                textFormFieldType: TextFormFieldType.securedPassword,
                isForm: true,
                isRequired: true,
                validator: (v) => (v == null || v.length < 6) ? localizations.passwordTooShort : null,
              ),
              const SizedBox(height: 12),
              // Confirm Password
              CustomTextFormField(
                title: localizations.confirmPassword,
                controller: _confirmPasswordCtrl,
                textFormFieldType: TextFormFieldType.securedPassword,
                isForm: true,
                isRequired: true,
                validator: (v) => (v == null || v.length < 6) ? localizations.passwordTooShort : null,
              ),
              const SizedBox(height: 20),
              // Sign up button
              CustomAppButton(
                title: localizations.signup.toUpperCase(),
                loader: authState.isLoading,
                onPressed: _onSignup,
                height: 50,
                borderRadius: 12,
              ),
              const SizedBox(height: 16),
              // Bottom login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${localizations.alreadyHaveAccount} ', style: Theme.of(context).textTheme.bodyMedium),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.login),
                    child: Text(localizations.login, style: TextStyle(color: ColorConstants.primary, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
