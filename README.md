# Wallpaper Unsplash

一个使用 Flutter 开发的壁纸应用，集成了 Unsplash API 来获取高质量的图片。

## ✨ 功能特点

- 🎨 欢迎页面展示随机 Unsplash 高清壁纸（1080p）
- 🔄 支持刷新壁纸功能
- 📱 优雅的 UI 设计
- 🚫 已关闭 Debug 标签

## 🏗️ 项目结构

```
lib/
├── main.dart                        # 应用入口
├── models/
│   └── unsplash_photo.dart         # Unsplash 照片数据模型
├── services/
│   └── unsplash_service.dart       # Unsplash API 服务类
└── pages/
    └── welcome_page.dart           # 欢迎页面
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

请参考 [UNSPLASH_API_SETUP.md](./UNSPLASH_API_SETUP.md) 获取详细配置说明。

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

## 📱 支持平台

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ macOS
- ✅ Linux
- ✅ Windows

## 📄 API 文档

### UnsplashService 类

主要方法：

- `getRandomPhoto()` - 获取随机照片
- `searchPhotos()` - 搜索照片
- `getPhotoById()` - 根据 ID 获取照片

详细文档请查看代码注释。

## 🎯 待开发功能

- [ ] 壁纸浏览和搜索
- [ ] 壁纸收藏功能
- [ ] 壁纸下载功能
- [ ] 分类浏览
- [ ] 个人收藏集

## 📝 许可证

本项目仅供学习和参考使用。

## 🙏 致谢

- [Unsplash](https://unsplash.com/) - 提供高质量的免费图片
- [Flutter](https://flutter.dev/) - 优秀的跨平台开发框架
