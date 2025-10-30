/// 网络异常类
///
/// 用于表示网络相关的错误
class NetworkException implements Exception {
  /// 错误消息
  final String message;

  /// HTTP 状态码（可选）
  final int? statusCode;

  /// 构造函数
  NetworkException(this.message, [this.statusCode]);

  @override
  String toString() {
    if (statusCode != null) {
      return 'NetworkException: $message (状态码: $statusCode)';
    }
    return 'NetworkException: $message';
  }
}
