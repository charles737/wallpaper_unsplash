import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'logger.dart';

/// 全局错误处理器
///
/// 负责捕获和处理应用中的所有错误
class ErrorHandler {
  /// 私有构造函数，防止实例化
  ErrorHandler._();

  /// 初始化全局错误处理
  ///
  /// 必须在 main() 函数中调用
  static void init() {
    // 捕获 Flutter 框架错误
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);

      if (kDebugMode) {
        // 开发环境：打印详细错误信息
        FlutterError.dumpErrorToConsole(details);
      } else {
        // 生产环境：记录错误并上报
        Logger.error('Flutter 框架错误', details.exception, details.stack);
        // TODO: 上报到崩溃分析服务
        // _reportError(details.exception, details.stack);
      }
    };
  }

  /// 处理异步错误
  ///
  /// 参数:
  /// - [error] Object 错误对象
  /// - [stackTrace] StackTrace 堆栈跟踪
  static void handleAsyncError(Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      Logger.error('异步错误', error, stackTrace);
    } else {
      Logger.error('异步错误', error);
      // TODO: 上报到崩溃分析服务
      // _reportError(error, stackTrace);
    }
  }

  /// 上报错误到服务器（预留接口）
  ///
  /// 参数:
  /// - [error] Object 错误对象
  /// - [stackTrace] StackTrace 堆栈跟踪
  // static Future<void> _reportError(
  //   Object error,
  //   StackTrace? stackTrace,
  // ) async {
  //   // 实现错误上报逻辑
  //   // 例如: Firebase Crashlytics, Sentry 等
  //   // try {
  //   //   await FirebaseCrashlytics.instance.recordError(error, stackTrace);
  //   // } catch (e) {
  //   //   Logger.error('错误上报失败', e);
  //   // }
  // }
}
