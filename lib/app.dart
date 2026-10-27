import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio/azkar_player.dart';
import 'models/content.dart';
import 'screens/azkar_tab.dart';
import 'screens/duas_tab.dart';
import 'screens/favorites_tab.dart';
import 'screens/home_tab.dart';
import 'screens/settings_tab.dart';
import 'state/app_state.dart';
import 'theme.dart';

class AzkarApp extends StatelessWidget {
  const AzkarApp({super.key, required this.state, required this.content});

  final AppState state;
  final Content content;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: state),
        ChangeNotifierProvider<AzkarPlayer>(create: (_) => AzkarPlayer()),
        Provider<Content>.value(value: content),
      ],
      // Rebuilt whenever the chosen palette changes. The key makes Flutter
      // rebuild the whole tree, so every screen picks up the new colours.
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          AppColors.select(appState.themeIndex);
          return MaterialApp(
            key: ValueKey(appState.themeIndex),
            title: 'እስላማዊ አዝካር',
            debugShowCheckedModeBanner: false,
            theme: buildTheme(),
            home: const RootShell(),
          );
        },
      ),
    );
  }
}

/// Bottom navigation with five tabs. Tabs are kept alive with IndexedStack.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  // Remembered outside the State: picking a colour theme rebuilds the whole
  // app (see the key in AzkarApp), and Settings should stay open afterwards.
  static int _lastIndex = 0;

  int _index = _lastIndex;

  void _selectTab(int index) {
    _lastIndex = index;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final favCount = context.watch<AppState>().favorites.length;

    // Back on a tab other than home goes to home first, instead of closing the app.
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _selectTab(0);
      },
      child: Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeTab(onOpenTab: _selectTab),
          const AzkarTab(),
          const DuasTab(),
          const FavoritesTab(),
          const SettingsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _selectTab,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'መነሻ',
          ),
          const NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny),
            label: 'አዝካር',
          ),
          const NavigationDestination(
            icon: Icon(Icons.front_hand_outlined),
            selectedIcon: Icon(Icons.front_hand),
            label: 'ጸሎት',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: favCount > 0,
              label: Text('$favCount'),
              child: const Icon(Icons.favorite_border),
            ),
            selectedIcon: Badge(
              isLabelVisible: favCount > 0,
              label: Text('$favCount'),
              child: const Icon(Icons.favorite),
            ),
            label: 'ተወዳጅ',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'ቅንብር',
          ),
        ],
      ),
      ),
    );
  }
}
