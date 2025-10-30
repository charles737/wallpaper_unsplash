/// API 相关常量
///
/// 定义 API 基础 URL 和其他常量
class ApiConstants {
  /// 私有构造函数，防止实例化
  ApiConstants._();

  /// Unsplash API 基础 URL
  static const String unsplashBaseUrl = 'https://api.unsplash.com';

  /// API 版本
  static const String apiVersion = 'v1';

  /// 连接超时时间（秒）
  static const int connectTimeout = 30;

  /// 接收超时时间（秒）
  static const int receiveTimeout = 30;
}
