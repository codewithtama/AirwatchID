import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/models/air_quality.dart';
import 'data/repos/air_quality_repo.dart';
import 'providers/location_provider.dart';
import 'providers/air_quality_provider.dart';
import 'core/theme.dart';
import 'services/notification_service.dart';
import 'screens/home/home_screen.dart';
import 'screens/detail/detail_screen.dart';
import 'screens/forecast/forecast_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/compare/compare_screen.dart';
import 'screens/stats/stats_screen.dart';
import 'screens/settings/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await initializeDateFormatting('id', null);

  await Hive.initFlutter();
  Hive.registerAdapter(HourlyAirQualityAdapter());
  Hive.registerAdapter(CachedAirQualityDataAdapter());

  final repo = AirQualityRepo();
  await repo.init();

  await NotificationService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final provider = AirQualityProvider(repo);
            provider.loadSettings();
            return provider;
          },
        ),
      ],
      child: const AirWatchApp(),
    ),
  );
}

class AirWatchApp extends StatelessWidget {
  const AirWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AirWatch ID',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    DetailScreen(),
    ForecastScreen(),
    MapScreen(),
    CompareScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  static const _navItems = [
    _NavItemData(Icons.air_rounded, Icons.air_outlined, 'Beranda'),
    _NavItemData(Icons.analytics_rounded, Icons.analytics_outlined, 'Detail'),
    _NavItemData(Icons.wb_cloudy_rounded, Icons.wb_cloudy_outlined, 'Prakiraan'),
    _NavItemData(Icons.map_rounded, Icons.map_outlined, 'Peta'),
    _NavItemData(Icons.compare_arrows_rounded, Icons.compare_arrows_rounded, 'Bandingkan'),
    _NavItemData(Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Statistik'),
    _NavItemData(Icons.settings_rounded, Icons.settings_outlined, 'Pengaturan'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: _navItems.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                final selected = _currentIndex == i;
                return Expanded(
                  flex: selected ? 2 : 1,
                  child: _NavItem(
                    icon: selected ? item.activeIcon : item.icon,
                    label: item.label,
                    selected: selected,
                    onTap: () => setState(() => _currentIndex = i),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData activeIcon;
  final IconData icon;
  final String label;

  const _NavItemData(this.activeIcon, this.icon, this.label);
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 12 : 8,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.accent.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppTheme.accent : AppTheme.textTertiary,
              ),
              if (selected) ...[
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accent,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
