import 'dart:async';

import 'package:flutter/material.dart';

import 'constants/app_colors.dart';
import 'features/settings/settings_screen.dart';
import 'logic/theme_logic.dart';
import 'networking/api_client.dart';
import 'networking/auth_storage.dart';
import 'networking/grpc_client.dart';
import 'networking/grpc_event_source.dart';
import 'networking/ws_client.dart';
import 'ui/shell/responsive_shell.dart';

typedef TuringApiFactory =
    TuringApi Function({required String baseUrl, required String apiKey});
typedef TuringEventSourceFactory =
    TuringEventSource Function({
      required String baseUrl,
      required String apiKey,
    });

class TuringApp extends StatefulWidget {
  const TuringApp({
    super.key,
    this.authStorage = const AuthStorage(),
    this.apiFactory = _createGrpcApi,
    this.eventSourceFactory = _createGrpcEventSource,
  });

  final ClientAuthStorage authStorage;
  final TuringApiFactory apiFactory;
  final TuringEventSourceFactory eventSourceFactory;

  @override
  State<TuringApp> createState() => _TuringAppState();
}

class _TuringAppState extends State<TuringApp> {
  late Future<_ClientConfig?> _configFuture;

  @override
  void initState() {
    super.initState();
    _configFuture = _loadConfig();
  }

  void _reloadConfig() {
    setState(() => _configFuture = _loadConfig());
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeLogic().mode,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Project Turing',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          themeMode: currentMode,
          home: FutureBuilder<_ClientConfig?>(
            future: _configFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final config = snapshot.data;
              if (config == null) {
                return SettingsScreen(
                  authStorage: widget.authStorage,
                  onSaved: _reloadConfig,
                );
              }

              return _ConfiguredTuringShell(
                config: config,
                authStorage: widget.authStorage,
                onSettingsChanged: _reloadConfig,
                apiFactory: widget.apiFactory,
                eventSourceFactory: widget.eventSourceFactory,
              );
            },
          ),
        );
      },
    );
  }

  Future<_ClientConfig?> _loadConfig() async {
    final backendUrl = await widget.authStorage.readBackendUrl();
    final apiKey = await widget.authStorage.readApiKey();
    if (backendUrl == null ||
        apiKey == null ||
        backendUrl.isEmpty ||
        apiKey.isEmpty) {
      return null;
    }
    return _ClientConfig(backendUrl: backendUrl, apiKey: apiKey);
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorSchemeSeed: AppColors.electricBlue,
      scaffoldBackgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      drawerTheme: DrawerThemeData(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        surfaceTintColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        foregroundColor: isDark ? AppColors.darkText : AppColors.lightText,
        elevation: isDark ? 0 : 0.5,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        selectedIconTheme: IconThemeData(
          color: isDark
              ? AppColors.menuSelectedDark
              : AppColors.menuSelectedLight,
        ),
        selectedLabelTextStyle: TextStyle(
          color: isDark
              ? AppColors.menuSelectedDark
              : AppColors.menuSelectedLight,
          fontWeight: FontWeight.bold,
        ),
        unselectedIconTheme: const IconThemeData(color: Colors.grey),
        indicatorColor: isDark ? AppColors.accentBlue : const Color(0xFFE3F2FD),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.electricBlue,
        foregroundColor: Colors.white,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.electricBlue;
          }
          return isDark ? Colors.grey : null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return isDark
                ? AppColors.accentBlue
                : AppColors.electricBlue.withValues(alpha: 0.5);
          }
          return isDark ? Colors.grey[800] : null;
        }),
      ),
    );
  }
}

class _ClientConfig {
  const _ClientConfig({required this.backendUrl, required this.apiKey});

  final String backendUrl;
  final String apiKey;
}

class _ConfiguredTuringShell extends StatefulWidget {
  const _ConfiguredTuringShell({
    required this.config,
    required this.authStorage,
    required this.onSettingsChanged,
    required this.apiFactory,
    required this.eventSourceFactory,
  });

  final _ClientConfig config;
  final ClientAuthStorage authStorage;
  final VoidCallback onSettingsChanged;
  final TuringApiFactory apiFactory;
  final TuringEventSourceFactory eventSourceFactory;

  @override
  State<_ConfiguredTuringShell> createState() => _ConfiguredTuringShellState();
}

class _ConfiguredTuringShellState extends State<_ConfiguredTuringShell> {
  late TuringApi _apiClient;

  @override
  void initState() {
    super.initState();
    _apiClient = _createApiClient();
  }

  @override
  void didUpdateWidget(_ConfiguredTuringShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.backendUrl != widget.config.backendUrl ||
        oldWidget.config.apiKey != widget.config.apiKey ||
        oldWidget.apiFactory != widget.apiFactory) {
      _closeApiClient(_apiClient);
      _apiClient = _createApiClient();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveShell(
      apiClient: _apiClient,
      authStorage: widget.authStorage,
      initialBackendUrl: widget.config.backendUrl,
      initialApiKey: widget.config.apiKey,
      onSettingsChanged: widget.onSettingsChanged,
      eventSourceFactory: () => widget.eventSourceFactory(
        baseUrl: widget.config.backendUrl,
        apiKey: widget.config.apiKey,
      ),
    );
  }

  @override
  void dispose() {
    _closeApiClient(_apiClient);
    super.dispose();
  }

  TuringApi _createApiClient() {
    return widget.apiFactory(
      baseUrl: widget.config.backendUrl,
      apiKey: widget.config.apiKey,
    );
  }

  void _closeApiClient(TuringApi apiClient) {
    if (apiClient is ClosableTuringApi) {
      unawaited(apiClient.close());
    }
  }
}

TuringApi _createGrpcApi({required String baseUrl, required String apiKey}) {
  return TuringGrpcApi(baseUrl: baseUrl, apiKey: apiKey);
}

TuringEventSource _createGrpcEventSource({
  required String baseUrl,
  required String apiKey,
}) {
  return TuringGrpcEventSource(baseUrl: baseUrl, apiKey: apiKey);
}
