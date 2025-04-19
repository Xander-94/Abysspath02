# Features 功能模块

本目录包含应用程序的所有主要功能模块，每个模块都遵循类似Clean Architecture的组织结构。

## 模块结构

每个功能模块通常包含以下子目录：
```
feature_name/
├── data/              # 数据层 (可选，如果逻辑简单可省略)
│   ├── datasources/   # 数据源接口与实现 (如 API Service)
│   └── models/        # 数据传输对象 (DTOs), 通常使用 Freezed
├── services/          # 业务逻辑服务层 (处理复杂逻辑, 调用DataSources)
├── providers/         # 状态管理 (Riverpod Providers/Notifiers)
├── pages/             # UI页面 (Widgets)
└── widgets/           # 模块内可复用的UI组件
```
*注意：根据模块复杂度，`data/` 和 `domain/` 层可能合并或简化。状态管理逻辑通常放在 `providers/` 或与页面紧密结合。*

## 当前模块

### 📱 auth/
- 用户认证：处理登录、注册、会话管理等。

### 📱 home/
- 首页：应用的主要入口和导航中心。

### 📱 profile/
- 用户画像与个人中心：展示用户基本信息、评估生成的画像数据。

### 📱 assessment/
- 学习评估：
  - 通过与 AI 对话进行多轮评估。
  - 展示评估结果和 AI 生成的用户画像分析 (`AssessmentResultPage`)。
  - 包含评估历史记录。

### 📱 learning_path/
- **（新）** 学习路径：
  - 基于用户目标和评估结果，请求后端生成个性化学习路径。
  - 提供知识图谱 (`KnowledgeGraphView`) 和列表两种视图展示路径。
  - 支持查看节点详情和关联的学习资源 (`LearningPathDetailPage`)。

### 📱 survey/
- 问卷系统：用于结构化的信息收集（可能与评估关联）。

### 📱 settings/
- 应用设置：例如主题、语言等。

## 开发规范

1. 遵循模块化原则，降低耦合度。
2. 使用Riverpod进行状态管理。
3. 使用GoRoute进行路由管理。
4. 使用Dio进行网络请求。
5. 优先使用Freezed定义不可变数据模型。
6. 编写清晰的文档注释。
7. 添加必要的单元和Widget测试。 