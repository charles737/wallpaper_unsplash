#!/bin/bash

# macOS 应用架构检查脚本
# 用于验证应用支持的 CPU 架构

set -e

APP_NAME="wallpaper_unsplash"
BUILD_DIR="build/macos/Build/Products/Release"
BINARY_PATH="${BUILD_DIR}/${APP_NAME}.app/Contents/MacOS/${APP_NAME}"

echo "🔍 检查 macOS 应用架构"
echo "================================"

# 检查应用是否存在
if [ ! -f "${BINARY_PATH}" ]; then
    echo "❌ 找不到应用二进制文件"
    echo "📍 期望位置: ${BINARY_PATH}"
    echo ""
    echo "💡 请先构建应用："
    echo "   flutter build macos --release"
    echo "   或"
    echo "   make build-macos-dmg"
    exit 1
fi

echo "📍 应用位置: ${BINARY_PATH}"
echo ""

# 使用 file 命令查看文件类型
echo "📄 文件信息："
file "${BINARY_PATH}"
echo ""

# 使用 lipo 命令查看支持的架构
echo "🏗️  支持的 CPU 架构："
ARCHS=$(lipo -archs "${BINARY_PATH}" 2>/dev/null)
echo "   ${ARCHS}"
echo ""

# 详细分析架构
echo "📊 详细架构信息："
lipo -info "${BINARY_PATH}"
echo ""

# 判断架构类型
echo "✅ 兼容性分析："
if [[ "${ARCHS}" == *"x86_64"* ]] && [[ "${ARCHS}" == *"arm64"* ]]; then
    echo "   ✅ Universal Binary (通用二进制)"
    echo "   ✅ 支持 Intel Mac (x86_64)"
    echo "   ✅ 支持 Apple Silicon Mac (M1/M2/M3 等 arm64)"
    echo ""
    echo "   💡 这是最佳配置！同一个应用可以在所有 Mac 上运行"
elif [[ "${ARCHS}" == *"arm64"* ]]; then
    echo "   ⚠️  仅支持 Apple Silicon (arm64)"
    echo "   ✅ 可以在 M1/M2/M3 Mac 上原生运行"
    echo "   ❌ 无法在 Intel Mac 上运行"
    echo ""
    echo "   💡 建议构建 Universal Binary 以支持所有 Mac"
elif [[ "${ARCHS}" == *"x86_64"* ]]; then
    echo "   ⚠️  仅支持 Intel (x86_64)"
    echo "   ✅ 可以在 Intel Mac 上原生运行"
    echo "   ⚠️  可以在 Apple Silicon Mac 上通过 Rosetta 2 运行（性能略低）"
    echo ""
    echo "   💡 建议构建 Universal Binary 以获得最佳性能"
else
    echo "   ❌ 未知架构：${ARCHS}"
fi

echo ""
echo "================================"

# 显示文件大小
echo "📊 文件大小："
du -h "${BINARY_PATH}" | awk '{print "   "$1}'
echo ""

# 显示整个 .app 包的大小
APP_PATH="${BUILD_DIR}/${APP_NAME}.app"
echo "📦 应用包大小："
du -sh "${APP_PATH}" | awk '{print "   "$1}'
echo ""

# 当前系统架构
SYSTEM_ARCH=$(uname -m)
echo "🖥️  当前系统架构："
if [[ "${SYSTEM_ARCH}" == "x86_64" ]]; then
    echo "   Intel (x86_64)"
elif [[ "${SYSTEM_ARCH}" == "arm64" ]]; then
    echo "   Apple Silicon (arm64)"
else
    echo "   ${SYSTEM_ARCH}"
fi

echo ""
echo "================================"
echo "✅ 检查完成！"


