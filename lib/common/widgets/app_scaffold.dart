import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healer_map_flutter/app/providers.dart';

class AppScaffold extends ConsumerWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showBack;

  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String appTitle = title ?? ref.watch(appTitleProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leadingWidth: 65,
        leading: Navigator.canPop(context) && showBack
            ? Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Container
                  (
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 22, color: Colors.black),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              )
            : null,
        title: Text(
          appTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ) ??
              const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        actions: actions,
      ),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
