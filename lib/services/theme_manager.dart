import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 主题管理器
///
/// 负责管理应用的明暗主题切换和主题色配置
class ThemeManager extends ChangeNotifier {
  /// 主题色 - 玫瑰棕色 #ba7264
  static const Color primaryColor = Color(0xFFBA7264);

  /// 当前主题模式
  ThemeMode _themeMode = ThemeMode.system;

  /// SharedPreferences 存储键
  static const String _themeModeKey = 'theme_mode';

  /// 构造函数
  ThemeManager() {
    _loadThemeMode();
  }

  /// 获取当前主题模式
  ThemeMode get themeMode => _themeMode;

  /// 加载保存的主题模式
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeModeKey);

      if (themeModeString != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeModeString,
          orElse: () => ThemeMode.system,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('加载主题模式失败: $e');
    }
  }

  /// 切换主题模式
  ///
  /// 参数:
  /// - [mode] ThemeMode 主题模式（light/dark/system）
  ///
  /// 返回:
  /// - Future<void>
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    // 保存到本地
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.toString());
      debugPrint('主题模式已保存: $mode');
    } catch (e) {
      debugPrint('保存主题模式失败: $e');
    }
  }

  /// 切换到下一个主题模式（循环切换）
  ///
  /// 顺序: light -> dark -> system -> light
  ///
  /// 返回:
  /// - Future<void>
  Future<void> toggleThemeMode() async {
    ThemeMode nextMode;
    switch (_themeMode) {
      case ThemeMode.light:
        nextMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        nextMode = ThemeMode.system;
        break;
      case ThemeMode.system:
        nextMode = ThemeMode.light;
        break;
    }
    await setThemeMode(nextMode);
  }

  /// 获取亮色主题配置
  ///
  /// 返回:
  /// - ThemeData 亮色主题数据
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      primaryColor: primaryColor,
      // AppBar 主题
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      // 卡片主题
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      // FilterChip 主题
      chipTheme: ChipThemeData(
        selectedColor: primaryColor,
        backgroundColor: Colors.grey.shade100,
        labelStyle: const TextStyle(fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      // 进度指示器颜色
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
    );
  }

  /// 获取暗色主题配置
  ///
  /// 返回:
  /// - ThemeData 暗色主题数据
  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      primaryColor: primaryColor,
      // AppBar 主题
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
      ),
      // 卡片主题
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      // FilterChip 主题
      chipTheme: ChipThemeData(
        selectedColor: primaryColor,
        backgroundColor: Colors.grey.shade800,
        labelStyle: const TextStyle(fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      // 进度指示器颜色
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
      // Scaffold 背景色
      scaffoldBackgroundColor: Colors.grey.shade900,
    );
  }
}
