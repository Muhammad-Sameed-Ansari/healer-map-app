import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:gap/gap.dart';
import 'package:healer_map_flutter/common/widgets/app_scaffold.dart';
import 'package:healer_map_flutter/common/widgets/custom_button.dart';
import 'package:healer_map_flutter/core/constants/app_constants.dart';
import 'package:healer_map_flutter/core/localization/app_localization.dart';
import 'package:healer_map_flutter/features/auth/presentation/controllers/auth_controller.dart';
import 'package:healer_map_flutter/app/router.dart';
import 'package:healer_map_flutter/core/utils/shared_pref_instance.dart';

import '../../../../common/widgets/custom_text_form_field.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  void logout(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);

    // Add loading state
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Stack(
              children: [
                // Blurred background with tap-to-dismiss
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      if (!isLoading) {
                        context.pop(); // Close the bottom sheet only if not loading
                      }
                    },
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: ColorConstants.primary.withOpacity(0.093),
                      ),
                    ),
                  ),
                ),
                // Bottom Sheet Content
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            height: 2,
                            color: ColorConstants.primary,
                            width: 35,
                          ),
                        ),
                        const Gap(10),
                        Text(
                          localizations.logout,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 20,
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Center(
                          child: Text(
                            localizations.logoutConfirm,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: CustomAppButton(
                                bgColor: ColorConstants.primary.withOpacity(0.2),
                                onPressed: isLoading ? () {} : () => Navigator.pop(context),
                                title: localizations.cancel,
                                titleTextStyle: TextStyle(
                                  color: ColorConstants.primary,
                                ),
                              ),
                            ),
                            const Gap(10),
                            Expanded(
                              child: CustomAppButton(
                                loader: isLoading,
                                onPressed: isLoading ? () {} : () async {
                                  setState(() => isLoading = true);

                                  try {
                                    await ref.read(authControllerProvider.notifier).logout();
                                    if (context.mounted) {
                                      Navigator.of(context).popUntil((r) => r.isFirst);
                                      context.go(AppRoutes.login);
                                    }
                                  } catch (e) {
                                    // Handle error if needed
                                    print('Logout error: $e');
                                  } finally {
                                    if (context.mounted) {
                                      setState(() => isLoading = false);
                                    }
                                  }
                                },
                                title: localizations.yesLogout,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void deleteAccount(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);

    // Add loading state
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Stack(
              children: [
                // Blurred background
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      if (!isLoading) {
                        context.pop(); // Close the bottom sheet
                      }
                    },
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: ColorConstants.primary.withOpacity(0.093),
                      ),
                    ),
                  ),
                ),
                // Bottom Sheet Content
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            height: 2,
                            color: ColorConstants.primary,
                            width: 35,
                          ),
                        ),
                        const Gap(10),
                        Text(
                          localizations.deleteAccountTitle,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 20,
                            color: ColorConstants.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Center(
                          child: Text(
                            localizations.deleteAccountConfirm,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(fontSize: 13),
                          ),
                        ),
                        Center(
                          child: Text(
                            localizations.deleteAccountWarning,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: CustomAppButton(
                                bgColor: ColorConstants.primary.withOpacity(0.1),
                                onPressed: isLoading ? () {} : () => Navigator.pop(context),
                                title: localizations.cancel,
                                titleTextStyle: TextStyle(
                                  color: ColorConstants.primary,
                                ),
                              ),
                            ),
                            const Gap(10),
                            Expanded(
                              child: CustomAppButton(
                                loader: isLoading,
                                onPressed: isLoading ? () {} : () async {
                                  setState(() => isLoading = true);

                                  try {
                                    final response = await ref.read(authControllerProvider.notifier).deleteAccount();

                                    // Close bottom sheet immediately
                                    Navigator.pop(context);

                                    if (!context.mounted) return;

                                    final isSuccess = response['status'] == true;
                                    final message = response['message'] ?? 'Unknown error occurred';

                                    _showMainScreenMessage(context, message, isSuccess);

                                    if (isSuccess) {
                                      // Clear all shared preferences
                                      await SharedPreference.instance.clear();

                                      // Navigate to login screen
                                      if (context.mounted) {
                                        Navigator.of(context).popUntil((r) => r.isFirst);
                                        context.go(AppRoutes.login);
                                      }
                                    }
                                  } catch (e) {
                                    // Close bottom sheet immediately
                                    Navigator.pop(context);

                                    if (!context.mounted) return;

                                    _showMainScreenMessage(context, 'Delete account failed: ${e.toString()}', false);
                                  } finally {
                                    if (context.mounted) {
                                      setState(() => isLoading = false);
                                    }
                                  }
                                },
                                title: localizations.yesDelete,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void changePassword(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);

    // Add loading state
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final TextEditingController oldPasswordController = TextEditingController();
        final TextEditingController newPasswordController = TextEditingController();
        final TextEditingController confirmNewPasswordController = TextEditingController();

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Stack(
              children: [
                // Blurred background
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: ColorConstants.primary.withOpacity(0.093),
                      ),
                    ),
                  ),
                ),
                // Bottom Sheet Content
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            height: 2,
                            color: ColorConstants.primary,
                            width: 35,
                          ),
                        ),
                        const Gap(10),
                        Text(
                          localizations.changePasswordTitle,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 19,
                            color: ColorConstants.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(15),
                        CustomTextFormField(
                          title: localizations.oldPassword,
                          controller: oldPasswordController,
                          textFormFieldType: TextFormFieldType.securedPassword,
                        ),
                        CustomTextFormField(
                          title: localizations.newPassword,
                          controller: newPasswordController,
                          textFormFieldType: TextFormFieldType.securedPassword,
                        ),
                        CustomTextFormField(
                          title: localizations.confirmNewPassword,
                          controller: confirmNewPasswordController,
                          textFormFieldType: TextFormFieldType.securedPassword,
                        ),
                        const Gap(20),
                        Row(
                          children: [
                            Expanded(
                              child: CustomAppButton(
                                bgColor: ColorConstants.primary.withOpacity(0.1),
                                onPressed: isLoading ? () {} : () => Navigator.pop(context),
                                title: localizations.cancel,
                                titleTextStyle: TextStyle(
                                  color: ColorConstants.primary,
                                ),
                              ),
                            ),
                            const Gap(10),
                            Expanded(
                              child: CustomAppButton(
                                loader: isLoading,
                                onPressed: isLoading ? () {} : () async {
                                  // Validation
                                  if (oldPasswordController.text.isEmpty ||
                                      newPasswordController.text.isEmpty ||
                                      confirmNewPasswordController.text.isEmpty) {
                                    Navigator.pop(context); // Close bottom sheet
                                    _showMainScreenMessage(context, 'Please fill all fields', false);
                                    return;
                                  }

                                  if (newPasswordController.text != confirmNewPasswordController.text) {
                                    Navigator.pop(context); // Close bottom sheet
                                    _showMainScreenMessage(context, 'New passwords do not match', false);
                                    return;
                                  }

                                  if (newPasswordController.text.length < 8) {
                                    Navigator.pop(context); // Close bottom sheet
                                    _showMainScreenMessage(context, 'New password must be at least 8 characters', false);
                                    return;
                                  }

                                  setState(() => isLoading = true);

                                  try {
                                    final response = await ref.read(authControllerProvider.notifier).changePassword(
                                      currentPassword: oldPasswordController.text,
                                      newPassword: newPasswordController.text,
                                    );

                                    // Close bottom sheet immediately
                                    Navigator.pop(context);

                                    if (!context.mounted) return;

                                    final isSuccess = response['status'] == true;
                                    final message = response['message']?.toString() ?? 'Unknown error occurred';

                                    _showMainScreenMessage(context, message, isSuccess);

                                  } catch (e) {
                                    // Close bottom sheet immediately
                                    Navigator.pop(context);

                                    if (!context.mounted) return;
                                    _showMainScreenMessage(context, 'Password change failed: ${e.toString()}', false);
                                  } finally {
                                    if (context.mounted) {
                                      setState(() => isLoading = false);
                                    }
                                  }
                                },
                                title: localizations.save,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper method to show messages in main screen context (after closing bottom sheet)
  void _showMainScreenMessage(BuildContext context, String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final localizations = AppLocalizations.of(context);

    return AppScaffold(
      title: localizations.profile,
      showBack: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // const SizedBox(height: 16),
            // Avatar
            Consumer(
              builder: (context, ref, _) {
                final u = ref.watch(authControllerProvider).value;
                final avatarStr = u?.avatarUrl ?? '';
                final hasAvatar = avatarStr.isNotEmpty;
                return CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(0xFFEDE7F6),
                  backgroundImage: hasAvatar ? NetworkImage(avatarStr) : null,
                  child: hasAvatar ? null : const Icon(Icons.person, size: 48, color: Colors.black54),
                );
              },
            ),
            const SizedBox(height: 16),
            // Username handle style
            Text(
              '@${(user?.name ?? 'guest').replaceAll(' ', '_')}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),

            // Action tiles
            _ProfileActionTile(
              imagePath: "assets/icons/profile_profile.png",
              title: localizations.editAccount,
              onTap: () {
                context.push('/edit-profile');
              },
            ),
            const SizedBox(height: 10),
            _ProfileActionTile(
              imagePath: "assets/icons/profile_favourite.png",
              title: localizations.yourFavorites,
              onTap: () {
                context.push(AppRoutes.favorite);
              },
            ),
            const SizedBox(height: 10),
            _ProfileActionTile(
              imagePath: "assets/icons/profile_lock.png",
              title: localizations.changePassword,
              onTap: () {
                changePassword(context, ref);
              },
            ),
            const SizedBox(height: 10),
            _ProfileActionTile(
              imagePath: "assets/icons/profile_language.png",
              title: localizations.changeLanguage,
              onTap: () {
                context.push('/change-language');
              },
            ),
            const SizedBox(height: 10),
            _ProfileActionTile(
              imagePath: "assets/icons/profile_policy.png",
              title: localizations.privacyPolicy,
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _ProfileActionTile(
              imagePath: "assets/icons/profile_delete_account.png",
              title: localizations.deleteAccount,
              onTap: () {
                deleteAccount(context, ref);
              },
            ),

            const Spacer(),

            // Logout button
            CustomAppButton(
              title: localizations.logout.toUpperCase(),
              height: 52,
              borderRadius: 12,
              width: double.infinity,
              onPressed: () async {
                logout(context, ref);
                // await ref.read(authControllerProvider.notifier).logout();
                // if (context.mounted) {
                //   Navigator.of(context).popUntil((r) => r.isFirst);
                // }
              },
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.imagePath,
    required this.title,
    required this.onTap,
  });

  final String imagePath;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: ColorConstants.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 30,
              width: 30,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: ColorConstants.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(imagePath, color: ColorConstants.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
