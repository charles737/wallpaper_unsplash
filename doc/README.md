# WallpaperUnsplash 文档中心

欢迎来到 WallpaperUnsplash 项目的文档中心！这里包含了项目的所有技术文档。

## 📚 文档目录

### 📖 [使用说明文档](./guides/)

项目功能介绍、开发指南和实现细节：

- [**项目概览**](./guides/PROJECT_OVERVIEW.md) - 项目整体介绍和架构说明
- [**首页功能**](./guides/HOME_PAGE_FEATURES.md) - 首页功能详细说明
- [**首页改进**](./guides/HOME_PAGE_IMPROVEMENTS.md) - 首页UI/UX优化记录
- [**图片详情页**](./guides/PHOTO_DETAIL_PAGE.md) - 图片详情页功能说明
- [**下载功能**](./guides/DOWNLOAD_FEATURE.md) - 图片下载和保存功能
- [**实现总结**](./guides/IMPLEMENTATION_SUMMARY.md) - 项目实现技术总结
- [**macOS DMG 构建指南**](./guides/BUILD_DMG_GUIDE.md) - macOS 安装包构建教程

### 🔧 [修复文档](./fixes/)

问题排查和解决方案记录：

#### 图片加载相关
- [**图片加载优化**](./fixes/IMAGE_LOADING_OPTIMIZATION.md) - 图片加载体验优化
- [**最终图片加载方案**](./fixes/FINAL_IMAGE_LOADING_SOLUTION.md) - 图片加载的最终解决方案
- [**图片宽高比修复**](./fixes/IMAGE_ASPECT_RATIO_FIX.md) - 不同尺寸图片显示修复
- [**图片覆盖修复**](./fixes/IMAGE_OVERLAY_FIX.md) - 高清图覆盖小图问题修复
- [**缓存未命中黑屏修复**](./fixes/CACHE_MISS_BLACK_SCREEN_FIX.md) - 缓存失效导致黑屏问题修复

#### Web 平台相关
- [**Web 平台修复**](./fixes/WEB_PLATFORM_FIX.md) - Web 平台下载功能适配
- [**Web 图片加载修复**](./fixes/WEB_IMAGE_LOADING_FIX.md) - Web 平台图片加载问题
- [**Web 图片不加载修复**](./fixes/WEB_IMAGE_NOT_LOADING_FIX.md) - Web 平台图片加载失败修复

#### 其他修复
- [**Hero Tag 冲突修复**](./fixes/HERO_TAG_CONFLICT_FIX.md) - iOS Hero 动画冲突解决
- [**应用名称更新**](./fixes/APP_NAME_UPDATE.md) - iOS/Android 应用名称修改

### 🌐 [API 接口文档](./api/)

外部服务接口说明：

- [**Unsplash API 设置**](./api/UNSPLASH_API_SETUP.md) - Unsplash API 配置和使用指南
- [**API 接口参考**](./api/API_REFERENCE.md) - 完整的 API 接口文档和使用示例

### 🔄 [重构文档](./refactor/)

项目重构记录和规范：

- [**环境配置说明**](./refactor/ENV_SETUP.md) - .env 文件配置指南
- [**重构计划**](./refactor/REFACTOR_PLAN.md) - 详细的重构计划和分析
- [**重构总结**](./refactor/REFACTOR_SUMMARY.md) - 重构内容和成果总结
- [**重构完成报告**](./refactor/REFACTOR_COMPLETE.md) - 完整的重构报告和使用说明

## 🚀 快速开始

1. **⚠️ 必读**：先查看 [环境配置说明](./refactor/ENV_SETUP.md) 配置 .env 文件
2. 阅读 [项目概览](./guides/PROJECT_OVERVIEW.md) 了解项目整体架构
3. 查看 [Unsplash API 设置](./api/UNSPLASH_API_SETUP.md) 配置 API 密钥
4. 参考 [使用说明文档](./guides/) 了解各功能模块
5. 遇到问题时查阅 [修复文档](./fixes/) 寻找解决方案
6. 了解重构内容请查看 [重构文档](./refactor/)

## 📝 文档分类说明

| 目录 | 说明 | 适用场景 |
|------|------|---------|
| **guides/** | 功能说明、开发指南 | 了解功能、学习实现 |
| **fixes/** | 问题修复记录 | 排查问题、学习经验 |
| **api/** | API 接口文档 | 集成第三方服务 |
| **refactor/** | 重构文档和规范 | 了解项目架构和代码规范 |

## 🔍 常见问题速查

### 图片显示问题
- 黑屏？→ [缓存未命中黑屏修复](./fixes/CACHE_MISS_BLACK_SCREEN_FIX.md)
- 图片覆盖？→ [图片覆盖修复](./fixes/IMAGE_OVERLAY_FIX.md)
- 宽高比不对？→ [图片宽高比修复](./fixes/IMAGE_ASPECT_RATIO_FIX.md)

### Web 平台问题
- 下载失败？→ [Web 平台修复](./fixes/WEB_PLATFORM_FIX.md)
- 图片不加载？→ [Web 图片加载修复](./fixes/WEB_IMAGE_LOADING_FIX.md)

### iOS 问题
- Hero 动画错误？→ [Hero Tag 冲突修复](./fixes/HERO_TAG_CONFLICT_FIX.md)

## 📊 文档统计

- **使用说明文档**: 7 篇
- **修复文档**: 10 篇
- **API 文档**: 2 篇
- **重构文档**: 4 篇
- **总计**: 23 篇

---

**持续更新中...** 📝✨


