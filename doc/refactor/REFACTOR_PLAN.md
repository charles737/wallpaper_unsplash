# Wallpaper Unsplash 项目重构计划

根据 `.cursorrules` 规范进行全面代码重构优化

---

## 📊 现状分析

### ✅ 做得好的地方
- 代码有完整的中文注释
- 使用了 final 声明不可变属性
- Widget 拆分合理，功能单一
- 有文档注释说明
- 使用了 ListView.builder、GridView.builder 等优化方案
- 响应式布局适配桌面和移动端

### ❌ 需要改进的问题

#### 🔴 高优先级（影响安全性和架构）

1. **API Key 硬编码**
   - 位置：`lib/services/unsplash_service.dart:14-15`
   - 问题：API Key 直接写在代码中
   - 风险：安全隐患，代码泄露即 Key 泄露
   - 规范要求：使用环境变量存储

2. **缺少全局错误处理**
   - 位置：`lib/main.dart`
   - 问题：没有设置 FlutterError.onError 和 runZonedGuarded
   - 影响：错误无法统一捕获和上报
   - 规范要求：在 main.dart 中配置全局错误处理

3. **项目结构不符合规范**
   - 当前结构：
     ```
     lib/
     ├── main.dart
     ├── models/
     ├── pages/
     └── services/
     ```
   - 规范要求（GetX 版本）:
     ```
     lib/
     ├── app/         # 应用配置层
     ├── core/        # 核心功能层
     ├── data/        # 数据层
     ├── modules/     # 功能模块（GetX）
     ├── shared/      # 共享层
     └── main.dart
     ```

4. **没有使用状态管理方案**
   - 当前：使用原始的 StatefulWidget + ChangeNotifier
   - 问题：状态管理混乱，代码冗余
   - 规范推荐：使用 GetX 进行状态管理

#### 🟡 中优先级（影响代码质量）

5. **网络层未使用 Dio**
   - 当前：使用 http 包
   - 问题：缺少拦截器、统一错误处理
   - 规范要求：使用 Dio 并配置拦截器（日志、认证、错误）

6. **路由使用魔法字符串**
   - 位置：`lib/main.dart:49-52`
   - 问题：`'/'`、`'/home'` 硬编码
   - 规范要求：定义路由常量类，使用命名路由

7. **缺少日志管理**
   - 当前：使用 debugPrint
   - 问题：无法区分日志级别，难以管理
   - 规范要求：封装日志工具类，区分级别

8. **数据模型缺少 copyWith**
   - 位置：`lib/models/unsplash_photo.dart`
   - 问题：不可变对象无法方便地创建副本
   - 规范要求：提供 copyWith 方法

9. **异常类型不明确**
   - 当前：所有异常都是 `Exception('xxx')`
   - 问题：无法区分错误类型
   - 规范要求：创建自定义异常类

#### 🟢 低优先级（优化建议）

10. **可以使用扩展方法**
    - 可以为 String、DateTime 等添加扩展方法
    - 提高代码可读性

11. **可以考虑使用代码生成**
    - 使用 json_serializable 或 freezed
    - 减少样板代码

---

## 🎯 重构方案

### 阶段一：基础架构重构（高优先级）

#### 1.1 安全性改造

**任务：将 API Key 移到环境变量**

1. 创建 `.env` 文件（不提交到 Git）
   ```
   UNSPLASH_ACCESS_KEY=your_api_key_here
   ```

2. 创建 `.env.example` 文件（提交到 Git）
   ```
   UNSPLASH_ACCESS_KEY=your_unsplash_api_key
   ```

3. 更新 `.gitignore`
   ```
   .env
   ```

4. 添加依赖
   ```yaml
   dependencies:
     flutter_dotenv: ^5.1.0
   ```

5. 更新 `pubspec.yaml` 资源配置
   ```yaml
   flutter:
     assets:
       - .env
   ```

6. 创建 `lib/core/config/app_config.dart`
   - 封装环境变量读取
   - 提供 API Key 访问方法

