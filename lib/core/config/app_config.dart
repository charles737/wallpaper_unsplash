import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 应用配置类
///
/// 管理环境变量和应用配置
class AppConfig {
  /// 私有构造函数，防止实例化
  AppConfig._();

  /// 初始化环境配置
  ///
  /// 必须在 main() 函数中最先调用
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }

  /// 获取 Unsplash API Access Key
  static String get unsplashAccessKey {
    final key = dotenv.env['UNSPLASH_ACCESS_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('UNSPLASH_ACCESS_KEY 未配置。请在 .env 文件中设置。');
    }
    return key;
  }

  /// 是否为调试模式
  static bool get isDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  /// 是否为生产模式
  static bool get isProduction => !isDebugMode;
}
