import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healer_map_flutter/common/widgets/app_scaffold.dart';
import 'package:healer_map_flutter/core/localization/app_localization.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final WebUri _url = WebUri('https://healer-map.com/hm-map-view/');

  final ValueNotifier<double> _progress = ValueNotifier<double>(0);
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<String?> _errorText = ValueNotifier<String?>(null);

  InAppWebViewController? _controller;
  PullToRefreshController? _pullToRefreshController;

  @override
  void initState() {
    super.initState();
    _pullToRefreshController = PullToRefreshController(
      onRefresh: () async {
        _errorText.value = null;
        if (_controller != null) {
          if (await _controller!.canGoBack()) {
            // Keep current page; just reload
          }
          await _controller!.reload();
        }
      },
    );
  }

  @override
  void dispose() {
    _progress.dispose();
    _isLoading.dispose();
    _errorText.dispose();
    // Do not manually dispose PullToRefreshController; it's handled by InAppWebView.
    // Set to null to avoid any further usages during teardown.
    _pullToRefreshController = null;
    super.dispose();
  }

  void _startLoading() {
    _isLoading.value = true;
    _errorText.value = null;
  }

  void _stopLoading() {
    _isLoading.value = false;
    // Guard: controller may already be disposed by the platform view.
    try {
      _pullToRefreshController?.endRefreshing();
    } catch (_) {}
  }

  void _setError(String message) {
    _errorText.value = message;
    _isLoading.value = false;
    // Guard: controller may already be disposed by the platform view.
    try {
      _pullToRefreshController?.endRefreshing();
    } catch (_) {}
  }

  void _ensureTimeoutFallback() {
    // If loading takes longer than 20s without finishing, show an error.
    Future.delayed(const Duration(seconds: 20), () {
      if (mounted && _isLoading.value) {
        _setError('Timed out while loading the page. Please check your connection and try again.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AppScaffold(
      title: localizations.map,
      actions: [
        ValueListenableBuilder<double>(
          valueListenable: _progress,
          builder: (context, value, _) {
            if (value >= 1.0 || value == 0.0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: value,
                ),
              ),
            );
          },
        )
      ],
      body: Stack(
        children: [
          // Web content
          InAppWebView(
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: true,
              allowsInlineMediaPlayback: true,
              // Android: enable inspect via chrome://inspect
              isInspectable: true,
              // Android rendering & content policies
              useHybridComposition: true,
              mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              thirdPartyCookiesEnabled: true,
              geolocationEnabled: true,
            ),
            initialUrlRequest: URLRequest(url: _url),
            pullToRefreshController: _pullToRefreshController,
            onWebViewCreated: (controller) {
              _controller = controller;
            },
            onLoadStart: (controller, url) {
              _startLoading();
              _ensureTimeoutFallback();
            },
            onLoadStop: (controller, url) async {
              _stopLoading();
            },
            onProgressChanged: (controller, p) {
              _progress.value = p / 100.0;
            },
            onLoadError: (controller, url, code, message) {
              _setError('Failed to load page ($code): $message');
            },
            onLoadHttpError: (controller, url, statusCode, description) {
              _setError('HTTP $statusCode: $description');
            },
            onConsoleMessage: (controller, consoleMessage) {
              // Useful to see JS-side issues in run logs
              // ignore: avoid_print
              print('[WEBVIEW][CONSOLE] ${consoleMessage.messageLevel}: ${consoleMessage.message}');
            },
            onGeolocationPermissionsShowPrompt: (controller, origin) async {
              // Auto-grant geolocation if requested by the page
              return GeolocationPermissionShowPromptResponse(
                origin: origin,
                allow: true,
                retain: true,
              );
            },
            onPermissionRequest: (controller, request) async {
              // Auto-grant permissions (e.g., camera/mic) that the page might request.
              return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.GRANT,
              );
            },
          ),

          // Error view
          ValueListenableBuilder<String?>(
            valueListenable: _errorText,
            builder: (context, error, _) {
              if (error == null) return const SizedBox.shrink();
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off, size: 40, color: Theme.of(context).colorScheme.error),
                      const SizedBox(height: 12),
                      Text(
                        error,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () async {
                          _startLoading();
                          _controller?.reload();
                        },
                        child: Text(localizations.retry),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Loading overlay
          ValueListenableBuilder<bool>(
            valueListenable: _isLoading,
            builder: (context, loading, _) {
              if (!loading) return const SizedBox.shrink();
              return const ColoredBox(
                color: Color(0x0F000000),
                child: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ],
      ),
    );
  }
}