7. 修改 `lib/services/unsplash_service.dart`
   - 移除硬编码的 API Key
   - 从 AppConfig 读取

#### 1.2 全局错误处理

**任务：在 main.dart 配置全局错误捕获**

1. 更新 `lib/main.dart`
   - 添加 FlutterError.onError
   - 使用 runZonedGuarded 包裹 runApp
   - 区分开发和生产环境

2. 创建 `lib/core/utils/error_handler.dart`
   - 封装错误处理逻辑
   - 提供错误上报接口（可选）

#### 1.3 项目结构重组

**任务：重新组织目录结构**

创建新的目录结构：

```
lib/
├── app/
│   ├── routes/
│   │   ├── app_pages.dart          # GetX 路由页面配置
│   │   └── app_routes.dart         # 路由常量
│   ├── theme/
│   │   └── app_theme.dart          # 主题配置（移动 theme_manager）
│   └── constants/
│       └── api_constants.dart      # API 相关常量
│
├── core/
│   ├── config/
│   │   └── app_config.dart         # 环境配置
│   ├── network/
│   │   ├── dio_client.dart         # Dio 封装
│   │   └── interceptors/           # 拦截器
│   │       ├── auth_interceptor.dart
│   │       ├── logger_interceptor.dart
│   │       └── error_interceptor.dart
│   └── utils/
│       ├── logger.dart              # 日志工具
│       └── error_handler.dart       # 错误处理
│
├── data/
│   ├── models/
│   │   ├── photo_category.dart     # 移动现有模型
│   │   └── unsplash_photo.dart     # 移动现有模型
│   ├── services/
│   │   └── unsplash_service.dart   # 移动并重构
│   └── exceptions/
│       ├── network_exception.dart  # 自定义异常
│       └── api_exception.dart
│
├── modules/
│   ├── welcome/                     # 欢迎页模块
│   │   ├── controllers/
│   │   │   └── welcome_controller.dart
│   │   └── views/
│   │       └── welcome_page.dart
│   │
│   ├── home/                        # 首页模块
│   │   ├── controllers/
│   │   │   └── home_controller.dart
│   │   └── views/
│   │       └── home_page.dart
│   │
│   └── photo_detail/                # 照片详情模块
│       ├── controllers/
│       │   └── photo_detail_controller.dart
│       └── views/
│           └── photo_detail_page.dart
│
├── shared/
│   ├── widgets/                     # 通用组件
│   │   ├── loading_indicator.dart
│   │   └── error_view.dart
│   └── extensions/                  # 扩展方法
│       └── string_extension.dart
│
└── main.dart
```

#### 1.4 引入 GetX

**任务：集成 GetX 状态管理**

1. 添加依赖
   ```yaml
   dependencies:
     get: ^4.6.6
   ```

2. 更新 main.dart
   - 将 MaterialApp 改为 GetMaterialApp
   - 注册全局服务

3. 创建 Controllers
   - WelcomeController
   - HomeController
   - PhotoDetailController

4. 重构现有的 StatefulWidget
   - 使用 StatelessWidget + Obx
   - 逻辑移到 Controller

---

### 阶段二：网络和数据层优化（中优先级）

#### 2.1 升级到 Dio

**任务：使用 Dio 替换 http**

1. 添加依赖
   ```yaml
   dependencies:
     dio: ^5.4.0
   ```

2. 创建 `lib/core/network/dio_client.dart`
   - 单例模式
   - 配置 baseUrl、超时
   - 添加拦截器

3. 创建拦截器
   - auth_interceptor.dart：添加 token
   - logger_interceptor.dart：记录请求日志
   - error_interceptor.dart：统一错误处理

4. 重构 unsplash_service.dart
   - 使用 DioClient
   - 优化错误处理

#### 2.2 路由管理

**任务：使用 GetX 命名路由**

1. 创建 `lib/app/routes/app_routes.dart`
   - 定义所有路由常量

2. 创建 `lib/app/routes/app_pages.dart`
   - 配置 GetPage
   - 设置页面过渡动画

3. 更新所有页面的导航代码
   - 使用 Get.toNamed
   - 使用 Get.arguments 传递参数

