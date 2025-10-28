// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint;

/// Web 平台专用的文件下载帮助类
class DownloadHelper {
  /// 在 Web 平台下载文件
  ///
  /// 参数:
  /// - [bytes] 文件字节数据
  /// - [fileName] 文件名
  ///
  /// 返回:
  /// - Future\<bool\> 是否下载成功
  static Future<bool> downloadFile(Uint8List bytes, String fileName) async {
    try {
      // 创建 Blob 对象
      final blob = html.Blob([bytes]);

      // 创建下载链接
      final url = html.Url.createObjectUrlFromBlob(blob);

      // 创建隐藏的 <a> 标签
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..style.display = 'none';

      // 添加到 DOM
      html.document.body?.children.add(anchor);

      // 触发下载
      anchor.click();

      // 清理
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      return true;
    } catch (e) {
      debugPrint('Web 下载失败: $e');
      return false;
    }
  }
}
