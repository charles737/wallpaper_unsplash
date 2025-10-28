# 首页功能说明

## ✨ 已实现功能

### 1. 图片墙网格布局
- ✅ **自适应列数**：根据屏幕宽度自动计算列数（最少3列）
  - 算法：`(屏幕宽度 / 120).floor()`，最少3列
  - 手机：通常 3-4 列
  - 平板：通常 5-8 列
  - 桌面：通常 8+ 列

- ✅ **正方形显示**：使用 `childAspectRatio: 1.0`
- ✅ **图片分辨率**：208x208 正方形裁剪
  - URL 参数：`&w=208&h=208&fit=crop`

### 2. 图片缓存功能
- ✅ 使用 `cached_network_image: ^3.4.1` 包
- ✅ 自动缓存已加载的图片
- ✅ 离线也能查看已缓存的图片
- ✅ 优化加载性能和流量消耗

### 3. 无限滚动加载
- ✅ **自动加载**：滚动到距底部 200px 时自动加载下一页
- ✅ **分页管理**：每页 30 张图片
- ✅ **加载指示器**：底部显示加载中动画
- ✅ **下拉刷新**：支持下拉刷新重新加载

### 4. 分类筛选功能
- ✅ **顶部分类栏**：横向可滚动的分类按钮组
- ✅ **预定义分类**：
  - 全部（默认）
  - 壁纸
  - 自然
  - 人物
  - 建筑
  - 动物
  - 美食
  - 旅行
  - 科技
  - 抽象

- ✅ **分类切换**：点击分类自动刷新列表
- ✅ **视觉反馈**：选中分类高亮显示

### 5. 错误处理
- ✅ **控制台日志**：使用 `debugPrint` 输出详细信息
  - 加载成功：显示当前照片总数
  - 加载失败：显示错误详情
  - 切换分类：显示分类名称

- ✅ **用户提示**：加载失败时显示 SnackBar
- ✅ **错误占位符**：图片加载失败显示错误图标

### 6. UI/UX 优化
- ✅ **标题居中**：AppBar 使用 `centerTitle: true`
- ✅ **标题文字**："壁纸工具"
- ✅ **加载占位符**：显示灰色占位块和加载动画
- ✅ **点击反馈**：图片可点击（预留详情页跳转）
- ✅ **Hero 动画**：使用 Hero 组件支持页面转场动画

## 📁 新增文件

```
lib/
├── models/
│   └── photo_category.dart         # 照片分类模型
├── pages/
│   └── home_page.dart              # 首页图片墙
└── services/
    └── unsplash_service.dart       # 新增 getPhotos() 方法
```

## 🎯 核心代码说明

### 自适应列数计算
```dart
int _calculateCrossAxisCount(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final count = (screenWidth / 120).floor();
  return count < 3 ? 3 : count;  // 最少3列
}
```

### 无限滚动监听
```dart
void _onScroll() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - 200) {
    if (!_isLoading && _hasMore) {
      _loadPhotos();
    }
  }
}
```

### 图片缓存加载
```dart
CachedNetworkImage(
  imageUrl: '${photo.urls.small}&w=208&h=208&fit=crop',
  fit: BoxFit.cover,
  placeholder: (context, url) => Container(...),
  errorWidget: (context, url, error) => Container(...),
)
```

### 分类筛选逻辑
```dart
if (_selectedCategory.id == 'all') {
  // 加载全部照片
  newPhotos = await _unsplashService.getPhotos(...);
} else {
  // 按分类搜索
  newPhotos = await _unsplashService.searchPhotos(
    query: _selectedCategory.query ?? _selectedCategory.name,
    ...
  );
}
```

## 🚀 使用说明

### 运行应用
```bash
flutter run
```

### 操作流程
1. 启动应用 → 进入欢迎页
2. 点击"开始使用" → 进入首页图片墙
3. 顶部选择分类 → 自动刷新列表
4. 向下滚动 → 自动加载更多
5. 下拉刷新 → 重新加载

## 📊 性能优化

1. **图片缓存**：避免重复下载，节省流量
2. **懒加载**：只加载可见区域的图片
3. **分页加载**：每次仅加载 30 张，减少内存占用
4. **提前触发**：距底部 200px 开始加载，流畅体验

## 🐛 调试信息

所有关键操作都会在控制台输出：
```
加载照片成功: 当前共 30 张照片
切换分类: 自然
加载照片失败: Exception: ...
点击照片: abc123
```

## 🔄 数据流

```
用户操作 → 触发加载
    ↓
判断分类（全部/特定）
    ↓
调用 API（getPhotos/searchPhotos）
    ↓
解析 JSON → UnsplashPhoto 列表
    ↓
更新 UI（GridView）
    ↓
缓存图片（CachedNetworkImage）
```

## 📝 待扩展功能

- [ ] 照片详情页
- [ ] 图片下载功能
- [ ] 收藏功能
- [ ] 搜索功能
- [ ] 瀑布流布局
- [ ] 图片预览
- [ ] 分享功能

---

**创建时间**: 2025-10-28  
**版本**: 1.0.0

