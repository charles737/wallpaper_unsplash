# Wallpaper Unsplash Makefile
# 用于简化常用的构建和开发命令

.PHONY: help clean get build-macos build-macos-dmg build-ios build-android run-macos run-ios run-android

# 默认目标：显示帮助信息
help:
	@echo "📱 WallpaperUnsplash 构建命令"
	@echo ""
	@echo "开发命令："
	@echo "  make get              - 获取依赖"
	@echo "  make clean            - 清理构建文件"
	@echo "  make run-macos        - 运行 macOS 应用"
	@echo "  make run-ios          - 运行 iOS 应用"
	@echo "  make run-android      - 运行 Android 应用"
	@echo ""
	@echo "构建命令："
	@echo "  make build-macos      - 构建 macOS 应用 (.app)"
	@echo "  make build-macos-dmg  - 构建 macOS 安装包 (.dmg) ⭐"
	@echo "  make build-ios        - 构建 iOS 应用"
	@echo "  make build-android    - 构建 Android APK"
	@echo ""
	@echo "工具命令："
	@echo "  make check-arch       - 检查 macOS 应用支持的架构"
	@echo ""

# 获取依赖
get:
	@echo "📦 获取依赖..."
	flutter pub get

# 清理构建文件
clean:
	@echo "🧹 清理构建文件..."
	flutter clean

# 运行 macOS 应用
run-macos:
	@echo "🚀 运行 macOS 应用..."
	flutter run -d macos

# 运行 iOS 应用
run-ios:
	@echo "🚀 运行 iOS 应用..."
	flutter run -d ios

# 运行 Android 应用
run-android:
	@echo "🚀 运行 Android 应用..."
	flutter run -d android

# 构建 macOS 应用 (.app)
build-macos:
	@echo "🔨 构建 macOS 应用..."
	flutter build macos --release
	@echo "✅ 构建完成！"
	@echo "📍 位置: build/macos/Build/Products/Release/wallpaper_unsplash.app"

# 构建 macOS DMG 安装包
build-macos-dmg:
	@echo "📦 构建 macOS DMG 安装包..."
	@bash scripts/build_macos_dmg.sh

# 构建 iOS 应用
build-ios:
	@echo "🔨 构建 iOS 应用..."
	flutter build ios --release
	@echo "✅ 构建完成！"

# 构建 Android APK
build-android:
	@echo "🔨 构建 Android APK..."
	flutter build apk --release
	@echo "✅ 构建完成！"
	@echo "📍 位置: build/app/outputs/flutter-apk/app-release.apk"

# 构建 Android App Bundle
build-android-bundle:
	@echo "🔨 构建 Android App Bundle..."
	flutter build appbundle --release
	@echo "✅ 构建完成！"
	@echo "📍 位置: build/app/outputs/bundle/release/app-release.aab"

# 检查 macOS 应用架构
check-arch:
	@echo "🔍 检查 macOS 应用架构..."
	@bash scripts/check_architecture.sh

