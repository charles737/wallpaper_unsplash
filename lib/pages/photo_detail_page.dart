import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../models/unsplash_photo.dart';

/// 图片详情页
///
/// 显示高清图片，支持手势缩放、旋转和分享功能
class PhotoDetailPage extends StatefulWidget {
  /// 照片对象
  final UnsplashPhoto photo;

  const PhotoDetailPage({super.key, required this.photo});

  @override
  State<PhotoDetailPage> createState() => _PhotoDetailPageState();
}

class _PhotoDetailPageState extends State<PhotoDetailPage> {
  /// PhotoView 控制器
  late PhotoViewController _photoViewController;

  /// 是否显示导航栏
  bool _showAppBar = true;

  /// 大图是否加载完成
  bool _isHighResLoaded = false;

  @override
  void initState() {
    super.initState();
    _photoViewController = PhotoViewController();
    _preloadHighResImage();
  }

  /// 预加载高清图，检查缓存状态
  ///
  /// 通过监听 ImageStream 来判断图片是否已缓存
  /// 如果已缓存会立即触发监听器
  ///
  /// 返回:
  /// - void
  void _preloadHighResImage() {
    final imageProvider = CachedNetworkImageProvider(_getPhotoUrl());
    final stream = imageProvider.resolve(const ImageConfiguration());

    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        // synchronousCall 为 true 表示图片已在缓存中，同步加载
        if (synchronousCall && mounted && !_isHighResLoaded) {
          setState(() {
            _isHighResLoaded = true;
          });
          debugPrint('高清图已在缓存中，跳过小图占位');
        }
        stream.removeListener(listener);
      },
      onError: (exception, stackTrace) {
        debugPrint('预加载检查失败: $exception');
        stream.removeListener(listener);
      },
    );

    stream.addListener(listener);
  }

  @override
  void dispose() {
    _photoViewController.dispose();
    super.dispose();
  }

  /// 切换导航栏显示/隐藏
  ///
  /// 返回:
  /// - void
  void _toggleAppBar() {
    setState(() {
      _showAppBar = !_showAppBar;
    });
  }

  /// 分享图片
  ///
  /// 分享图片链接和作者信息
  ///
  /// 返回:
  /// - Future\<void\>
  Future<void> _sharePhoto() async {
    try {
      final text =
          '${widget.photo.description ?? "精美壁纸"}\n'
          '作者: ${widget.photo.user.name}\n'
          '${_getPhotoUrl()}';

      await Share.share(text, subject: widget.photo.description ?? '分享壁纸');

      debugPrint('分享图片: ${widget.photo.id}');
    } catch (e) {
      debugPrint('分享失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('分享失败')));
      }
    }
  }

  /// 获取图片 URL (1440p)
  ///
  /// 返回:
  /// - String 图片 URL
  String _getPhotoUrl() {
    // 1440p = 2560x1440
    return '${widget.photo.urls.raw}&w=2560&h=1440&fit=max';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: _showAppBar
          ? AppBar(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                widget.photo.user.name,
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                // 分享按钮
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: _sharePhoto,
                  tooltip: '分享',
                ),
                // 更多选项按钮（预留）
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    debugPrint('更多选项');
                    // TODO: 显示更多选项（下载、设为壁纸等）
                  },
                  tooltip: '更多',
                ),
              ],
            )
          : null,
      body: GestureDetector(onTap: _toggleAppBar, child: _buildPhotoView()),
    );
  }

  /// 构建照片查看器
  ///
  /// 使用 Stack 实现渐进式加载：先显示小图占位，再加载高清大图
  /// 大图加载完成后替换小图
  /// 使用 PhotoView 支持缩放、旋转、拖动等手势
  ///
  /// 返回:
  /// - Widget 照片查看器组件
  Widget _buildPhotoView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 底层：小图占位符（仅在大图未加载完成时显示）
        if (!_isHighResLoaded)
          Hero(
            tag: widget.photo.id,
            child: CachedNetworkImage(
              imageUrl: '${widget.photo.urls.small}&w=208&h=208&fit=crop',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.black),
            ),
          ),

        // 上层：高清大图 PhotoView
        Hero(
          tag: _isHighResLoaded ? widget.photo.id : '${widget.photo.id}_high',
          child: PhotoView(
            imageProvider: CachedNetworkImageProvider(_getPhotoUrl()),
            controller: _photoViewController,
            backgroundDecoration: BoxDecoration(
              color: _isHighResLoaded ? Colors.black : Colors.transparent,
            ),
            // 最小缩放倍数
            minScale: PhotoViewComputedScale.contained,
            // 最大缩放倍数
            maxScale: PhotoViewComputedScale.covered * 3.0,
            // 初始缩放模式：适应屏幕
            initialScale: PhotoViewComputedScale.contained,
            // 启用旋转
            enableRotation: true,
            // 加载状态 - 优化显示
            loadingBuilder: (context, event) {
              // 计算加载进度百分比（整数）
              final progress = event == null
                  ? 0
                  : ((event.cumulativeBytesLoaded /
                                (event.expectedTotalBytes ?? 1)) *
                            100)
                        .toInt();

              // 检测加载完成
              if (event != null &&
                  event.expectedTotalBytes != null &&
                  event.cumulativeBytesLoaded >= event.expectedTotalBytes!) {
                // 延迟设置状态，避免在 build 过程中调用 setState
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_isHighResLoaded) {
                    setState(() {
                      _isHighResLoaded = true;
                    });
                    debugPrint('大图加载完成，已替换小图');
                  }
                });
              }

              return Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 转圈动画（粗线条）
                      CircularProgressIndicator(
                        value: event == null
                            ? null
                            : event.cumulativeBytesLoaded /
                                  (event.expectedTotalBytes ?? 1),
                        strokeWidth: 4.0,
                        color: Colors.white,
                      ),
                      // 百分比显示在中间
                      Text(
                        '$progress%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            // 错误状态
            errorBuilder: (context, error, stackTrace) {
              debugPrint('图片加载失败: $error');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white70,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '图片加载失败',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('返回'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
