import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/unsplash_photo.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/logger.dart';
import '../exceptions/network_exception.dart';
import '../exceptions/api_exception.dart';

/// Unsplash API 服务类
/// 提供与 Unsplash API 交互的方法
class UnsplashService {
  /// Unsplash API 基础 URL
  static const String _baseUrl = 'https://api.unsplash.com';

  /// 获取 Unsplash API Access Key
  String get _accessKey => AppConfig.unsplashAccessKey;

  /// HTTP 客户端实例
  final http.Client _client;

  /// 构造函数
  ///
  /// 参数:
  /// - [client] http.Client HTTP 客户端实例（可选，默认创建新实例）
  UnsplashService({http.Client? client}) : _client = client ?? http.Client();

  /// 获取随机照片
  ///
  /// 参数:
  /// - [width] int? 图片宽度（可选，例如 1920）
  /// - [height] int? 图片高度（可选，例如 1080）
  /// - [query] String? 搜索关键词（可选，例如 "nature"）
  /// - [orientation] String? 图片方向（可选，landscape/portrait/squarish）
  ///
  /// 返回:
  /// - Future\<UnsplashPhoto\> 返回随机照片对象
  ///
  /// 异常:
  /// - Exception 如果 API 请求失败或响应解析错误
  ///
  /// 示例:
  /// ```dart
  /// final service = UnsplashService();
  /// final photo = await service.getRandomPhoto(width: 1920, height: 1080);
  /// ```
  Future<UnsplashPhoto> getRandomPhoto({
    int? width,
    int? height,
    String? query,
    String? orientation,
  }) async {
    try {
      // 构建请求 URL
      final queryParams = <String, String>{
        if (width != null) 'w': width.toString(),
        if (height != null) 'h': height.toString(),
        if (query != null) 'query': query,
        if (orientation != null) 'orientation': orientation,
      };

      final uri = Uri.parse(
        '$_baseUrl/photos/random',
      ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

      // 发送 HTTP GET 请求
      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Client-ID $_accessKey',
          'Accept-Version': 'v1',
        },
      );

      // 检查响应状态
      if (response.statusCode == 200) {
        // 解析 JSON 数据
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        Logger.debug('成功获取随机照片', jsonData['id']);
        return UnsplashPhoto.fromJson(jsonData);
      } else {
        Logger.error('获取随机照片失败', '状态码: ${response.statusCode}');
        throw ApiException('获取随机照片失败', response.statusCode, response.body);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      Logger.error('获取随机照片异常', e);
      throw NetworkException('网络请求失败: $e');
    }
  }

  /// 搜索照片
  ///
  /// 参数:
  /// - [query] String 搜索关键词（必需）
  /// - [page] int 页码（可选，默认 1）
  /// - [perPage] int 每页数量（可选，默认 10，最大 30）
  /// - [orientation] String? 图片方向（可选，landscape/portrait/squarish）
  ///
  /// 返回:
  /// - Future\<List\<UnsplashPhoto\>\> 返回照片列表
  ///
  /// 异常:
  /// - Exception 如果 API 请求失败或响应解析错误
  ///
  /// 示例:
  /// ```dart
  /// final service = UnsplashService();
  /// final photos = await service.searchPhotos(
  ///   query: 'wallpaper',
  ///   perPage: 20,
  ///   orientation: 'landscape',
  /// );
  /// ```
  Future<List<UnsplashPhoto>> searchPhotos({
    required String query,
    int page = 1,
    int perPage = 10,
    String? orientation,
  }) async {
    try {
      // 构建请求参数
      final queryParams = {
        'query': query,
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (orientation != null) 'orientation': orientation,
      };

      final uri = Uri.parse(
        '$_baseUrl/search/photos',
      ).replace(queryParameters: queryParams);

      // 发送 HTTP GET 请求
      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Client-ID $_accessKey',
          'Accept-Version': 'v1',
        },
      );

      // 检查响应状态
      if (response.statusCode == 200) {
        // 解析 JSON 数据
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final results = jsonData['results'] as List<dynamic>;

        Logger.debug('搜索照片成功', '关键词: $query, 结果数: ${results.length}');
        return results
            .map((json) => UnsplashPhoto.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        Logger.error('搜索照片失败', '状态码: ${response.statusCode}');
        throw ApiException('搜索照片失败', response.statusCode, response.body);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      Logger.error('搜索照片异常', e);
      throw NetworkException('网络请求失败: $e');
    }
  }

  /// 获取指定 ID 的照片详情
  ///
  /// 参数:
  /// - [photoId] String 照片 ID（必需）
  ///
  /// 返回:
  /// - Future\<UnsplashPhoto\> 返回照片对象
  ///
  /// 异常:
  /// - Exception 如果 API 请求失败或响应解析错误
  ///
  /// 示例:
  /// ```dart
  /// final service = UnsplashService();
  /// final photo = await service.getPhotoById('abc123');
  /// ```
  Future<UnsplashPhoto> getPhotoById(String photoId) async {
    try {
      final uri = Uri.parse('$_baseUrl/photos/$photoId');

      // 发送 HTTP GET 请求
      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Client-ID $_accessKey',
          'Accept-Version': 'v1',
        },
      );

      // 检查响应状态
      if (response.statusCode == 200) {
        // 解析 JSON 数据
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        Logger.debug('成功获取照片详情', photoId);
        return UnsplashPhoto.fromJson(jsonData);
      } else {
        Logger.error('获取照片详情失败', '状态码: ${response.statusCode}');
        throw ApiException('获取照片详情失败', response.statusCode, response.body);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      Logger.error('获取照片详情异常', e);
      throw NetworkException('网络请求失败: $e');
    }
  }

  /// 获取照片列表
  ///
  /// 参数:
  /// - [page] int 页码（默认 1）
  /// - [perPage] int 每页数量（默认 30，最大 30）
  /// - [orderBy] String 排序方式（latest/oldest/popular，默认 latest）
  ///
  /// 返回:
  /// - Future\<List\<UnsplashPhoto\>\> 返回照片列表
  ///
  /// 异常:
  /// - Exception 如果 API 请求失败或响应解析错误
  ///
  /// 示例:
  /// ```dart
  /// final service = UnsplashService();
  /// final photos = await service.getPhotos(page: 1, perPage: 30);
  /// ```
  Future<List<UnsplashPhoto>> getPhotos({
    int page = 1,
    int perPage = 30,
    String orderBy = 'latest',
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        'order_by': orderBy,
      };

      final uri = Uri.parse(
        '$_baseUrl/photos',
      ).replace(queryParameters: queryParams);

      // 发送 HTTP GET 请求
      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Client-ID $_accessKey',
          'Accept-Version': 'v1',
        },
      );

      // 检查响应状态
      if (response.statusCode == 200) {
        // 解析 JSON 数据
        final jsonData = json.decode(response.body) as List<dynamic>;

        Logger.debug('获取照片列表成功', '页码: $page, 数量: ${jsonData.length}');
        return jsonData
            .map((json) => UnsplashPhoto.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        Logger.error('获取照片列表失败', '状态码: ${response.statusCode}');
        throw ApiException('获取照片列表失败', response.statusCode, response.body);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      Logger.error('获取照片列表异常', e);
      throw NetworkException('网络请求失败: $e');
    }
  }

  /// 关闭 HTTP 客户端
  /// 在不再需要服务时调用以释放资源
  void dispose() {
    _client.close();
  }
}
