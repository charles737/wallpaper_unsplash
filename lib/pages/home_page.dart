import 'package:flutter/material.dart';
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

  /// 计算网格列数
  ///
  /// 参数:
  /// - [context] BuildContext 上下文
  ///
  /// 返回:
  /// - int 列数（最少3列）
  int _calculateCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 每个图片最小宽度 120，最少 3 列
    final count = (screenWidth / 120).floor();
    return count < 3 ? 3 : count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('壁纸工具'),
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
      height: 50,
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
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: PhotoCategory.categories.length,
        itemBuilder: (context, index) {
          final category = PhotoCategory.categories[index];
          final isSelected = _selectedCategory.id == category.id;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: ChoiceChip(
              label: Text(category.name),
              selected: isSelected,
              onSelected: (_) => _onCategoryChanged(category),
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建照片网格
  ///
  /// 返回:
  /// - Widget 照片网格组件
  Widget _buildPhotoGrid() {
    final crossAxisCount = _calculateCrossAxisCount(context);

    return RefreshIndicator(
      onRefresh: () => _loadPhotos(refresh: true),
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(4),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1.0, // 正方形
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
        child: CachedNetworkImage(
          imageUrl: '${photo.urls.small}&w=208&h=208&fit=crop',
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
    );
  }
}
