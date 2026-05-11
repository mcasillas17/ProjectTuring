import 'package:flutter/material.dart';
import '../../constants/app_colors.dart'; // Import constants
import '../../features/sessions/session_list_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../logic/theme_logic.dart';
import '../../networking/api_client.dart';
import '../../networking/auth_storage.dart';
import '../../networking/ws_client.dart';

class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({
    super.key,
    required this.apiClient,
    required this.wsClientFactory,
    this.authStorage,
    this.initialBackendUrl = 'http://localhost:3000',
    this.initialApiKey = '',
    this.onSettingsChanged,
  });

  final TuringApi apiClient;
  final TuringEventSource Function() wsClientFactory;
  final ClientAuthStorage? authStorage;
  final String initialBackendUrl;
  final String initialApiKey;
  final VoidCallback? onSettingsChanged;

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 800;

    // Grab the primary color for highlights
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      // --- MOBILE TOP BAR ---
      appBar: isDesktop ? null : AppBar(title: const Text("Project Turing")),

      // --- MOBILE DRAWER ---
      drawer: isDesktop
          ? null
          : Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Drawer Header
                  DrawerHeader(
                    decoration: BoxDecoration(color: primaryColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Turing OS",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Mobile Theme Toggle
                        Row(
                          children: [
                            const Text(
                              "Dark Mode",
                              style: TextStyle(color: Colors.white70),
                            ),
                            const Spacer(),
                            Switch(
                              value: ThemeLogic().isDark,
                              activeThumbColor: Colors.white,
                              activeTrackColor: Colors.white24,
                              onChanged: (val) => ThemeLogic().toggleTheme(val),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Menu Items
                  _buildMobileNavItem(Icons.chat_bubble, "Chat", 0),
                  _buildMobileNavItem(Icons.smart_toy, "Devices", 1),
                  _buildMobileNavItem(Icons.bar_chart, "Stats", 2),
                  _buildMobileNavItem(Icons.extension, "Integrations", 3),
                  _buildMobileNavItem(Icons.settings, "Settings", 4),
                ],
              ),
            ),

      // --- DESKTOP / MAIN BODY ---
      body: Row(
        children: [
          // Desktop Sidebar
          if (isDesktop)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Icon(Icons.memory, size: 40, color: primaryColor),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: IconButton(
                      icon: Icon(
                        ThemeLogic().isDark
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      tooltip: "Toggle Theme",
                      onPressed: () {
                        ThemeLogic().toggleTheme(!ThemeLogic().isDark);
                      },
                    ),
                  ),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  selectedIcon: Icon(Icons.chat_bubble),
                  label: Text('Chat'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.smart_toy_outlined),
                  selectedIcon: Icon(Icons.smart_toy),
                  label: Text('Devices'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bar_chart),
                  label: Text('Stats'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.extension),
                  label: Text('Integrations'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),

          if (isDesktop) const VerticalDivider(thickness: 1, width: 1),

          // Main Content
          Expanded(child: _buildSelectedScreen()),
        ],
      ),
    );
  }

  Widget _buildSelectedScreen() {
    return switch (_selectedIndex) {
      0 => SessionListScreen(
        apiClient: widget.apiClient,
        wsClientFactory: widget.wsClientFactory,
        embedded: true,
      ),
      1 => const Center(
        child: Text("IoT Devices Dashboard", style: TextStyle(fontSize: 20)),
      ),
      2 => const Center(
        child: Text("Stats & Usage", style: TextStyle(fontSize: 20)),
      ),
      3 => const Center(
        child: Text("Integrations Status", style: TextStyle(fontSize: 20)),
      ),
      4 =>
        widget.authStorage == null
            ? const Center(
                child: Text(
                  "Settings unavailable",
                  style: TextStyle(fontSize: 20),
                ),
              )
            : SettingsScreen(
                authStorage: widget.authStorage!,
                initialBackendUrl: widget.initialBackendUrl,
                initialApiKey: widget.initialApiKey,
                onSaved: widget.onSettingsChanged,
                embedded: true,
              ),
      _ => const SizedBox.shrink(),
    };
  }

  // FIXED: Using AppColors.menuSelectedLight/Dark
  Widget _buildMobileNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Pick the specific color based on the theme
    final selectedTextColor = isDark
        ? AppColors.menuSelectedDark
        : AppColors.menuSelectedLight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // Solid background to look like a button
        color: isSelected
            ? (isDark ? Colors.grey[800] : Colors.grey[200])
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(
          icon,
          // Color changes based on selection and theme
          color: isSelected ? selectedTextColor : Colors.grey,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? selectedTextColor : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onTap: () {
          _onItemTapped(index);
          Navigator.pop(context); // Close drawer
        },
      ),
    );
  }
}
