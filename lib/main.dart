import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/welcome_page.dart';
import 'pages/home_page.dart';
import 'app/theme/theme_manager.dart';
import 'app/routes/app_routes.dart';
import 'core/config/app_config.dart';
import 'core/utils/error_handler.dart';
import 'core/utils/logger.dart';

void main() async {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化环境配置
  try {
    await AppConfig.init();
    Logger.info('环境配置初始化成功');
  } catch (e) {
    Logger.error('环境配置初始化失败', e);
  }

  // 初始化全局错误处理
  ErrorHandler.init();

  // 注册全局服务
  Get.put(ThemeManager());
  Logger.info('全局服务初始化完成');

  // 在 Zone 中运行应用，捕获所有异步错误
  runZonedGuarded(() => runApp(const MyApp()), (error, stackTrace) {
    ErrorHandler.handleAsyncError(error, stackTrace);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Get.find<ThemeManager>();

    return Obx(
      () => GetMaterialApp(
        title: '壁纸工具',
        debugShowCheckedModeBanner: false,
        // 明暗主题配置
        theme: ThemeManager.getLightTheme(),
        darkTheme: ThemeManager.getDarkTheme(),
        themeMode: themeManager.themeMode,
        // 初始路由为欢迎页
        initialRoute: AppRoutes.welcome,
        getPages: [
          GetPage(name: AppRoutes.welcome, page: () => WelcomePage()),
          GetPage(name: AppRoutes.home, page: () => HomePage()),
        ],
      ),
    );
  }
}
