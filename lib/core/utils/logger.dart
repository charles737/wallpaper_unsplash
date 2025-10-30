import 'package:flutter/foundation.dart';

/// 日志工具类
///
/// 提供统一的日志管理，区分不同级别的日志输出
class Logger {
  /// 私有构造函数，防止实例化
  Logger._();

  /// 是否启用日志（仅在调试模式下启用）
  static bool get _isEnabled => kDebugMode;

  /// Debug 级别日志
  ///
  /// 用于输出调试信息
  ///
  /// 参数:
  /// - [message] String 日志消息
  /// - [data] dynamic 附加数据（可选）
  static void debug(String message, [dynamic data]) {
    if (_isEnabled) {
      final output = data != null ? '$message\n数据: $data' : message;
      debugPrint('🐛 [DEBUG] $output');
    }
  }

  /// Info 级别日志
  ///
  /// 用于输出一般信息
  ///
  /// 参数:
  /// - [message] String 日志消息
  /// - [data] dynamic 附加数据（可选）
  static void info(String message, [dynamic data]) {
    if (_isEnabled) {
      final output = data != null ? '$message\n数据: $data' : message;
      debugPrint('ℹ️  [INFO] $output');
    }
  }

  /// Warning 级别日志
  ///
  /// 用于输出警告信息
  ///
  /// 参数:
  /// - [message] String 日志消息
  /// - [data] dynamic 附加数据（可选）
  static void warning(String message, [dynamic data]) {
    final output = data != null ? '$message\n数据: $data' : message;
    debugPrint('⚠️  [WARNING] $output');
  }

  /// Error 级别日志
  ///
  /// 用于输出错误信息
  ///
  /// 参数:
  /// - [message] String 日志消息
  /// - [error] dynamic 错误对象（可选）
  /// - [stackTrace] StackTrace 堆栈跟踪（可选）
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint('❌ [ERROR] $message');
    if (error != null) {
      debugPrint('错误详情: $error');
    }
    if (stackTrace != null && _isEnabled) {
      debugPrint('堆栈跟踪:\n$stackTrace');
    }

    // TODO: 生产环境可在此处上报错误到服务器
    // if (!kDebugMode) {
    //   _reportErrorToServer(message, error, stackTrace);
    // }
  }

  /// 上报错误到服务器（预留接口）
  ///
  /// 参数:
  /// - [message] String 错误消息
  /// - [error] dynamic 错误对象
  /// - [stackTrace] StackTrace 堆栈跟踪
  // static Future<void> _reportErrorToServer(
  //   String message,
  //   dynamic error,
  //   StackTrace? stackTrace,
  // ) async {
  //   // 实现错误上报逻辑
  //   // 例如: Firebase Crashlytics, Sentry 等
  // }
}
