import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:healer_map_flutter/common/widgets/app_scaffold.dart';
import 'package:healer_map_flutter/common/widgets/custom_button.dart';
import 'package:healer_map_flutter/common/widgets/custom_text_form_field.dart';
import 'package:healer_map_flutter/core/constants/app_constants.dart';
import 'package:healer_map_flutter/core/localization/app_localization.dart';
import 'package:healer_map_flutter/features/auth/presentation/controllers/auth_controller.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _displayNameController;

  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).value;

    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _displayNameController = TextEditingController(text: user?.displayName ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _showMainScreenMessage(BuildContext context, String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Image selection methods
  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select Image Source',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstants.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxHeight: 512,
        maxWidth: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showMainScreenMessage(context, 'Failed to pick image: ${e.toString()}', false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ref.read(authControllerProvider.notifier).updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        displayName: _displayNameController.text.trim(),
        image: _selectedImage, // Send the selected image file
      );

      if (!context.mounted) return;

      final isSuccess = response['status'] == true;
      final message = response['message']?.toString() ?? 'Unknown error occurred';

      _showMainScreenMessage(context, message, isSuccess);

      if (isSuccess) {
        // Invalidate auth controller to refresh Profile/Home screens
        ref.invalidate(authControllerProvider);
        // Go back to profile page shortly after
        Future.delayed(const Duration(milliseconds: 200), () {
          if (context.mounted) {
            context.pop();
          }
        });
      }
    } catch (e) {
      if (!context.mounted) return;
      _showMainScreenMessage(context, 'Failed to update profile: ${e.toString()}', false);
    } finally {
      if (context.mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AppScaffold(
      title: localizations.editAccount,
      showBack: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Avatar
                Center(
                  child: Stack(
                    children: [
                      Consumer(
                        builder: (context, ref, _) {
                          final user = ref.watch(authControllerProvider).value;
                          final remote = user?.avatarUrl ?? '';
                          final hasRemote = remote.isNotEmpty;
                          return CircleAvatar(
                            radius: 50,
                            backgroundColor: ColorConstants.surface,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (hasRemote ? NetworkImage(remote) : null) as ImageProvider<Object>?,
                            child: _selectedImage == null && !hasRemote
                                ? const Icon(Icons.person, size: 50, color: Colors.black54)
                                : null,
                          );
                        },
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showImageSourceDialog,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: ColorConstants.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(32),

                // Form Fields
                CustomTextFormField(
                  isForm: true,
                  title: localizations.firstName,
                  controller: _firstNameController,
                  textFormFieldType: TextFormFieldType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
                const Gap(16),

                CustomTextFormField(
                  isForm: true,
                  title: localizations.lastName,
                  controller: _lastNameController,
                  textFormFieldType: TextFormFieldType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
                const Gap(16),

                CustomTextFormField(
                  isForm: true,
                  title: localizations.email,
                  controller: _emailController,
                  textFormFieldType: TextFormFieldType.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const Gap(16),

                CustomTextFormField(
                  isForm: true,
                  title: localizations.displayName,
                  controller: _displayNameController,
                  textFormFieldType: TextFormFieldType.text,
                  hintText: 'How you want to be displayed',
                ),
                const Gap(16),
                // Save Button
                CustomAppButton(
                  title: localizations.save,
                  height: 52,
                  width: double.infinity,
                  borderRadius: 12,
                  onPressed: _isLoading ? () {} : _updateProfile,
                  loader: _isLoading,
                  titleTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),


                const Gap(32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
