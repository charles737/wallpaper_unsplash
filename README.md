# Wallpaper Unsplash

一个使用 Flutter 开发的壁纸应用，集成了 Unsplash API 来获取高质量的图片。

## ✨ 功能特点

- 🎨 欢迎页面展示随机 Unsplash 高清壁纸（1080p）
- 🔄 支持刷新壁纸功能
- 📱 优雅的 UI 设计
- 🚫 已关闭 Debug 标签
- 📂 壁纸分类浏览（自然、建筑、动物等）
- 🔍 图片详情查看（支持缩放、旋转）
- 💾 **图片下载保存到相册**
- 📋 **已下载图片管理**
- 🔗 图片分享功能

## 🏗️ 项目结构

```
lib/
├── main.dart                        # 应用入口
├── models/
│   ├── unsplash_photo.dart         # Unsplash 照片数据模型
│   └── photo_category.dart         # 照片分类数据模型
├── services/
│   └── unsplash_service.dart       # Unsplash API 服务类
└── pages/
    ├── welcome_page.dart           # 欢迎页面
    ├── home_page.dart              # 主页（分类浏览）
    ├── photo_detail_page.dart      # 图片详情页（含下载功能）
    └── downloaded_photos_page.dart # 已下载图片管理页面
```

## 🚀 快速开始

### 1. 克隆项目

```bash
git clone <repository-url>
cd wallpaper_unsplash
```

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 配置 Unsplash API Key

⚠️ **必须配置 API Key 才能运行**

请参考 [Unsplash API 设置文档](./doc/api/UNSPLASH_API_SETUP.md) 获取详细配置说明。

简要步骤：
1. 访问 [Unsplash Developers](https://unsplash.com/developers) 注册应用
2. 获取 Access Key
3. 修改 `lib/services/unsplash_service.dart` 中的 `_accessKey` 常量

### 4. 运行应用

```bash
flutter run
```

## 📦 依赖

- `flutter` - Flutter SDK
- `http: ^1.2.0` - HTTP 请求库
- `cupertino_icons: ^1.0.8` - iOS 风格图标
- `cached_network_image: ^3.3.1` - 网络图片缓存
- `photo_view: ^0.15.0` - 图片查看和缩放
- `share_plus: ^10.1.2` - 分享功能
- `saver_gallery: ^3.0.6` - 保存图片到相册
- `shared_preferences: ^2.3.3` - 本地数据存储
- `permission_handler: ^11.3.1` - 权限管理

## 📱 支持平台

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ macOS
- ✅ Linux
- ✅ Windows

## 📚 文档中心

完整的项目文档请访问 [文档中心](./doc/README.md)：

- 📖 [使用说明文档](./doc/guides/) - 功能介绍和开发指南
- 🔧 [修复文档](./doc/fixes/) - 问题排查和解决方案
- 🌐 [API 接口文档](./doc/api/) - 第三方服务集成

## 📄 API 文档

### UnsplashService 类

主要方法：

- `getRandomPhoto()` - 获取随机照片
- `searchPhotos()` - 搜索照片
- `getPhotoById()` - 根据 ID 获取照片

详细文档请查看代码注释。

## 💾 下载功能

应用支持将高清壁纸保存到设备相册，并提供已下载图片的管理功能。

**主要特性：**
- 下载 1440p 高清图片（2560x1440）
- 自动保存到系统相册
- 下载进度提示
- 已下载图片列表管理
- 支持删除和清空下载记录

详细使用说明请查看 [下载功能文档](./doc/guides/DOWNLOAD_FEATURE.md)

## 🎯 已完成功能

- ✅ 壁纸分类浏览
- ✅ 图片详情查看（缩放、旋转）
- ✅ 图片下载保存
- ✅ 已下载图片管理
- ✅ 图片分享功能

## 🚧 待开发功能

- [ ] 壁纸搜索功能
- [ ] 壁纸收藏功能
- [ ] 设置为壁纸
- [ ] 批量下载
- [ ] 个人收藏集
- [ ] 选择下载质量

## 📝 许可证

本项目仅供学习和参考使用。

## 🙏 致谢

- [Unsplash](https://unsplash.com/) - 提供高质量的免费图片
- [Flutter](https://flutter.dev/) - 优秀的跨平台开发框架
