/// API 异常类
///
/// 用于表示 API 请求失败的错误
class ApiException implements Exception {
  /// 错误消息
  final String message;

  /// HTTP 状态码（可选）
  final int? statusCode;

  /// 错误详情（可选）
  final dynamic details;

  /// 构造函数
  ApiException(this.message, [this.statusCode, this.details]);

  @override
  String toString() {
    final buffer = StringBuffer('ApiException: $message');

    if (statusCode != null) {
      buffer.write(' (状态码: $statusCode)');
    }

    if (details != null) {
      buffer.write('\n详情: $details');
    }

    return buffer.toString();
  }
}
