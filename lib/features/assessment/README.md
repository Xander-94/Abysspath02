# Assessment 评估模块

## 功能说明
- **多轮对话评估**: 通过与 AI 进行多轮对话来评估用户能力和目标。
- **智能追问**: AI 根据对话上下文生成相关追问问题。
- **评估结果展示 (`AssessmentResultPage`)**: 
    - 展示 AI 生成的用户画像分析结果。
    - **近期 UI 优化**: 对该页面进行了视觉和布局改进，包括添加图标、优化卡片样式、调整间距等，以提升可读性和用户体验。
- 能力评估测试 (通过对话进行)
- 测试结果分析 (集成在对话反馈和最终报告中)
- 评估报告生成 (待实现，目前结果集成在画像中)
- 历史记录查看与管理
- 评估建议 (通过对话反馈和报告提供)

## 目录结构 (示例)
```
assessment/
├── data/         # 数据层 (模型, 数据源)
├── providers/    # 状态管理 (Riverpod)
├── pages/        # UI 页面 (`assessment_page.dart`, `assessment_result_page.dart`)
├── services/     # 业务逻辑服务
└── widgets/      # 模块特定组件
```
*具体结构可能因实现细节调整*

## 关键组件
- **`AssessmentPage`**: 进行多轮对话评估的主界面。
- **`AssessmentResultPage`**: 展示评估结果和用户画像的页面。
- **`AssessmentProvider`/`DialogueProvider` (或类似)**: Riverpod Provider，管理对话状态、与后端服务交互、处理 AI 响应。
- **`AssessmentService` (或类似)**: 封装调用后端对话/评估 API 的逻辑。
- **`assessment_models.dart` (或类似)**: 定义与评估、对话相关的 Freezed 模型。

## 目录结构
- data/
  - datasources/  # 数据源
  - models/       # 数据模型
  - repositories/ # 仓库实现
- domain/
  - entities/     # 实体 (较少使用，业务逻辑主要在 Provider)
  - repositories/ # 仓库接口 (较少使用，业务逻辑主要在 Provider)
  - usecases/     # 用例 (较少使用，业务逻辑主要在 Provider)
- providers/      # 状态管理 (Riverpod)
- pages/        # 页面
- services/     # 服务层 (封装业务逻辑和 API 调用)
- widgets/      # 评估模块特定的组件 