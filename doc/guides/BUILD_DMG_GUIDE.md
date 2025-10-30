# macOS DMG 构建指南

本指南介绍如何构建 macOS 的 DMG 安装包。

## 🖥️ Intel vs Apple Silicon 支持

### Universal Binary（通用二进制）

✨ **好消息**：Flutter 默认构建 **Universal Binary**，这意味着：

- ✅ **同一个 DMG 可以在 Intel 和 M 芯片上运行**
- ✅ 包含 x86_64（Intel）和 arm64（Apple Silicon）两种架构
- ✅ 系统会自动选择对应的架构运行
- ✅ 无需分别打包

### 架构说明

| 芯片类型 | 架构 | 说明 |
|---------|------|------|
| Intel Mac | x86_64 | 传统 Intel 处理器 |
| M1/M2/M3 Mac | arm64 | Apple Silicon (Apple 自研芯片) |
| Universal Binary | x86_64 + arm64 | 包含两种架构（推荐） |

### 验证架构

构建完成后，脚本会自动显示支持的架构。您也可以手动验证：

```bash
# 使用验证脚本
./scripts/check_architecture.sh

# 或手动检查
lipo -archs build/macos/Build/Products/Release/wallpaper_unsplash.app/Contents/MacOS/wallpaper_unsplash
```

输出示例：
```
x86_64 arm64  ← Universal Binary（支持 Intel 和 Apple Silicon）
```

## 📋 前置要求

- macOS 操作系统（Intel 或 Apple Silicon 均可）
- Flutter SDK 已安装
- Xcode 已安装
- 已配置好开发环境

## 🚀 快速构建

### 方法 1：使用 Makefile（推荐）

最简单的方式：

```bash
make build-macos-dmg
```

### 方法 2：直接运行脚本

```bash
./scripts/build_macos_dmg.sh
```

## 📦 构建流程说明

构建脚本会自动执行以下步骤，**并自动生成 Universal Binary**：

1. **清理旧的构建文件**
   ```bash
   flutter clean
   ```

2. **获取依赖**
   ```bash
   flutter pub get
   ```

3. **构建 Release 版本的 .app**
   ```bash
   flutter build macos --release
   ```

4. **准备 DMG 内容**
   - 创建临时目录
   - 复制 .app 文件
   - 创建 Applications 文件夹的符号链接

5. **创建 DMG 镜像**
   - 使用 `hdiutil` 创建临时 DMG
   - 配置 Finder 窗口样式
   - 压缩并生成最终的只读 DMG

6. **清理临时文件**

## 📍 输出位置

构建完成后，DMG 文件位于：

```
build/macos/wallpaper_unsplash_macos.dmg
```

## 🎨 DMG 特性

生成的 DMG 安装包包含以下特性：

- ✅ **Universal Binary**：同时支持 Intel 和 Apple Silicon Mac
- ✅ **可拖拽安装**：包含应用图标和 Applications 文件夹符号链接
- ✅ **优化的窗口布局**：自动配置图标大小和位置
- ✅ **压缩格式**：使用 UDZO 格式压缩，减小文件体积
- ✅ **只读模式**：防止用户意外修改

## 📐 DMG 窗口配置

脚本会自动配置以下 Finder 窗口样式：

| 配置项 | 值 |
|--------|-----|
| 窗口大小 | 600x400 像素 |
| 视图模式 | 图标视图 |
| 图标大小 | 100 像素 |
| 应用图标位置 | (150, 200) |
| Applications 链接位置 | (450, 200) |

## 🛠️ 自定义配置

### 修改 DMG 名称

编辑 `scripts/build_macos_dmg.sh` 文件：

```bash
# 修改这些变量
DMG_NAME="${APP_NAME}_macos"          # DMG 文件名
VOLUME_NAME="WallpaperUnsplash"       # DMG 卷名
```

### 修改窗口布局

编辑脚本中的 AppleScript 部分：

```bash
# 窗口大小
set the bounds of container window to {100, 100, 700, 500}

# 图标大小
set icon size of viewOptions to 100

# 图标位置
set position of item "${APP_NAME}.app" of container window to {150, 200}
set position of item "Applications" of container window to {450, 200}
```

### 添加自定义背景

1. 准备背景图片（推荐 600x400 像素）
2. 在脚本的挂载 DMG 部分添加：

```bash
# 复制背景图片
mkdir "${MOUNT_DIR}/.background"
cp path/to/your/background.png "${MOUNT_DIR}/.background/"

# 在 AppleScript 中设置背景
set background picture of viewOptions to file ".background:background.png"
```

### 添加自定义 DMG 图标

```bash
# 在脚本中添加
cp path/to/icon.icns "${MOUNT_DIR}/.VolumeIcon.icns"
SetFile -c icnC "${MOUNT_DIR}/.VolumeIcon.icns"
SetFile -a C "${MOUNT_DIR}"
```

## ❓ 常见问题

