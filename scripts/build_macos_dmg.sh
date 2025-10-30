#!/bin/bash

# macOS DMG 构建脚本
# 用法: ./scripts/build_macos_dmg.sh

set -e

echo "🚀 开始构建 macOS 应用..."

# 定义变量
APP_NAME="wallpaper_unsplash"
BUILD_DIR="build/macos/Build/Products/Release"
DMG_DIR="build/macos/dmg"
DMG_NAME="${APP_NAME}_macos"
VOLUME_NAME="WallpaperUnsplash"

# 清理旧的构建文件
echo "🧹 清理旧的构建文件..."
flutter clean

# 获取依赖
echo "📦 获取依赖..."
flutter pub get

# 构建 macOS Release 版本（Universal Binary - 支持 Intel 和 Apple Silicon）
echo "🔨 构建 macOS Release 版本（Universal Binary）..."
echo "   支持架构：x86_64 (Intel) + arm64 (Apple Silicon)"
flutter build macos --release

# 检查构建是否成功
if [ ! -d "${BUILD_DIR}/${APP_NAME}.app" ]; then
    echo "❌ 构建失败: 找不到 ${APP_NAME}.app"
    exit 1
fi

echo "✅ 应用构建成功!"

# 检查二进制架构
echo ""
echo "🔍 检查二进制架构..."
BINARY_PATH="${BUILD_DIR}/${APP_NAME}.app/Contents/MacOS/${APP_NAME}"
if [ -f "${BINARY_PATH}" ]; then
    ARCHS=$(lipo -archs "${BINARY_PATH}" 2>/dev/null || echo "无法检测")
    echo "   支持的架构：${ARCHS}"
    if [[ "${ARCHS}" == *"x86_64"* ]] && [[ "${ARCHS}" == *"arm64"* ]]; then
        echo "   ✅ Universal Binary - 支持 Intel 和 Apple Silicon"
    elif [[ "${ARCHS}" == *"arm64"* ]]; then
        echo "   ⚠️  仅支持 Apple Silicon (M 芯片)"
    elif [[ "${ARCHS}" == *"x86_64"* ]]; then
        echo "   ⚠️  仅支持 Intel 芯片"
    fi
else
    echo "   ⚠️  无法检测二进制文件"
fi
echo ""

# 创建 DMG 目录
echo "📁 准备创建 DMG..."
rm -rf "${DMG_DIR}"
mkdir -p "${DMG_DIR}"

# 复制 .app 文件到 DMG 目录
echo "📋 复制应用文件..."
cp -R "${BUILD_DIR}/${APP_NAME}.app" "${DMG_DIR}/"

# 创建应用程序文件夹的符号链接（方便用户拖拽安装）
echo "🔗 创建应用程序文件夹链接..."
ln -s /Applications "${DMG_DIR}/Applications"

# 删除旧的 DMG 文件
echo "🗑️  删除旧的 DMG 文件..."
rm -f "build/macos/${DMG_NAME}.dmg"
rm -f "build/macos/${DMG_NAME}_temp.dmg"

# 创建临时 DMG
echo "🔧 创建临时 DMG..."
hdiutil create -volname "${VOLUME_NAME}" \
    -srcfolder "${DMG_DIR}" \
    -ov -format UDRW \
    "build/macos/${DMG_NAME}_temp.dmg"

# 挂载临时 DMG 进行定制
echo "💿 挂载临时 DMG..."
MOUNT_DIR=$(hdiutil attach -readwrite -noverify -noautoopen \
    "build/macos/${DMG_NAME}_temp.dmg" | \
    egrep '^/dev/' | sed 1q | awk '{print $3}')

echo "📐 配置 DMG 窗口样式..."
# 使用 AppleScript 设置 Finder 窗口样式
osascript <<EOD
tell application "Finder"
    tell disk "${VOLUME_NAME}"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {100, 100, 700, 500}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 100
        set position of item "${APP_NAME}.app" of container window to {150, 200}
        set position of item "Applications" of container window to {450, 200}
        update without registering applications
        delay 2
        close
    end tell
end tell
EOD

# 设置 DMG 图标（如果有自定义图标）
# 这里可以添加自定义背景和图标的代码

# 卸载 DMG
echo "⏏️  卸载临时 DMG..."
hdiutil detach "${MOUNT_DIR}" -quiet

# 压缩并创建最终的只读 DMG
echo "🗜️  压缩并创建最终 DMG..."
hdiutil convert "build/macos/${DMG_NAME}_temp.dmg" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -o "build/macos/${DMG_NAME}.dmg"

# 清理临时文件
echo "🧹 清理临时文件..."
rm -f "build/macos/${DMG_NAME}_temp.dmg"
rm -rf "${DMG_DIR}"

# 获取 DMG 文件信息
DMG_PATH="build/macos/${DMG_NAME}.dmg"
DMG_SIZE=$(du -h "${DMG_PATH}" | cut -f1)

echo ""
echo "✨ ================================================"
echo "✅ DMG 创建成功！"
echo "================================================"
echo "📦 文件名: ${DMG_NAME}.dmg"
echo "📍 位置: ${DMG_PATH}"
echo "📊 大小: ${DMG_SIZE}"
echo "🖥️  兼容性: Intel + Apple Silicon (Universal)"
echo "================================================"
echo ""
echo "💡 安装方法："
echo "   1. 双击打开 ${DMG_NAME}.dmg"
echo "   2. 将 ${APP_NAME}.app 拖拽到 Applications 文件夹"
echo "   3. 从 Applications 文件夹运行应用"
echo ""
echo "✅ 此 DMG 可在以下 Mac 上安装："
echo "   • Intel Mac (x86_64)"
echo "   • Apple Silicon Mac (M1/M2/M3 等 arm64)"
echo ""

