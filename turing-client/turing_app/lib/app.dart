import 'package:flutter/material.dart';

import 'constants/app_colors.dart';
import 'features/sessions/session_list_screen.dart';
import 'features/settings/settings_screen.dart';
import 'logic/theme_logic.dart';
import 'networking/api_client.dart';
import 'networking/auth_storage.dart';
import 'networking/ws_client.dart';

class TuringApp extends StatefulWidget {
  const TuringApp({super.key, this.authStorage = const AuthStorage()});

  final ClientAuthStorage authStorage;

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

              final apiClient = TuringApiClient(
                baseUrl: config.backendUrl,
                apiKey: config.apiKey,
              );
              return SessionListScreen(
                apiClient: apiClient,
                authStorage: widget.authStorage,
                initialBackendUrl: config.backendUrl,
                initialApiKey: config.apiKey,
                onSettingsChanged: _reloadConfig,
                wsClientFactory: () => TuringWsClient(
                  baseUrl: config.backendUrl,
                  apiKey: config.apiKey,
                ),
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
      appBarTheme: AppBarTheme(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        foregroundColor: isDark ? AppColors.darkText : AppColors.lightText,
        elevation: isDark ? 0 : 0.5,
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _ClientConfig {
  const _ClientConfig({required this.backendUrl, required this.apiKey});

  final String backendUrl;
  final String apiKey;
}
