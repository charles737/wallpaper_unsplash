# 应用名称更新

## 📱 更新内容

已将iOS和Android端的应用显示名称统一修改为 **WallpaperUnsplash**。

## 🔧 修改的文件

### 1. Android 端

**文件**: `android/app/src/main/AndroidManifest.xml`

**修改内容**:
```xml
<application
    android:label="WallpaperUnsplash"
    ...
>
```

**位置**: 第16行

**说明**: `android:label` 属性控制应用在Android设备桌面和应用列表中显示的名称。

---

### 2. iOS 端

**文件**: `ios/Runner/Info.plist`

**修改内容**:

#### CFBundleDisplayName（显示名称）
```xml
<key>CFBundleDisplayName</key>
<string>WallpaperUnsplash</string>
```
**位置**: 第7-8行

**说明**: 控制应用在iOS设备主屏幕上显示的名称。

#### CFBundleName（Bundle名称）
```xml
<key>CFBundleName</key>
<string>WallpaperUnsplash</string>
```
**位置**: 第15-16行

**说明**: 应用的Bundle名称，用于系统内部识别。

---

## 📊 修改对比

| 平台 | 属性 | 修改前 | 修改后 |
|------|------|--------|--------|
| **Android** | `android:label` | `wallpaper_unsplash` | `WallpaperUnsplash` |
| **iOS** | `CFBundleDisplayName` | `Wallpaper Unsplash` | `WallpaperUnsplash` |
| **iOS** | `CFBundleName` | `wallpaper_unsplash` | `WallpaperUnsplash` |

---

## ✅ 生效说明

### Android
1. 重新编译应用后，桌面图标下方将显示 **WallpaperUnsplash**
2. 在应用列表、最近使用等位置都将显示新名称

### iOS
1. 重新编译应用后，主屏幕图标下方将显示 **WallpaperUnsplash**
2. 在App切换器、设置等位置都将显示新名称

### 如何应用更改
```bash
# 清理构建缓存
flutter clean

# 重新安装应用
flutter run
```

或者直接重新编译安装应用即可看到新的应用名称。

---

## 🎯 命名规范

现在应用名称在所有平台保持一致：
- ✅ **应用内标题**: `WallpaperUnsplash`（首页AppBar）
- ✅ **Android应用名**: `WallpaperUnsplash`
- ✅ **iOS应用名**: `WallpaperUnsplash`

**品牌统一，识别度更高！** 🎊

