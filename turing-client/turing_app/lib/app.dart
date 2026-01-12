import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'logic/theme_logic.dart';
import 'ui/shell/responsive_shell.dart';

class TuringApp extends StatelessWidget {
  const TuringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeLogic().mode,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Turing AI',
          debugShowCheckedModeBanner: false,

          // ☀️ LIGHT THEME
          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            
            // Global Colors
            colorSchemeSeed: AppColors.electricBlue,
            scaffoldBackgroundColor: AppColors.lightBackground,
            
            // Drawer (Sidebar)
            drawerTheme: const DrawerThemeData(
              backgroundColor: AppColors.lightSurface,
              surfaceTintColor: AppColors.lightSurface,
            ),
            
            // AppBar
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.lightSurface,
              foregroundColor: AppColors.lightText,
              elevation: 0.5,
            ),
            
            // Navigation Rail (Desktop)
            navigationRailTheme: const NavigationRailThemeData(
              backgroundColor: AppColors.lightSurface,
              // Uses Deep Navy
              selectedIconTheme: IconThemeData(color: AppColors.menuSelectedLight),
              selectedLabelTextStyle: TextStyle(color: AppColors.menuSelectedLight, fontWeight: FontWeight.bold),
              unselectedIconTheme: IconThemeData(color: Colors.grey),
              indicatorColor: Color(0xFFE3F2FD), 
            ),
            
            // Modern Switch
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return AppColors.electricBlue;
                return null;
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                 if (states.contains(WidgetState.selected)) return AppColors.electricBlue.withOpacity(0.5);
                return null;
              }),
            ),
          ),

          // 🌙 DARK THEME
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            
            // Global Colors
            colorSchemeSeed: AppColors.electricBlue,
            scaffoldBackgroundColor: AppColors.darkBackground,
            
            // Drawer (Sidebar)
            drawerTheme: const DrawerThemeData(
              backgroundColor: AppColors.darkSurface,
              surfaceTintColor: AppColors.darkSurface,
            ),
            
            // AppBar
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.darkSurface,
              foregroundColor: AppColors.darkText,
              elevation: 0,
            ),
            
            // Navigation Rail (Desktop)
            navigationRailTheme: const NavigationRailThemeData(
              backgroundColor: AppColors.darkSurface,
              // Uses Bright Cyan
              selectedIconTheme: IconThemeData(color: AppColors.menuSelectedDark),
              selectedLabelTextStyle: TextStyle(color: AppColors.menuSelectedDark, fontWeight: FontWeight.bold),
              unselectedIconTheme: IconThemeData(color: Colors.grey),
              indicatorColor: AppColors.accentBlue, 
            ),
            
            // FAB
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: AppColors.electricBlue,
              foregroundColor: Colors.white,
            ),
            
            // Modern Switch
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return AppColors.electricBlue;
                return Colors.grey; 
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                 if (states.contains(WidgetState.selected)) return AppColors.accentBlue;
                return Colors.grey[800];
              }),
            ),
          ),

          themeMode: currentMode,
          home: const ResponsiveShell(),
        );
      },
    );
  }
}