/// 照片分类模型
class PhotoCategory {
  /// 分类 ID
  final String id;

  /// 分类名称
  final String name;

  /// 分类查询关键词（用于 API 搜索）
  final String? query;

  const PhotoCategory({required this.id, required this.name, this.query});

  /// 预定义的分类列表
  static const List<PhotoCategory> categories = [
    PhotoCategory(id: 'all', name: '全部'),
    PhotoCategory(id: 'wallpapers', name: '壁纸', query: 'wallpapers'),
    PhotoCategory(id: 'nature', name: '自然', query: 'nature'),
    PhotoCategory(id: 'people', name: '人物', query: 'people'),
    PhotoCategory(id: 'architecture', name: '建筑', query: 'architecture'),
    PhotoCategory(id: 'animals', name: '动物', query: 'animals'),
    PhotoCategory(id: 'food', name: '美食', query: 'food'),
    PhotoCategory(id: 'travel', name: '旅行', query: 'travel'),
    PhotoCategory(id: 'technology', name: '科技', query: 'technology'),
    PhotoCategory(id: 'abstract', name: '抽象', query: 'abstract'),
  ];
}
