# 环境配置说明

## ⚠️ 重要：配置 .env 文件

项目已重构为使用环境变量管理 API Key，您需要手动创建 `.env` 文件。

### 步骤

#### 1. 创建 .env 文件

在项目根目录创建 `.env` 文件：

```bash
touch .env
```

#### 2. 添加配置内容

在 `.env` 文件中添加以下内容：

```
UNSPLASH_ACCESS_KEY=oOYmJINogxLlNPH8zERilSmGmw8EzoMK2yp6HEPKWIw
```

**注意：** 
- 上面的 Key 是您项目中原有的 API Key
- 如需使用新的 Key，请访问 [Unsplash Developers](https://unsplash.com/developers) 注册获取
- `.env` 文件已添加到 `.gitignore`，不会被提交到 Git

#### 3. 验证配置

运行项目，如果配置正确，应用会正常启动并能加载图片。

如果看到错误提示 "UNSPLASH_ACCESS_KEY 未配置"，说明 `.env` 文件配置有问题。

---

## 📝 示例 .env 文件

创建 `.env` 文件后，内容应类似：

```env
# Unsplash API 配置
UNSPLASH_ACCESS_KEY=your_actual_api_key_here
```

---

## 🔒 安全性

- ✅ `.env` 文件不会被提交到 Git（已在 .gitignore 中配置）
- ✅ API Key 不再硬编码在代码中
- ✅ 可以为不同环境使用不同的配置文件

