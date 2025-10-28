import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';
import 'pages/home_page.dart';
import 'services/theme_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// 主题管理器
  late final ThemeManager _themeManager;

  @override
  void initState() {
    super.initState();
    _themeManager = ThemeManager();
    _themeManager.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeManager.removeListener(_onThemeChanged);
    super.dispose();
  }

  /// 主题变化回调
  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '壁纸工具',
      debugShowCheckedModeBanner: false,
      // 明暗主题配置
      theme: ThemeManager.getLightTheme(),
      darkTheme: ThemeManager.getDarkTheme(),
      themeMode: _themeManager.themeMode,
      // 初始路由为欢迎页
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomePage(themeManager: _themeManager),
        '/home': (context) => HomePage(themeManager: _themeManager),
      },
    );
  }
}
