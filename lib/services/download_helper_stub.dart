import 'dart:typed_data';

/// 非 Web 平台的空实现（占位符）
class DownloadHelper {
  /// 在非 Web 平台此方法不应被调用
  static Future<bool> downloadFile(Uint8List bytes, String fileName) async {
    throw UnsupportedError('此方法仅在 Web 平台可用');
  }
}
