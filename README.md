# AbyssPath - AI驱动的个性化学习路径生成器

## 项目概述
AbyssPath是一个基于AI的个性化学习路径生成系统，通过智能评估和路径规划，为用户提供定制化的学习体验。

## 技术栈
- 前端：Flutter 3.24.4
- 后端：FastAPI
- 数据库：Supabase/PostgreSQL
- 缓存：Redis
- AI模型：Deepseek API
- Riverpod (状态管理)
- GoRouter (路由管理)
- Dio + Retrofit (网络请求)
- GetIt + Injectable (依赖注入)
## 系统架构
```
[Flutter App] <-> [FastAPI] <-> [Supabase] <-> [Redis] <-> [Deepseek API]
```

## Git分支管理规范

### 分支结构
```
main/          # 主分支，用于存放稳定的生产版本
├── develop/   # 开发分支，所有功能开发都基于此分支
│   ├── feature/  # 功能分支
│   ├── hotfix/   # 紧急修复分支
│   └── release/  # 发布分支
```

### 分支命名规范

#### 功能分支 (feature)
- 格式：`feature/模块名-功能名`
- 示例：`feature/auth-login`
- 说明：用于开发新功能，从develop分支创建，完成后合并回develop分支

#### 修复分支 (hotfix)
- 格式：`hotfix/问题描述`
- 示例：`hotfix/fix-login-error`
- 说明：用于修复生产环境中的紧急问题，从main分支创建，完成后同时合并到main和develop分支

#### 发布分支 (release)
- 格式：`release/版本号`
- 示例：`release/v2.0.0`
- 说明：用于版本发布，从develop分支创建，完成后同时合并到main和develop分支

### 工作流程
1. 功能开发：从develop分支创建feature分支
2. 问题修复：从main分支创建hotfix分支
3. 版本发布：从develop分支创建release分支
4. 合并规则：
   - feature分支 -> develop分支
   - hotfix分支 -> main分支 + develop分支
   - release分支 -> main分支 + develop分支

## 已完成功能
1. 用户认证系统
   - 注册/登录
   - 密码重置
   - 邮箱验证
   - 用户资料管理

2. 学习路径系统
   - 路径生成
   - 路径管理
   - 进度追踪
   - 学习资源管理

3. 能力评估系统
   - 多维度评估
   - 智能分析
   - 报告生成
   - 历史记录

4. 路由系统
   - 页面导航
   - 权限控制
   - 转场动画
   - 深层链接

## 项目结构
```
lib/
  ├── core/           # 核心功能
  │   ├── constants/  # 常量配置
  │   ├── error/      # 错误处理
  │   ├── services/   # 基础服务
  │   ├── theme/      # 主题配置
  │   ├── utils/      # 工具类
  │   └── widgets/    # 公共组件
  │
  ├── features/       # 功能模块
  │   ├── auth/       # 认证模块
  │   ├── path/       # 路径模块
  │   ├── assessment/ # 评估模块
  │   └── profile/    # 用户模块
  │
  ├── l10n/          # 国际化
  └── main.dart      # 入口文件
```

## 开发规范
1. 代码风格
   - 使用Dart官方代码风格
   - 遵循Clean Architecture架构
   - 使用BLoC模式进行状态管理
   - 实现适当的错误处理

2. 命名规范
   - 文件命名：小写字母，下划线分隔
   - 类命名：大驼峰
   - 变量命名：小驼峰
   - 常量命名：大写字母，下划线分隔

3. 注释规范
   - 文件注释：说明文件用途
   - 类注释：说明类功能
   - 方法注释：说明参数和返回值
   - 关键代码注释：说明实现逻辑

## 环境配置
1. Flutter环境
   - Flutter 3.24.4
   - Dart 3.3.0
   - Android Studio 火烈鸟
   - Android SDK 33/34/35

2. 后端环境
   - Python 3.11+
   - FastAPI
   - PostgreSQL 15+
   - Redis 7+

3. 依赖管理
   - pubspec.yaml：前端依赖
   - requirements.txt：后端依赖
   - package.json：工具依赖

## 开发流程
1. 功能开发
   - 创建功能分支
   - 实现功能代码
   - 编写单元测试
   - 提交代码审查

2. 测试流程
   - 单元测试
   - 集成测试
   - 性能测试
   - 用户测试

3. 部署流程
   - 代码审查
   - 自动化测试
   - 构建发布
   - 监控反馈

## 更新日志
### v1.0.0 (2024-04-12)
- 初始化项目结构
- 实现基础工具类
- 完成认证模块
- 搭建评估系统框架

## 贡献指南
1. Fork项目
2. 创建功能分支
3. 提交代码
4. 发起Pull Request

## 许可证
MIT License
