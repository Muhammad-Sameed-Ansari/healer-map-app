import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healer_map_flutter/common/widgets/app_scaffold.dart';
import 'package:healer_map_flutter/common/widgets/custom_button.dart';
import 'package:healer_map_flutter/core/constants/app_constants.dart';
import 'package:healer_map_flutter/core/localization/app_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:healer_map_flutter/app/router.dart';

class ChangeLanguagePage extends StatefulWidget {
  const ChangeLanguagePage({super.key});

  @override
  State<ChangeLanguagePage> createState() => _ChangeLanguagePageState();
}

class _ChangeLanguagePageState extends State<ChangeLanguagePage> {
  late String _selectedLanguage;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'native': 'English', 'flag': '🇺🇸'},
    {'code': 'es', 'name': 'Spanish', 'native': 'Español', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'French', 'native': 'Français', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'German', 'native': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'it', 'name': 'Italian', 'native': 'Italiano', 'flag': '🇮🇹'},
    {'code': 'pt', 'name': 'Portuguese', 'native': 'Português', 'flag': '🇵🇹'},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with current locale from provider
    _selectedLanguage = localizationProvider.currentLanguageCode;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AppScaffold(
      title: localizations.changeLanguage,
      showBack: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.selectLanguage,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const Gap(8),
            Text(
              localizations.languageRestartNote,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const Gap(24),
            Expanded(
              child: ListView.builder(
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final language = _languages[index];
                  final isSelected = _selectedLanguage == language['code'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? ColorConstants.primary.withOpacity(0.1) : ColorConstants.surface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      border: Border.all(
                        color: isSelected ? ColorConstants.primary : Colors.grey.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 50,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            language['flag']!,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      title: Text(
                        language['native']!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? ColorConstants.primary : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        language['name']!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: ColorConstants.primary,
                              size: 24,
                            )
                          : Icon(
                              Icons.circle_outlined,
                              color: Colors.grey[400],
                              size: 24,
                            ),
                      onTap: () {
                        setState(() {
                          _selectedLanguage = language['code']!;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const Gap(16),
            CustomAppButton(
              title: localizations.saveLanguage,
              height: 52,
              borderRadius: 12,
              width: double.infinity,
              onPressed: _selectedLanguage.isNotEmpty ? () {
                // Change the app locale
                localizationProvider.setLocaleFromLanguageCode(_selectedLanguage);

                // Show confirmation message
                final rootCtx = rootNavigatorKey.currentContext;
                if (rootCtx != null) {
                  ScaffoldMessenger.of(rootCtx).showSnackBar(
                    SnackBar(
                      content: Text(
                        localizations.languageChanged(
                          _languages.firstWhere((lang) => lang['code'] == _selectedLanguage)['native']!,
                        ),
                      ),
                      backgroundColor: ColorConstants.primary,
                    ),
                  );
                }

                // Defer pop to next frame to avoid using deactivated context during rebuilds
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) context.pop();
                });
              } : () {},
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const Gap(8),
          ],
        ),
      ),
    );
  }
}
