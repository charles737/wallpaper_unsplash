import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/unsplash_service.dart';
import '../app/theme/theme_manager.dart';
import '../app/routes/app_routes.dart';
import '../data/models/unsplash_photo.dart';

/// 欢迎页面
/// 显示随机 Unsplash 图片作为背景，提供确认按钮进入首页
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  /// Unsplash 服务实例
  final UnsplashService _unsplashService = UnsplashService();

  /// 当前照片对象
  UnsplashPhoto? _currentPhoto;

  /// 加载状态
  bool _isLoading = false;

  /// 错误信息
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 页面初始化时加载随机图片
    _loadRandomPhoto();
  }

  @override
  void dispose() {
    // 释放服务资源
    _unsplashService.dispose();
    super.dispose();
  }

  /// 加载随机照片
  ///
  /// 从 Unsplash 获取 1280x720 的随机照片
  Future<void> _loadRandomPhoto() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 获取 720p 分辨率的随机照片
      final photo = await _unsplashService.getRandomPhoto(
        width: 1280,
        height: 720,
        orientation: 'landscape',
      );

      setState(() {
        _currentPhoto = photo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载图片失败: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// 进入首页
  void _enterHomePage() {
    Get.offNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 背景图片
          _buildBackground(),

          // 渐变遮罩层
          _buildGradientOverlay(),

          // 内容层
          _buildContent(),
        ],
      ),
    );
  }

  /// 构建背景图片
  Widget _buildBackground() {
    if (_isLoading) {
      return Container(
        color: Colors.grey[900],
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        color: Colors.grey[900],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white70, size: 64),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentPhoto != null) {
      return Image.network(
        _currentPhoto!.urls.regular,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[900],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                color: Theme.of(context).primaryColor,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[900],
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.white70, size: 64),
            ),
          );
        },
      );
    }

    return Container(color: Colors.grey[900]);
  }

  /// 构建渐变遮罩层
  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.6),
          ],
        ),
      ),
    );
  }

  /// 构建内容层
  Widget _buildContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 主题切换按钮
            Align(
              alignment: Alignment.topRight,
              child: _buildThemeToggleButton(),
            ),

            const Spacer(),

            // 欢迎内容
            Column(
              children: [
                // 欢迎标题
                const Text(
                  '欢迎使用',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 8,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 应用名称
                const Text(
                  'Wallpaper Unsplash',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white70,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 4,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // 确认按钮和刷新按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildEnterButton(),
                    const SizedBox(width: 16),
                    _buildRefreshButton(),
                  ],
                ),
              ],
            ),

            const Spacer(),

            // 照片作者信息 - 底部居中
            if (_currentPhoto != null) _buildPhotoCredit(),
          ],
        ),
      ),
    );
  }

  /// 构建主题切换按钮
  Widget _buildThemeToggleButton() {
    final themeManager = Get.find<ThemeManager>();

    return Material(
      color: Colors.black.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: () => themeManager.toggleThemeMode(),
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Obx(
            () => Icon(
              themeManager.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : themeManager.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.brightness_auto,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建刷新按钮
  Widget _buildRefreshButton() {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: _isLoading ? null : _loadRandomPhoto,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : const Icon(Icons.refresh, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  /// 构建照片作者信息
  Widget _buildPhotoCredit() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.camera_alt, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Text(
            'Photo by ${_currentPhoto!.user.name}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// 构建确认按钮
  Widget _buildEnterButton() {
    return ElevatedButton(
      onPressed: _enterHomePage,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 8,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '开始使用',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward),
        ],
      ),
    );
  }
}
