# Features 功能模块

本目录包含应用程序的所有主要功能模块，每个模块都遵循Clean Architecture架构。

## 模块结构

每个功能模块都遵循以下结构：
```
feature_name/
├── data/              # 数据层
│   ├── datasources/   # 数据源实现
│   ├── models/        # 数据模型
│   └── repositories/  # 仓库实现
├── domain/            # 领域层
│   ├── entities/      # 业务实体
│   ├── repositories/  # 仓库接口
│   └── usecases/     # 用例定义
└── presentation/      # 表现层
    ├── bloc/         # 状态管理
    ├── pages/        # 页面
    └── widgets/      # 组件
```

## 当前模块

### 📱 auth/
- 用户认证
- 登录注册
- 密码重置
- 身份验证

### 📱 home/
- 首页展示
- 导航功能
- 数据概览

### 📱 profile/
- 用户资料
- 个人设置
- 账户管理

### 📱 assessment/
- 能力评估
- 测试系统
- 结果分析

### 📱 learning_path/
- 学习路径
- 课程推荐
- 进度跟踪

### 📱 survey/
- 问卷调查
- 数据收集
- 反馈系统

### 📱 settings/
- 应用设置
- 主题切换
- 语言设置
- 通知管理

## 开发规范

1. 严格遵循Clean Architecture分层
2. 使用Riverpod进行状态管理
3. 实现Repository模式访问数据
4. 每个功能模块独立可测试
5. 编写单元测试和Widget测试 