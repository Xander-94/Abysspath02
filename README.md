# AbyssPath - AI驱动的个性化学习路径规划应用

## 项目简介
AbyssPath 是一个基于 Flutter 开发的移动应用，结合 AI 技术为用户提供个性化的学习路径规划。应用通过评估用户当前知识水平和学习目标，生成定制化的学习计划。

## 技术栈
- 前端：Flutter 3.24.4
- 后端：FastAPI
- 数据库：Supabase + PostgreSQL
- AI 模型：Deepseek API

## 主要功能
1. 用户认证
   - 注册/登录
   - 密码重置
   - 个人信息管理

2. 学习评估
   - 知识水平评估
   - 学习目标设定
   - 实时反馈

3. 学习路径
   - AI 生成学习路径
   - 进度追踪
   - 路径调整

4. 个人中心
   - 个人信息管理
   - 学习历史
   - 进度统计

## 环境要求
- Flutter 3.24.4
- JDK 17
- Gradle 8.3
- Android Studio Flamingo
- Android SDK 33/34/35
- Supabase 账号
- Deepseek API Key

## 安装说明
1. 克隆项目
```bash
git clone [repository-url]
cd abysspath
```

2. 安装依赖
```bash
flutter pub get
```

3. 配置环境变量
创建 .env 文件并配置以下变量：
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
DEEPSEEK_API_KEY=your_deepseek_api_key
```

4. 运行项目
```bash
flutter run
```

## 项目结构
```
lib/
├── core/                 # 核心功能
│   ├── constants/        # 常量定义
│   ├── theme/           # 主题配置
│   ├── utils/           # 工具类
│   ├── widgets/         # 公共组件
│   └── providers/       # 全局状态管理
├── features/            # 功能模块
│   ├── auth/           # 认证模块
│   ├── assessment/     # 评估模块
│   ├── learning_path/  # 学习路径模块
│   └── profile/        # 个人中心模块
└── main.dart           # 入口文件
```

## 开发规范
1. 代码风格
   - 使用 Flutter 官方推荐的代码风格
   - 遵循 clean architecture 原则
   - 使用 Riverpod 进行状态管理

2. 提交规范
   - feat: 新功能
   - fix: 修复问题
   - docs: 文档变更
   - style: 代码格式
   - refactor: 代码重构
   - test: 测试相关
   - chore: 其他修改

## 贡献指南
1. Fork 项目
2. 创建特性分支
3. 提交修改
4. 发起 Pull Request

## 版本历史
- v0.1.0 (2024-03-xx)
  - 初始版本发布
  - 基础功能实现
  - 用户认证系统
  - AI 评估功能
  - 学习路径生成

## 许可证
MIT License
