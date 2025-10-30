import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../data/models/unsplash_photo.dart';
import '../app/theme/theme_manager.dart';
import 'downloaded_photos_page.dart';
import 'dart:typed_data';
// 条件导入：根据平台选择不同的下载实现
import '../services/download_helper_stub.dart'
    if (dart.library.html) '../services/download_helper_web.dart';

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

  /// 是否正在下载
  bool _isDownloading = false;

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

  /// 保存图片到相册
  ///
  /// 下载高清图片并保存到设备相册
  ///
  /// 返回:
  /// - Future\<void\>
  Future<void> _savePhoto() async {
    if (_isDownloading) {
      debugPrint('图片正在下载中，请稍候');
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      // 显示下载开始提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('开始下载图片...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // 下载图片
      final imageUrl = _getPhotoUrl();
      debugPrint('开始下载图片: $imageUrl');

      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode != 200) {
        throw Exception('下载失败: HTTP ${response.statusCode}');
      }

      // 文件名
      final fileName =
          'wallpaper_${widget.photo.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      bool success = false;

      // 根据平台选择不同的保存方式
      if (kIsWeb) {
        // Web 平台：直接下载文件
        debugPrint('Web 平台：触发文件下载');
        success = await DownloadHelper.downloadFile(
          Uint8List.fromList(response.bodyBytes),
          fileName,
        );
      } else {
        // 移动平台：保存到相册
        debugPrint('移动平台：保存到相册');
        final result = await SaverGallery.saveImage(
          response.bodyBytes,
          fileName: fileName,
          skipIfExists: false,
          androidRelativePath: 'Pictures/WallpaperUnsplash',
        );
        success = result.isSuccess;
        if (!success) {
          throw Exception('保存失败: ${result.errorMessage}');
        }
      }

      if (success) {
        // 保存下载记录
        await _saveDownloadRecord(fileName);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(kIsWeb ? '图片已下载' : '图片已保存到相册'),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        debugPrint('图片已保存: ${widget.photo.id}');
      } else {
        throw Exception('保存失败');
      }
    } catch (e) {
      debugPrint('保存图片失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  /// 保存下载记录到本地存储
  ///
  /// 参数:
  /// - [filePath] 保存的文件路径
  ///
  /// 返回:
  /// - Future\<void\>
  Future<void> _saveDownloadRecord(String? filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photosJson = prefs.getStringList('downloaded_photos') ?? [];

      // 检查是否已存在
      final exists = photosJson.any((json) {
        final item = DownloadedPhoto.fromJson(jsonDecode(json));
        return item.photo.id == widget.photo.id;
      });

      if (!exists) {
        // 添加新记录
        final downloadedPhoto = DownloadedPhoto(
          photo: widget.photo,
          downloadTime: DateTime.now(),
          savedPath: filePath,
        );

        photosJson.add(jsonEncode(downloadedPhoto.toJson()));
        await prefs.setStringList('downloaded_photos', photosJson);

        debugPrint('已保存下载记录: ${widget.photo.id}');
      } else {
        debugPrint('下载记录已存在: ${widget.photo.id}');
      }
    } catch (e) {
      debugPrint('保存下载记录失败: $e');
    }
  }

  /// 显示更多选项菜单
  ///
  /// 返回:
  /// - void
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('下载图片'),
                onTap: () {
                  Navigator.of(context).pop();
                  _savePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: const Text('已下载'),
                onTap: () {
                  Navigator.of(context).pop();
                  Get.to(() => const DownloadedPhotosPage());
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('取消'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
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
                // 主题切换按钮
                Obx(() {
                  final themeManager = Get.find<ThemeManager>();
                  return IconButton(
                    icon: Icon(
                      themeManager.themeMode == ThemeMode.dark
                          ? Icons.light_mode
                          : themeManager.themeMode == ThemeMode.light
                          ? Icons.dark_mode
                          : Icons.brightness_auto,
                      color: Colors.white,
                    ),
                    onPressed: () => themeManager.toggleThemeMode(),
                    tooltip: '切换主题',
                  );
                }),
                // 下载按钮
                _isDownloading
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.download, color: Colors.white),
                        onPressed: _savePhoto,
                        tooltip: '下载',
                      ),
                // 分享按钮
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: _sharePhoto,
                  tooltip: '分享',
                ),
                // 更多选项按钮
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: _showMoreOptions,
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
        // 第一层：纯黑色背景（始终存在，确保没有任何透明区域）
        Container(color: Colors.black),

        // 第二层：小图占位符（仅在大图未加载完成时显示）
        if (!_isHighResLoaded)
          CachedNetworkImage(
            // 使用与主页相同的 URL，确保命中缓存，立即显示
            imageUrl: '${widget.photo.urls.small}&w=208&h=288&fit=crop',
            fit: BoxFit.contain, // 保持宽高比，居中显示
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
                strokeWidth: 2,
              ),
            ),
            errorWidget: (context, url, error) =>
                Container(color: Colors.black),
          ),

        // 第三层：高清大图 PhotoView
        Hero(
          tag: widget.photo.id,
          child: PhotoView(
            imageProvider: CachedNetworkImageProvider(_getPhotoUrl()),
            controller: _photoViewController,
            backgroundDecoration: const BoxDecoration(
              // 始终透明，让底层的黑色背景显示出来
              color: Colors.transparent,
            ),
            // 最小缩放倍数
            minScale: PhotoViewComputedScale.contained,
            // 最大缩放倍数
            maxScale: PhotoViewComputedScale.covered * 3.0,
            // 初始缩放模式：适应屏幕
            initialScale: PhotoViewComputedScale.contained,
            // 启用旋转
            enableRotation: true,
            // 加载状态 - 显示加载进度
            loadingBuilder: (context, event) {
              // 计算加载进度（0.0 - 1.0）
              final loadProgress = event == null
                  ? 0.0
                  : event.cumulativeBytesLoaded /
                        (event.expectedTotalBytes ?? 1);

              // 计算加载进度百分比（整数）
              final progressPercent = (loadProgress * 100).toInt();

              // 检测加载完成
              if (event != null &&
                  event.expectedTotalBytes != null &&
                  event.cumulativeBytesLoaded >= event.expectedTotalBytes!) {
                // 加载完成后隐藏小图
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_isHighResLoaded) {
                    setState(() {
                      _isHighResLoaded = true;
                    });
                    debugPrint('高清图加载完成，隐藏小图占位');
                  }
                });
              }

              // 显示加载进度指示器
              return Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 转圈动画（粗线条）
                      CircularProgressIndicator(
                        value: event == null ? null : loadProgress,
                        strokeWidth: 4.0,
                        color: Theme.of(context).primaryColor,
                      ),
                      // 百分比显示在中间
                      Text(
                        '$progressPercent%',
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