#### 2.3 日志管理

**任务：封装日志工具类**

1. 创建 `lib/core/utils/logger.dart`
   - 区分日志级别（debug、info、warning、error）
   - 开发环境启用日志
   - 生产环境关闭 debug 日志

2. 替换所有 debugPrint
   - 使用 Logger.debug
   - 使用 Logger.error

#### 2.4 自定义异常

**任务：创建异常类**

1. 创建 `lib/data/exceptions/network_exception.dart`
   - 网络相关异常

2. 创建 `lib/data/exceptions/api_exception.dart`
   - API 错误异常

3. 更新 unsplash_service.dart
   - 抛出具体的异常类型

#### 2.5 数据模型优化

**任务：添加 copyWith 方法**

1. 更新 UnsplashPhoto
   - 添加 copyWith 方法

2. 更新 PhotoUrls
   - 添加 copyWith 方法

3. 更新 User
   - 添加 copyWith 方法

---

### 阶段三：代码优化和扩展（低优先级）

#### 3.1 扩展方法

1. 创建 `lib/shared/extensions/string_extension.dart`
   - isValidEmail
   - capitalize 等

2. 创建 `lib/shared/extensions/date_extension.dart`
   - formattedDate
   - isToday 等

#### 3.2 共享组件

1. 创建 `lib/shared/widgets/loading_indicator.dart`
   - 统一的加载指示器

2. 创建 `lib/shared/widgets/error_view.dart`
   - 统一的错误显示

3. 创建 `lib/shared/widgets/photo_card.dart`
   - 照片卡片组件

#### 3.3 代码生成（可选）

1. 添加依赖
   ```yaml
   dependencies:
     freezed_annotation: ^2.4.1
     json_annotation: ^4.8.1
   
   dev_dependencies:
     build_runner: ^2.4.6
     freezed: ^2.4.5
     json_serializable: ^6.7.1
   ```

2. 使用 freezed 重构数据模型
   - 自动生成 copyWith
   - 自动生成 toJson/fromJson

---

## 📝 实施步骤

### 第一步：安全和错误处理（必须）
1. ✅ 创建 .env 文件配置
2. ✅ 添加全局错误处理
3. ✅ 创建日志工具类
4. ✅ 创建自定义异常类

### 第二步：项目结构重组（推荐）
1. ✅ 创建新的目录结构
2. ✅ 移动现有文件到新位置
3. ✅ 更新所有导入路径

### 第三步：引入 GetX（推荐）
1. ✅ 集成 GetX 依赖
2. ✅ 创建 Controllers
3. ✅ 重构页面为 StatelessWidget + Obx
4. ✅ 配置路由管理

### 第四步：网络层升级（推荐）
1. ✅ 集成 Dio
2. ✅ 创建拦截器
3. ✅ 重构 API 服务

### 第五步：优化和扩展（可选）
1. ⭕ 添加扩展方法
2. ⭕ 创建共享组件
3. ⭕ 使用代码生成工具

---

## ⚠️ 注意事项

1. **渐进式重构**
   - 不要一次性重构所有代码
   - 按模块逐步迁移
   - 每个阶段测试通过后再继续

2. **保持可运行**
   - 确保每次提交代码都能运行
   - 避免长时间的大规模重构

3. **测试验证**
   - 重构后充分测试功能
   - 确保没有破坏现有功能

4. **Git 提交**
   - 每个阶段单独提交
   - 提交信息清晰明确

---

## 🎯 预期效果

重构完成后，项目将获得：

✅ **更安全**：API Key 环境变量管理，全局错误捕获  
✅ **更清晰**：符合规范的项目结构，职责分明  
✅ **更易维护**：GetX 状态管理，代码更简洁  
✅ **更健壮**：完善的错误处理和日志系统  
✅ **更规范**：遵循 Flutter/Dart 最佳实践  
✅ **更高效**：Dio 拦截器，统一网络处理  

---

**建议：优先完成第一步和第二步（安全性和错误处理），其他步骤可根据项目需求选择性实施。**

