import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:cached_network_image/cached_network_image.dart';
import '../services/unsplash_service.dart';
import '../models/unsplash_photo.dart';
import '../models/photo_category.dart';
import 'photo_detail_page.dart';

/// 首页 - 图片墙界面
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Unsplash 服务实例
  final UnsplashService _unsplashService = UnsplashService();

  /// 滚动控制器
  final ScrollController _scrollController = ScrollController();

  /// 照片列表
  final List<UnsplashPhoto> _photos = [];

  /// 当前页码
  int _currentPage = 1;

  /// 是否正在加载
  bool _isLoading = false;

  /// 是否还有更多数据
  bool _hasMore = true;

  /// 当前选中的分类
  PhotoCategory _selectedCategory = PhotoCategory.categories[0];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _unsplashService.dispose();
    super.dispose();
  }

  /// 滚动监听
  ///
  /// 当滚动到底部时自动加载更多照片
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadPhotos();
      }
    }
  }

  /// 加载照片
  ///
  /// 参数:
  /// - [refresh] bool 是否刷新（清空现有数据，默认 false）
  ///
  /// 返回:
  /// - Future\<void\>
  Future<void> _loadPhotos({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final List<UnsplashPhoto> newPhotos;

      if (_selectedCategory.id == 'all') {
        // 加载全部照片
        newPhotos = await _unsplashService.getPhotos(
          page: refresh ? 1 : _currentPage,
          perPage: 30,
        );
      } else {
        // 按分类搜索照片
        newPhotos = await _unsplashService.searchPhotos(
          query: _selectedCategory.query ?? _selectedCategory.name,
          page: refresh ? 1 : _currentPage,
          perPage: 30,
        );
      }

      setState(() {
        if (refresh) {
          _photos.clear();
          _currentPage = 1;
        }
        _photos.addAll(newPhotos);
        _currentPage++;
        _hasMore = newPhotos.isNotEmpty;
        _isLoading = false;
      });

      debugPrint('加载照片成功: 当前共 ${_photos.length} 张照片');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('加载照片失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载失败: ${e.toString()}')));
      }
    }
  }

  /// 切换分类
  ///
  /// 参数:
  /// - [category] PhotoCategory 选中的分类
  ///
  /// 返回:
  /// - void
  void _onCategoryChanged(PhotoCategory category) {
    if (_selectedCategory.id == category.id) return;

    setState(() {
      _selectedCategory = category;
    });

    debugPrint('切换分类: ${category.name}');
    _loadPhotos(refresh: true);
  }

  /// 判断是否为桌面平台
  ///
  /// 返回:
  /// - bool 是否为桌面平台（Web、macOS、Windows）
  bool get _isDesktopPlatform {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  /// 计算网格列数
  ///
  /// 参数:
  /// - [context] BuildContext 上下文
  ///
  /// 返回:
  /// - int 列数
  /// - 移动端：根据屏幕宽度动态计算，最少 2 列
  /// - 桌面端：固定 3 列
  int _calculateCrossAxisCount(BuildContext context) {
    // 桌面平台（Web、macOS、Windows）固定显示 3 列
    if (_isDesktopPlatform) {
      return 3;
    }

    // 移动平台根据屏幕宽度动态计算
    final screenWidth = MediaQuery.of(context).size.width;
    // 每个图片最小宽度 150，最少 2 列
    final count = (screenWidth / 150).floor();
    return count < 2 ? 2 : count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF667EEA), // 紫蓝色
              Color(0xFF764BA2), // 深紫色
              Color(0xFFF093FB), // 粉紫色
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'WallpaperUnsplash',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 分类按钮组
          _buildCategoryBar(),

          // 图片网格
          Expanded(
            child: _photos.isEmpty && _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildPhotoGrid(),
          ),
        ],
      ),
    );
  }

  /// 构建分类按钮栏
  ///
  /// 返回:
  /// - Widget 分类按钮栏组件
  Widget _buildCategoryBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: PhotoCategory.categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = PhotoCategory.categories[index];
          final isSelected = _selectedCategory.id == category.id;

          return _buildCategoryButton(category, isSelected);
        },
      ),
    );
  }

  /// 构建单个分类按钮
  ///
  /// 参数:
  /// - [category] PhotoCategory 分类对象
  /// - [isSelected] bool 是否选中
  ///
  /// 返回:
  /// - Widget 分类按钮组件
  Widget _buildCategoryButton(PhotoCategory category, bool isSelected) {
    return Material(
      color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _onCategoryChanged(category),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Text(
            category.name,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: 0.3,
            ),
            overflow: TextOverflow.visible,
            maxLines: 1,
          ),
        ),
      ),
    );
  }

  /// 构建照片网格
  ///
  /// 返回:
  /// - Widget 照片网格组件
  Widget _buildPhotoGrid() {
    final crossAxisCount = _calculateCrossAxisCount(context);
    // 桌面端使用更大的间距和宽高比
    final spacing = _isDesktopPlatform ? 12.0 : 4.0;
    final padding = _isDesktopPlatform ? 16.0 : 4.0;
    final childAspectRatio = _isDesktopPlatform ? 0.75 : 1.0;

    return RefreshIndicator(
      onRefresh: () => _loadPhotos(refresh: true),
      child: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(padding),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: _photos.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _photos.length) {
            // 加载更多指示器
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          return _buildPhotoItem(_photos[index]);
        },
      ),
    );
  }

  /// 构建单个照片项
  ///
  /// 参数:
  /// - [photo] UnsplashPhoto 照片对象
  ///
  /// 返回:
  /// - Widget 照片项组件
  Widget _buildPhotoItem(UnsplashPhoto photo) {
    // 桌面端添加圆角和阴影
    final borderRadius = _isDesktopPlatform
        ? BorderRadius.circular(12)
        : BorderRadius.zero;

    return GestureDetector(
      onTap: () {
        debugPrint('点击照片: ${photo.id}');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PhotoDetailPage(photo: photo),
          ),
        );
      },
      child: Hero(
        tag: photo.id,
        child: Container(
          decoration: _isDesktopPlatform
              ? BoxDecoration(
                  borderRadius: borderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
              : null,
          child: ClipRRect(
            borderRadius: borderRadius,
            child: CachedNetworkImage(
              imageUrl: '${photo.urls.small}&w=400&h=600&fit=crop',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error, color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
