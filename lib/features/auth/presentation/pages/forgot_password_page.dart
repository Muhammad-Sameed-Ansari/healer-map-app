import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healer_map_flutter/app/router.dart';
import 'package:healer_map_flutter/common/widgets/app_scaffold.dart';
import 'package:healer_map_flutter/common/widgets/custom_button.dart';
import 'package:healer_map_flutter/common/widgets/custom_text_form_field.dart';
import 'package:healer_map_flutter/features/auth/presentation/controllers/auth_controller.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: _ForgotPasswordBody(),
    );
  }
}

class _ForgotPasswordBody extends ConsumerWidget {
  const _ForgotPasswordBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Forget Password',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _ForgotPasswordForm(),
      ),
    );
  }
}

class _ForgotPasswordForm extends StatefulWidget {
  @override
  State<_ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<_ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'john@example.com');
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Call the forgot password API through auth controller
      final pageState = context.findAncestorStateOfType<_ForgotPasswordPageState>();
      final authNotifier = pageState?.ref?.read(authControllerProvider.notifier);

      if (authNotifier != null) {
        final response = await authNotifier.forgotPassword(_emailCtrl.text.trim());

        if (!mounted) return;

        // Handle response based on status
        final isSuccess = response['status'] == true;
        final message = response['message'] ?? 'Unknown error occurred';

        // Show message with appropriate color
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
          ),
        );

        // Navigate back to login screen only on success
        if (isSuccess) {
          context.go(AppRoutes.login);
        }
      } else {
        throw Exception('Auth controller not available');
      }
    } catch (e) {
      if (!mounted) return;

      // Show error message for unexpected errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send reset link: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        // Illustration (icon-based to avoid missing assets)
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
          child: SizedBox(
            height: 180,
            child: Image.asset('assets/images/forget.png', fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Use your email to reset your\npassword.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextFormField(
                title: 'Email Address',
                controller: _emailCtrl,
                textFormFieldType: TextFormFieldType.email,
                textInputType: TextInputType.emailAddress,
                isForm: true,
                isRequired: true,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your email address' : null,
              ),
              const SizedBox(height: 24),
              CustomAppButton(
                title: 'SUBMIT',
                onPressed: _isLoading ? () {} : _submit,
                height: 50,
                borderRadius: 12,
                loader: _isLoading,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
