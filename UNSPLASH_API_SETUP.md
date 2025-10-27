# Unsplash API 配置说明

## 获取 Unsplash API Access Key

1. 访问 [Unsplash Developers](https://unsplash.com/developers)
2. 登录或注册 Unsplash 账号
3. 点击 "Register as a developer"
4. 创建一个新的应用程序（New Application）
5. 填写应用信息：
   - Application name: `Wallpaper Unsplash`
   - Description: `A Flutter wallpaper app using Unsplash API`
6. 同意条款并创建应用
7. 复制 `Access Key`

## 配置 API Key

打开 `lib/services/unsplash_service.dart` 文件，找到以下代码：

```dart
static const String _accessKey = 'YOUR_UNSPLASH_ACCESS_KEY';
```

将 `YOUR_UNSPLASH_ACCESS_KEY` 替换为你的实际 Access Key：

```dart
static const String _accessKey = '你的_Access_Key_在这里';
```

## 注意事项

⚠️ **重要提示**：
- 不要将包含真实 API Key 的代码提交到公共代码仓库
- 在生产环境中，建议使用环境变量或配置文件来管理密钥
- Unsplash 免费版有请求限制（50 requests/hour）

## 测试 API

配置完成后，运行应用：

```bash
flutter run
```

如果配置正确，欢迎页面应该会显示一张来自 Unsplash 的随机图片。

## API 限制

Unsplash 免费版 API 限制：
- **Demo/Development**: 50 requests/hour
- **Production**: 需要申请 Production 权限，可以获得 5,000 requests/hour

## 更好的配置方式（可选）

如果你想更安全地管理 API Key，可以：

1. 创建 `.env` 文件（不要提交到 git）
2. 使用 `flutter_dotenv` 包加载环境变量
3. 添加 `.env` 到 `.gitignore`

示例：

```dart
// pubspec.yaml
dependencies:
  flutter_dotenv: ^5.1.0

// .env
UNSPLASH_ACCESS_KEY=你的_Access_Key
```

```dart
// unsplash_service.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

static final String _accessKey = dotenv.env['UNSPLASH_ACCESS_KEY'] ?? '';
```

