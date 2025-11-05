import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healer_map_flutter/app/router.dart';
import 'package:healer_map_flutter/common/widgets/app_scaffold.dart';
import 'package:healer_map_flutter/core/network/dio_client.dart';
import 'package:healer_map_flutter/features/auth/presentation/controllers/auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:healer_map_flutter/common/widgets/custom_button.dart';
import 'package:healer_map_flutter/common/widgets/custom_text_form_field.dart';
import 'package:healer_map_flutter/core/utils/shared_pref_instance.dart';
import 'package:healer_map_flutter/core/constants/app_constants.dart';
import 'package:healer_map_flutter/core/localization/app_localization.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: '');
  final _passwordCtrl = TextEditingController(text: '');
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Load remembered email if any
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final remembered = await SharedPreference.instance.getString('remembered_email');
      final rememberFlag = await SharedPreference.instance.getString('remember_me');
      if (!mounted) return;
      setState(() {
        _rememberMe = rememberFlag == 'true';
        if (remembered != null && remembered.isNotEmpty) {
          _emailCtrl.text = remembered;
        }
      });
    });
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final localizations = AppLocalizations.of(context);

    // Read the current auth state before login
    final authNotifier = ref.read(authControllerProvider.notifier);

    await authNotifier.login(
      _passwordCtrl.text,
      _emailCtrl.text.trim(),
    );

    // Check if widget is still mounted after login
    if (!mounted) return;

    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      final err = state.error;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } else if (state.hasValue && state.value != null && mounted) {
      // Save user data to SharedPreferences
      final user = state.value!;
       SharedPreference.instance.setString('user_id', user.id);
       SharedPreference.instance.setString('username', user.username);
       SharedPreference.instance.setString('email', user.email);
       SharedPreference.instance.setString('first_name', user.firstName);
       SharedPreference.instance.setString('last_name', user.lastName);
       SharedPreference.instance.setString('display_name', user.displayName);
       SharedPreference.instance.setString('avatar_url', user.avatarUrl);
       SharedPreference.instance.setString('is_logged_in', 'true');

      // Save token if available

      if (user.token != null && user.token!.isNotEmpty) {
        await SharedPreference.instance.setString('auth_token', user.token!);
        DioClient.instance.setToken(user.token!);
      }
      if (user.tokenExpires != null) {
        await SharedPreference.instance.setString('token_expires', user.tokenExpires.toString());
      }

      // Handle Remember Me persistence
      if (_rememberMe) {
        await SharedPreference.instance.setString('remember_me', 'true');
        await SharedPreference.instance.setString('remembered_email', _emailCtrl.text.trim());
      } else {
        await SharedPreference.instance.remove('remember_me');
        await SharedPreference.instance.remove('remembered_email');
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.loginSuccessful),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Navigate to home screen on successful login
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final localizations = AppLocalizations.of(context);

    return AppScaffold(
      title: localizations.login,
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
                  child: Image.asset('assets/images/login.png', fit: BoxFit.contain),
                ),
              ),
              // Username or Email
              CustomTextFormField(
                title: localizations.email,
                controller: _emailCtrl,
                textFormFieldType: TextFormFieldType.text,
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
                validator: (v) => (v == null || v.length < 6) ? localizations.passwordRequired : null,
              ),
              const SizedBox(height: 8),
              // Remember me + Forgot password
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v ?? false),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  Text('Remember Me', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ColorConstants.secondary2)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.forgotPassword),
                    child: Text(localizations.forgotPassword, style: TextStyle(color: ColorConstants.primary)),
                  )
                ],
              ),
              const SizedBox(height: 8),
              // Login button
              CustomAppButton(
                title: localizations.login.toUpperCase(),
                loader: authState.isLoading,
                onPressed: _onLogin,
                height: 50,
                borderRadius: 12,
              ),
              const SizedBox(height: 16),
              // Bottom sign-up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${localizations.dontHaveAccount} ", style: Theme.of(context).textTheme.bodyMedium),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.signup),
                    child: Text(localizations.signup, style: TextStyle(color: ColorConstants.primary, fontWeight: FontWeight.w600)),
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
