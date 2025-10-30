/// Unsplash 照片数据模型
/// 用于解析和存储从 Unsplash API 返回的照片数据
class UnsplashPhoto {
  /// 照片唯一标识符
  final String id;

  /// 照片描述
  final String? description;

  /// 照片替代描述
  final String? altDescription;

  /// 照片 URLs
  final PhotoUrls urls;

  /// 照片作者信息
  final User user;

  /// 照片宽度
  final int width;

  /// 照片高度
  final int height;

  UnsplashPhoto({
    required this.id,
    this.description,
    this.altDescription,
    required this.urls,
    required this.user,
    required this.width,
    required this.height,
  });

  /// 从 JSON 数据创建 UnsplashPhoto 对象
  ///
  /// 参数:
  /// - [json] Map\<String, dynamic\> JSON 数据对象
  ///
  /// 返回:
  /// - UnsplashPhoto 照片对象
  factory UnsplashPhoto.fromJson(Map<String, dynamic> json) {
    return UnsplashPhoto(
      id: json['id'] as String,
      description: json['description'] as String?,
      altDescription: json['alt_description'] as String?,
      urls: PhotoUrls.fromJson(json['urls'] as Map<String, dynamic>),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      width: json['width'] as int,
      height: json['height'] as int,
    );
  }

  /// 将 UnsplashPhoto 对象转换为 JSON
  ///
  /// 返回:
  /// - Map\<String, dynamic\> JSON 数据对象
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'alt_description': altDescription,
      'urls': urls.toJson(),
      'user': user.toJson(),
      'width': width,
      'height': height,
    };
  }
}

/// 照片 URLs 数据模型
/// 包含不同尺寸的照片链接
class PhotoUrls {
  /// 原始图片 URL
  final String raw;

  /// 完整尺寸图片 URL
  final String full;

  /// 常规尺寸图片 URL
  final String regular;

  /// 小尺寸图片 URL
  final String small;

  /// 缩略图 URL
  final String thumb;

  PhotoUrls({
    required this.raw,
    required this.full,
    required this.regular,
    required this.small,
    required this.thumb,
  });

  /// 从 JSON 数据创建 PhotoUrls 对象
  ///
  /// 参数:
  /// - [json] Map\<String, dynamic\> JSON 数据对象
  ///
  /// 返回:
  /// - PhotoUrls URLs 对象
  factory PhotoUrls.fromJson(Map<String, dynamic> json) {
    return PhotoUrls(
      raw: json['raw'] as String,
      full: json['full'] as String,
      regular: json['regular'] as String,
      small: json['small'] as String,
      thumb: json['thumb'] as String,
    );
  }

  /// 将 PhotoUrls 对象转换为 JSON
  ///
  /// 返回:
  /// - Map\<String, dynamic\> JSON 数据对象
  Map<String, dynamic> toJson() {
    return {
      'raw': raw,
      'full': full,
      'regular': regular,
      'small': small,
      'thumb': thumb,
    };
  }
}

/// 用户数据模型
/// 包含照片作者的信息
class User {
  /// 用户唯一标识符
  final String id;

  /// 用户名
  final String username;

  /// 用户显示名称
  final String name;

  /// 用户头像 URL
  final String? profileImage;

  User({
    required this.id,
    required this.username,
    required this.name,
    this.profileImage,
  });

  /// 从 JSON 数据创建 User 对象
  ///
  /// 参数:
  /// - [json] Map\<String, dynamic\> JSON 数据对象
  ///
  /// 返回:
  /// - User 用户对象
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      name: json['name'] as String,
      profileImage: json['profile_image']?['large'] as String?,
    );
  }

  /// 将 User 对象转换为 JSON
  ///
  /// 返回:
  /// - Map\<String, dynamic\> JSON 数据对象
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'profile_image': {'large': profileImage},
    };
  }
}