### Q1: 如何验证应用支持的架构？

**回答：**
```bash
# 方法 1：使用验证脚本
./scripts/check_architecture.sh

# 方法 2：手动检查
lipo -archs build/macos/Build/Products/Release/wallpaper_unsplash.app/Contents/MacOS/wallpaper_unsplash
```

期望输出：`x86_64 arm64`（Universal Binary）

### Q2: 为什么 Universal Binary 文件更大？

**回答：**
Universal Binary 包含两套代码（Intel 和 Apple Silicon），所以体积约为单架构版本的 1.5-2 倍。但这样可以在所有 Mac 上原生运行，性能最佳。

### Q3: 可以只构建单一架构吗？

**回答：**
可以，但不推荐。如果确实需要：

```bash
# 仅 Apple Silicon
flutter build macos --release --target-platform darwin-arm64

# 仅 Intel
flutter build macos --release --target-platform darwin-x64
```

但这样生成的 DMG 只能在对应的 Mac 上运行。

### Q4: Intel Mac 可以构建支持 M 芯片的应用吗？

**回答：**
可以！Flutter 支持交叉编译。在 Intel Mac 上默认就会构建 Universal Binary，包含 arm64 代码。

### Q5: Apple Silicon Mac 可以构建支持 Intel 的应用吗？

**回答：**
可以！同样，在 Apple Silicon Mac 上默认也会构建 Universal Binary，包含 x86_64 代码。

## 🔍 故障排除

### 问题 1：脚本没有执行权限

**解决方案：**
```bash
chmod +x scripts/build_macos_dmg.sh
```

### 问题 2：hdiutil 命令失败

**可能原因：**
- 磁盘空间不足
- 旧的 DMG 文件被占用

**解决方案：**
```bash
# 清理旧文件
rm -f build/macos/*.dmg
rm -rf build/macos/dmg/

# 重新运行构建
make build-macos-dmg
```

### 问题 3：AppleScript 执行失败

**可能原因：**
- 没有授予脚本访问 Finder 的权限

**解决方案：**
1. 打开"系统偏好设置" > "安全性与隐私" > "隐私"
2. 在左侧选择"自动化"
3. 允许终端控制 Finder

### 问题 4：DMG 挂载后卸载失败

**解决方案：**
```bash
# 手动查找并卸载
hdiutil info | grep "wallpaper"
hdiutil detach /Volumes/WallpaperUnsplash -force

# 重新构建
make build-macos-dmg
```

## 📊 构建时间参考

| 步骤 | 预计时间 |
|------|----------|
| 清理和获取依赖 | 10-30 秒 |
| 构建 .app | 2-5 分钟 |
| 创建 DMG | 10-30 秒 |
| **总计** | **约 3-6 分钟** |

## 💡 最佳实践

1. **构建前清理**
   - 始终使用 `flutter clean` 确保干净构建

2. **版本号管理**
   - 在 `pubspec.yaml` 中更新版本号
   - DMG 文件名可以包含版本号

3. **测试安装**
   - 构建完成后，在干净的测试环境中验证 DMG
   - 确认应用可以正常拖拽安装

4. **代码签名**
   - 对于发布版本，需要添加 Apple 开发者签名
   - 使用 `codesign` 命令签名应用

5. **公证（Notarization）**
   - macOS 10.15+ 需要公证才能分发
   - 使用 `xcrun altool` 提交公证

## 🔐 代码签名与公证

### 签名应用

```bash
# 签名 .app
codesign --deep --force --verify --verbose \
  --sign "Developer ID Application: Your Name" \
  build/macos/Build/Products/Release/wallpaper_unsplash.app

# 签名 DMG
codesign --sign "Developer ID Application: Your Name" \
  build/macos/wallpaper_unsplash_macos.dmg
```

### 公证流程

```bash
# 1. 上传公证
xcrun altool --notarize-app \
  --primary-bundle-id "com.linzencode.wallpaperUnsplash" \
  --username "your@email.com" \
  --password "@keychain:AC_PASSWORD" \
  --file build/macos/wallpaper_unsplash_macos.dmg

# 2. 检查公证状态
xcrun altool --notarization-info <RequestUUID> \
  --username "your@email.com" \
  --password "@keychain:AC_PASSWORD"

# 3. 装订（Staple）公证票据
xcrun stapler staple build/macos/wallpaper_unsplash_macos.dmg
```

## 📚 相关资源

- [Flutter macOS 构建文档](https://docs.flutter.dev/deployment/macos)
- [Apple 代码签名指南](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [hdiutil 命令手册](https://ss64.com/osx/hdiutil.html)

## 🆘 获取帮助

如果遇到问题：

1. 查看本文档的故障排除部分
2. 检查脚本输出的错误信息
3. 在项目 Issues 中搜索类似问题
4. 提交新的 Issue 并附上详细错误日志

---

**最后更新：** 2025-01-30  
**维护者：** WallpaperUnsplash Team

