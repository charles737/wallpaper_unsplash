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

### 📂 程序目录清单

```
wallpaper_unsplash/
├── lib/                              # 源代码目录
│   ├── main.dart                     # 应用入口
│   ├── models/                       # 数据模型
│   │   ├── photo_category.dart       # 照片分类数据模型
│   │   └── unsplash_photo.dart       # Unsplash 照片数据模型
│   ├── pages/                        # 页面组件
│   │   ├── downloaded_photos_page.dart  # 已下载图片管理页
│   │   ├── home_page.dart            # 首页（分类浏览）
│   │   ├── photo_detail_page.dart    # 图片详情页（含下载功能）
│   │   └── welcome_page.dart         # 欢迎页面
│   └── services/                     # 服务类
│       ├── download_helper_stub.dart # 下载辅助（存根）
│       ├── download_helper_web.dart  # 下载辅助（Web平台）
│       ├── theme_manager.dart        # 主题管理器
│       └── unsplash_service.dart     # Unsplash API 服务
├── android/                          # Android 平台配置
├── ios/                              # iOS 平台配置
├── web/                              # Web 平台配置
├── macos/                            # macOS 平台配置
├── linux/                            # Linux 平台配置
├── windows/                          # Windows 平台配置
├── doc/                              # 项目文档
│   ├── README.md                     # 文档中心索引
│   ├── api/                          # API 接口文档
│   ├── fixes/                        # 问题修复文档
│   ├── guides/                       # 使用说明文档
│   └── refactor/                     # 重构文档
├── pubspec.yaml                      # 项目依赖配置
└── README.md                         # 项目说明文档
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

### 3. 配置环境变量和 API Key

⚠️ **必须配置才能运行**

**第一步：配置 .env 文件**

在项目根目录创建 `.env` 文件并添加您的 API Key：

```dotenv
UNSPLASH_ACCESS_KEY=你的_Unsplash_Access_Key
```

详细说明请参考 [环境配置文档](./doc/refactor/ENV_SETUP.md)

**第二步：获取 Unsplash API Key**

请参考 [Unsplash API 设置文档](./doc/api/UNSPLASH_API_SETUP.md) 获取详细配置说明。

简要步骤：
1. 访问 [Unsplash Developers](https://unsplash.com/developers) 注册应用
2. 获取 Access Key
3. 将 Access Key 添加到 `.env` 文件

### 4. 运行应用

```bash
flutter run
```

## 🏗️ 构建发布版本

项目提供了便捷的构建脚本和 Makefile 命令。

### macOS DMG 安装包 (.dmg)

**方法 1：使用 Makefile（推荐）**
```bash
make build-macos-dmg
```

**方法 2：直接运行脚本**
```bash
./scripts/build_macos_dmg.sh
```

构建完成后，DMG 文件位置：`build/macos/wallpaper_unsplash_macos.dmg`

### 其他平台

```bash
# Android APK
make build-android
# 或
flutter build apk --release

# iOS
make build-ios
# 或
flutter build ios --release

# macOS .app (不打包 DMG)
make build-macos
# 或
flutter build macos --release
```

### Makefile 命令列表

```bash
make help              # 显示所有可用命令
make clean             # 清理构建文件
make get               # 获取依赖
make run-macos         # 运行 macOS 应用
make build-macos-dmg   # 构建 macOS DMG 安装包 ⭐
make check-arch        # 检查应用支持的 CPU 架构
```

### 关于 Intel 和 Apple Silicon 支持

✨ **好消息**：默认构建的 DMG 是 **Universal Binary（通用二进制）**

- ✅ **同一个 DMG 同时支持 Intel 和 M 芯片（M1/M2/M3）**
- ✅ 无需分别打包
- ✅ 系统会自动选择对应架构运行

验证架构支持：
```bash
make check-arch
```

## 📦 Flutter 组件与依赖

### 核心依赖包

| 组件包 | 版本 | 用途说明 |
|--------|------|----------|
| `flutter` | SDK | Flutter 框架核心 |
| `http` | ^1.2.0 | HTTP 网络请求，用于调用 Unsplash API |
| `cached_network_image` | ^3.3.1 | 网络图片缓存加载，提升图片加载性能 |
| `photo_view` | ^0.15.0 | 图片查看器，支持缩放、旋转、拖动 |
| `share_plus` | ^10.1.2 | 跨平台分享功能 |
| `saver_gallery` | ^3.0.6 | 保存图片到设备相册 |
| `shared_preferences` | ^2.3.3 | 本地数据持久化存储 |
| `permission_handler` | ^11.3.1 | 运行时权限管理 |
| `cupertino_icons` | ^1.0.8 | iOS 风格图标库 |

### 主要 Flutter 组件

**UI 组件：**
- `MaterialApp` - Material Design 应用容器
- `Scaffold` - 页面脚手架（AppBar + Body）
- `AppBar` - 应用顶部导航栏
- `GridView` - 网格布局（图片列表）
- `ListView` - 列表布局（分类选择）
- `Card` - 卡片组件
- `FilterChip` - 筛选标签按钮
- `CircularProgressIndicator` - 圆形加载指示器
- `Hero` - 页面过渡动画
- `GestureDetector` - 手势检测
- `RefreshIndicator` - 下拉刷新

**导航组件：**
- `Navigator` - 页面路由导航
- `MaterialPageRoute` - Material 风格页面路由

**状态管理：**
- `StatefulWidget` - 有状态组件
- `ChangeNotifier` - 状态通知（主题管理）
- `setState()` - 局部状态更新

**主题系统：**
- `ThemeData` - 主题配置
- `ThemeManager` - 自定义主题管理器
- `ThemeMode` - 主题模式（明暗切换）
- 支持亮色/暗色主题自动切换
- 主题色：`#BA7264`（玫瑰棕色）

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
- 🔄 [重构文档](./doc/refactor/) - 项目重构记录和规范

### ⚠️ 重要文档（必读）

**新项目启动必看：**
1. [环境配置说明](./doc/refactor/ENV_SETUP.md) - 配置 .env 文件
2. [重构完成报告](./doc/refactor/REFACTOR_COMPLETE.md) - 了解最新的项目架构

## 📄 API 接口文档

### UnsplashService 类

主要方法：

| 方法 | 功能说明 |
|------|----------|
| `getPhotos()` | 获取照片列表（支持分页、排序） |
| `getRandomPhoto()` | 获取随机照片（支持尺寸、主题筛选） |
| `searchPhotos()` | 搜索照片（支持关键词、分页） |
| `getPhotoById()` | 获取指定 ID 的照片详情 |

**详细文档：**
- [**API 接口参考**](./doc/api/API_REFERENCE.md) - 完整的接口文档、参数说明、使用示例
- [**API 配置指南**](./doc/api/UNSPLASH_API_SETUP.md) - API Key 获取和配置说明

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
