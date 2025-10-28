import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/unsplash_photo.dart';
import '../services/theme_manager.dart';
import 'photo_detail_page.dart';

/// 已下载图片页面
///
/// 显示所有已下载的图片，支持查看和删除
class DownloadedPhotosPage extends StatefulWidget {
  /// 主题管理器
  final ThemeManager themeManager;

  const DownloadedPhotosPage({super.key, required this.themeManager});

  @override
  State<DownloadedPhotosPage> createState() => _DownloadedPhotosPageState();
}

class _DownloadedPhotosPageState extends State<DownloadedPhotosPage> {
  /// 已下载的图片列表
  List<DownloadedPhoto> _downloadedPhotos = [];

  /// 是否正在加载
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadedPhotos();
  }

  /// 从本地存储加载已下载的图片列表
  ///
  /// 返回:
  /// - Future\<void\>
  Future<void> _loadDownloadedPhotos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photosJson = prefs.getStringList('downloaded_photos') ?? [];

      final photos = photosJson
          .map((json) => DownloadedPhoto.fromJson(jsonDecode(json)))
          .toList();

      // 按下载时间倒序排序（最新的在前面）
      photos.sort((a, b) => b.downloadTime.compareTo(a.downloadTime));

      setState(() {
        _downloadedPhotos = photos;
        _isLoading = false;
      });

      debugPrint('已加载 ${photos.length} 张下载的图片');
    } catch (e) {
      debugPrint('加载下载列表失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 删除已下载的图片记录
  ///
  /// 参数:
  /// - [photo] 要删除的图片对象
  ///
  /// 返回:
  /// - Future\<void\>
  Future<void> _deletePhoto(DownloadedPhoto photo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要从下载列表中删除这张图片吗？\n\n注意：图片仍会保留在系统相册中。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final photosJson = prefs.getStringList('downloaded_photos') ?? [];

      // 移除指定的图片
      photosJson.removeWhere((json) {
        final item = DownloadedPhoto.fromJson(jsonDecode(json));
        return item.photo.id == photo.photo.id;
      });

      await prefs.setStringList('downloaded_photos', photosJson);

      setState(() {
        _downloadedPhotos.removeWhere((p) => p.photo.id == photo.photo.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已从下载列表中删除')));
      }

      debugPrint('已删除图片记录: ${photo.photo.id}');
    } catch (e) {
      debugPrint('删除图片记录失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('删除失败')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('已下载'),
        actions: [
          if (_downloadedPhotos.isNotEmpty)
            TextButton.icon(
              onPressed: _clearAll,
              icon: const Icon(Icons.delete_outline),
              label: const Text('清空'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// 构建页面主体
  ///
  /// 返回:
  /// - Widget 页面主体组件
  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
      );
    }

    if (_downloadedPhotos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '暂无下载记录',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '下载的图片会显示在这里',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: _downloadedPhotos.length,
      itemBuilder: (context, index) {
        final downloadedPhoto = _downloadedPhotos[index];
        return _buildPhotoCard(downloadedPhoto);
      },
    );
  }

  /// 构建图片卡片
  ///
  /// 参数:
  /// - [downloadedPhoto] 已下载的图片对象
  ///
  /// 返回:
  /// - Widget 图片卡片组件
  Widget _buildPhotoCard(DownloadedPhoto downloadedPhoto) {
    final photo = downloadedPhoto.photo;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // 点击查看图片详情
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PhotoDetailPage(
                photo: photo,
                themeManager: widget.themeManager,
              ),
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 图片缩略图
            Image.network(
              photo.urls.small,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 48),
                );
              },
            ),

            // 底部信息栏
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      photo.user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDownloadTime(downloadedPhoto.downloadTime),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 删除按钮
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () => _deletePhoto(downloadedPhoto),
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 格式化下载时间
  ///
  /// 参数:
  /// - [dateTime] 下载时间
  ///
  /// 返回:
  /// - String 格式化后的时间字符串
  String _formatDownloadTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} 分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} 小时前';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} 天前';
    } else {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
  }

  /// 清空所有下载记录
  ///
  /// 返回:
  /// - Future\<void\>
  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有下载记录吗？\n\n注意：图片仍会保留在系统相册中。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清空'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('downloaded_photos');

      setState(() {
        _downloadedPhotos.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已清空所有下载记录')));
      }

      debugPrint('已清空所有下载记录');
    } catch (e) {
      debugPrint('清空下载记录失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('清空失败')));
      }
    }
  }
}

/// 已下载图片数据模型
class DownloadedPhoto {
  /// 图片对象
  final UnsplashPhoto photo;

  /// 下载时间
  final DateTime downloadTime;

  /// 保存路径（可选）
  final String? savedPath;

  DownloadedPhoto({
    required this.photo,
    required this.downloadTime,
    this.savedPath,
  });

  /// 从 JSON 创建对象
  factory DownloadedPhoto.fromJson(Map<String, dynamic> json) {
    return DownloadedPhoto(
      photo: UnsplashPhoto.fromJson(json['photo']),
      downloadTime: DateTime.parse(json['downloadTime']),
      savedPath: json['savedPath'],
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'photo': photo.toJson(),
      'downloadTime': downloadTime.toIso8601String(),
      'savedPath': savedPath,
    };
  }
}
