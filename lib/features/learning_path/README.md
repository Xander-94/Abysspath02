# Learning Path 学习路径模块

## 功能说明
本模块负责处理与个性化学习路径相关的所有功能，包括：

- **请求生成路径**: 用户输入学习目标后，通过调用后端 API 请求 AI 生成个性化的学习路径。
- **展示学习路径**: 
    - 以**知识图谱** (`KnowledgeGraphView`) 的形式可视化展示节点和它们之间的关系。
    - 提供**列表视图**，线性地展示所有路径节点。
- **查看节点详情**: 用户可以点击图谱中的节点或列表项，查看节点的详细信息、类型以及关联的学习资源。
- **状态管理**: 使用 Riverpod 管理路径数据的加载状态、错误处理以及用户交互（如节点选择）。

## 目录结构 (当前)
```
learning_path/
├── models/        # Freezed 数据模型 (`learning_path_models.dart`)
├── pages/         # UI 页面
│   ├── learning_path_detail_page.dart # 路径详情页 (包含图谱和列表)
│   └── subpages/
│       └── knowledge_graph_view.dart  # 知识图谱可视化组件
├── providers/     # Riverpod 状态管理 (例如 `LearningPathLogicProvider`)
├── services/      # 服务层
│   ├── learning_path_api_service.dart # 处理与后端 API 的交互
│   └── learning_path_service.dart     # (可能包含) 组合业务逻辑
└── widgets/       # (可选) 模块内可复用的 UI 组件
```

## 关键组件
- **`LearningPathDetailPage`**: 模块主页面，包含 Tab 切换逻辑，展示图谱或列表，并处理节点选择和详情显示。
- **`KnowledgeGraphView`**: 核心可视化组件，使用 `InteractiveViewer` 和 `CustomPaint` 绘制节点和边。
- **`LearningPathApiService`**: 负责通过 Dio 调用后端 `/api/learning-paths/` 相关接口，获取和创建学习路径。
- **`LearningPathLogicProvider` (或类似)**: Riverpod Provider，封装获取和管理 `FullLearningPathResponse` 数据的业务逻辑。
- **`learning_path_models.dart`**: 使用 Freezed 定义与学习路径相关的 Dart 数据模型 (如 `LearningPath`, `PathNode`, `PathEdge`, `NodeResource`, `FullLearningPathResponse`)。

## 数据交互
- 模块通过 `LearningPathApiService` 与后端 FastAPI 服务进行通信。
- 主要交互是获取指定 ID 的学习路径详情 (`GET /learning-paths/{path_id}`) 和请求创建新的学习路径 (`POST /learning-paths/`)。

## 开发要点
- **模型可空性**: 由于后端 API 返回的数据可能包含 `null` 值（即使是 ID 字段），本模块的 Freezed 模型 (`learning_path_models.dart`) 中的**大量字段已被设为可空 (`String?`)**，并且在 UI 代码中添加了相应的 `null` 处理（例如 `?? ''`）。这是为了确保数据解析的健壮性。
- **代码生成**: 在修改 `learning_path_models.dart` 后，**必须**运行 `flutter pub run build_runner build --delete-conflicting-outputs` 来更新生成的 `.freezed.dart` 和 `.g.dart` 文件。
- **状态管理**: 遵循 Riverpod 的最佳实践来管理异步数据加载、用户交互状态和错误处理。 